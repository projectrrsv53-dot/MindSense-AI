#audio_inference.py

import torch
import torch.nn as nn
import torch.nn.functional as F
import numpy as np
import soundfile as sf

from transformers import AutoModel

# ============================================================
# CONFIG
# ============================================================

DEVICE = torch.device(
    "cuda" if torch.cuda.is_available() else "cpu"
)

AUDIO_SR = 16000

MIN_WAVLM_INPUT_SAMPLES = 400

MAX_AUDIO_SECONDS = 15

MAX_AUDIO_SAMPLES = AUDIO_SR * MAX_AUDIO_SECONDS

MODEL_PATH = "models/redesign_audio_model.pt"

WAVLM_PATH = "microsoft/wavlm-base"

AUDIO_PROJ_DIM = 128

# ============================================================
# ATTENTION POOL
# ============================================================

class AttentionPool(nn.Module):

    def __init__(self, dim):

        super().__init__()

        self.scorer = nn.Sequential(

            nn.LayerNorm(dim),

            nn.Linear(
                dim,
                dim // 2
            ),

            nn.Tanh(),

            nn.Dropout(0.1),

            nn.Linear(
                dim // 2,
                1
            ),
        )

    def forward(
        self,
        x,
        mask=None
    ):

        scores = self.scorer(x).squeeze(-1)

        if mask is not None:

            scores = scores.masked_fill(
                ~mask.bool(),
                torch.finfo(scores.dtype).min
            )

        weights = torch.softmax(
            scores,
            dim=-1
        )

        pooled = (
            x * weights.unsqueeze(-1)
        ).sum(dim=1)

        return pooled

# ============================================================
# AUDIO MODEL
# ============================================================

class AudioEncoder(nn.Module):

    def __init__(self):

        super().__init__()

        self.encoder = AutoModel.from_pretrained(
            WAVLM_PATH
        )

        hidden = self.encoder.config.hidden_size

        self.pool = AttentionPool(hidden)

        self.proj = nn.Sequential(

            nn.Linear(
                hidden,
                AUDIO_PROJ_DIM
            ),

            nn.LayerNorm(
                AUDIO_PROJ_DIM
            ),

            nn.GELU(),

            nn.Dropout(0.2),
        )

        self.classifier = nn.Linear(
            AUDIO_PROJ_DIM,
            2
        )

    def _frame_mask(
        self,
        hidden,
        audio_mask
    ):

        try:

            return self.encoder._get_feature_vector_attention_mask(
                hidden.shape[1],
                audio_mask
            ).bool()

        except Exception:

            return F.interpolate(
                audio_mask.float().unsqueeze(1),
                size=hidden.shape[1],
                mode="nearest"
            ).squeeze(1).bool()

    def encode(
        self,
        audio,
        audio_mask
    ):

        hidden = self.encoder(
            audio,
            attention_mask=audio_mask
        ).last_hidden_state

        hidden = torch.nan_to_num(
            hidden,
            nan=0.0,
            posinf=0.0,
            neginf=0.0
        )

        fmask = self._frame_mask(
            hidden,
            audio_mask
        )

        pooled = self.pool(
            hidden,
            fmask
        )

        pooled = torch.nan_to_num(
            pooled,
            nan=0.0,
            posinf=0.0,
            neginf=0.0
        )

        emb = self.proj(pooled)

        emb = torch.nan_to_num(
            emb,
            nan=0.0,
            posinf=0.0,
            neginf=0.0
        )

        return emb

    def forward(
        self,
        audio,
        audio_mask
    ):

        emb = self.encode(
            audio,
            audio_mask
        )

        logits = self.classifier(emb)

        logits = torch.nan_to_num(
            logits,
            nan=0.0,
            posinf=30.0,
            neginf=-30.0
        )

        return logits

# ============================================================
# LAZY LOAD MODEL
# ============================================================

model = None

def load_audio_model():

    global model

    if model is None:

        model = AudioEncoder().to(DEVICE)

        checkpoint = torch.load(
            MODEL_PATH,
            map_location=DEVICE
        )

        model.load_state_dict(
            checkpoint["model"]
        )

        model.eval()

        print("Audio model loaded successfully")

    return model

# ============================================================
# AUDIO LOADER
# ============================================================

def load_audio(path):

    audio, sr = sf.read(path)

    # stereo -> mono
    if len(audio.shape) > 1:

        audio = audio.mean(axis=1)

    # nan protection
    audio = np.nan_to_num(
        audio,
        nan=0.0,
        posinf=0.0,
        neginf=0.0
    )

    audio = torch.tensor(
        audio,
        dtype=torch.float32
    )

    # resample
    if sr != AUDIO_SR:

        new_len = max(
            1,
            int(round(
                audio.shape[0] * AUDIO_SR / sr
            ))
        )

        audio = F.interpolate(
            audio.view(1, 1, -1),
            size=new_len,
            mode="linear",
            align_corners=False
        ).view(-1)

    audio = torch.nan_to_num(
        audio,
        nan=0.0,
        posinf=0.0,
        neginf=0.0
    )

    # normalize
    mx = audio.abs().max()

    if mx > 1e-8:

        audio = audio / mx

    else:

        audio = torch.zeros_like(audio)

    # truncate
    audio = audio[:MAX_AUDIO_SAMPLES]

    # minimum size
    if audio.numel() < MIN_WAVLM_INPUT_SAMPLES:

        audio = F.pad(
            audio,
            (
                0,
                MIN_WAVLM_INPUT_SAMPLES - audio.numel()
            )
        )

    # bool mask
    mask = torch.ones(
        audio.shape[0],
        dtype=torch.bool
    )

    return (
        audio.unsqueeze(0).to(DEVICE),
        mask.unsqueeze(0).to(DEVICE)
    )

# ============================================================
# PREDICTION FUNCTION
# ============================================================

def predict_audio(path):

    try:

        model = load_audio_model()

        audio, mask = load_audio(path)

        with torch.no_grad():

            logits = model(
                audio,
                mask
            )

            probs = torch.softmax(
                logits,
                dim=-1
            )[0]

            pred = torch.argmax(
                probs
            ).item()

        label = (
            "Depressed"
            if pred == 1
            else "Non-Depressed"
        )

        return {

            "prediction": label,

            "confidence": float(
                probs[pred]
            ),

            "probabilities": {

                "non_depressed": float(
                    probs[0]
                ),

                "depressed": float(
                    probs[1]
                )
            }
        }

    except Exception as e:

        return {
            "error": str(e)
        }