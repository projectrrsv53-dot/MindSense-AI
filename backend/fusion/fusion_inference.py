# fusion/fusion_inference.py

import torch
import torch.nn as nn
import torch.nn.functional as F

from transformers import (
    BertTokenizerFast,
    BertModel,
    AutoModel
)

# ============================================================
# CONFIG
# ============================================================

DEVICE = torch.device(
    "cuda" if torch.cuda.is_available() else "cpu"
)

TEXT_MODEL_PATH = "bert-base-uncased"
WAVLM_PATH = "microsoft/wavlm-base"

FUSION_MODEL_PATH = "models/redesign_fusion_model.pt"

TEXT_PROJ_DIM = 128
AUDIO_PROJ_DIM = 128
FUSION_DIM = 256

MAX_LEN = 160

# ============================================================
# TOKENIZER
# ============================================================

tokenizer = BertTokenizerFast.from_pretrained(
    TEXT_MODEL_PATH
)

# ============================================================
# TEXT ENCODER
# ============================================================

class TextEncoder(nn.Module):

    def __init__(self):

        super().__init__()

        self.bert = BertModel.from_pretrained(
            TEXT_MODEL_PATH
        )

        hidden = self.bert.config.hidden_size

        self.proj = nn.Sequential(
            nn.Linear(hidden * 2, TEXT_PROJ_DIM),
            nn.LayerNorm(TEXT_PROJ_DIM),
            nn.GELU(),
        )

    def encode(
        self,
        ids,
        mask
    ):

        out = self.bert(
            ids,
            attention_mask=mask
        )

        cls_pooled = out.last_hidden_state[:, 0]

        token_mask = mask.unsqueeze(-1).float()

        mean_pooled = (
            out.last_hidden_state * token_mask
        ).sum(dim=1)

        mean_pooled = mean_pooled / token_mask.sum(
            dim=1
        ).clamp(min=1e-6)

        combined = torch.cat(
            [cls_pooled, mean_pooled],
            dim=1
        )

        emb = self.proj(combined)

        return emb

# ============================================================
# ATTENTION POOL
# ============================================================

class AttentionPool(nn.Module):

    def __init__(self, dim):

        super().__init__()

        self.scorer = nn.Sequential(
            nn.LayerNorm(dim),
            nn.Linear(dim, dim // 2),
            nn.Tanh(),
            nn.Dropout(0.1),
            nn.Linear(dim // 2, 1),
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
# AUDIO ENCODER
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
            nn.Linear(hidden, AUDIO_PROJ_DIM),
            nn.LayerNorm(AUDIO_PROJ_DIM),
            nn.GELU(),
        )

    def encode(
        self,
        audio,
        audio_mask
    ):

        hidden = self.encoder(
            audio,
            attention_mask=audio_mask
        ).last_hidden_state

        pooled = self.pool(hidden)

        emb = self.proj(pooled)

        return emb

# ============================================================
# FUSION MODEL
# ============================================================

class FusionModel(nn.Module):

    def __init__(self):

        super().__init__()

        self.gate = nn.Linear(
            TEXT_PROJ_DIM + AUDIO_PROJ_DIM,
            TEXT_PROJ_DIM + AUDIO_PROJ_DIM
        )

        self.pre_residual = nn.Linear(
            TEXT_PROJ_DIM + AUDIO_PROJ_DIM + TEXT_PROJ_DIM,
            FUSION_DIM
        )

        self.mlp = nn.Sequential(
            nn.LayerNorm(FUSION_DIM),
            nn.GELU(),
            nn.Dropout(0.3),

            nn.Linear(FUSION_DIM, FUSION_DIM),

            nn.LayerNorm(FUSION_DIM),
            nn.GELU(),
            nn.Dropout(0.2),
        )

        self.classifier = nn.Linear(
            FUSION_DIM,
            2
        )

    def forward(
        self,
        text_emb,
        audio_emb
    ):

        combined = torch.cat(
            [text_emb, audio_emb],
            dim=1
        )

        gate = torch.sigmoid(
            self.gate(combined)
        )

        gate_text = gate[:, :TEXT_PROJ_DIM]
        gate_audio = gate[:, TEXT_PROJ_DIM:]

        interaction = text_emb * audio_emb

        combined = torch.cat([
            gate_text * text_emb,
            gate_audio * audio_emb,
            interaction
        ], dim=1)

        fused = self.pre_residual(combined)

        fused = fused + self.mlp(fused)

        logits = self.classifier(fused)

        return logits

# ============================================================
# LOAD MODELS
# ============================================================

text_model = TextEncoder().to(DEVICE)
audio_model = AudioEncoder().to(DEVICE)
fusion_model = FusionModel().to(DEVICE)

checkpoint = torch.load(
    FUSION_MODEL_PATH,
    map_location=DEVICE
)

fusion_model.load_state_dict(
    checkpoint["model"],
    strict=False
)

fusion_model.eval()
text_model.eval()
audio_model.eval()

# ============================================================
# PREDICT
# ============================================================

def predict_fusion(
    text,
    audio,
    audio_mask
):

    enc = tokenizer(
        text,
        padding="max_length",
        truncation=True,
        max_length=MAX_LEN,
        return_tensors="pt"
    )

    ids = enc["input_ids"].to(DEVICE)
    mask = enc["attention_mask"].to(DEVICE)

    with torch.no_grad():

        text_emb = text_model.encode(
            ids,
            mask
        )

        audio_emb = audio_model.encode(
            audio,
            audio_mask
        )

        logits = fusion_model(
            text_emb,
            audio_emb
        )

        probs = torch.softmax(
            logits,
            dim=-1
        )[0]

        pred = torch.argmax(probs).item()

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
