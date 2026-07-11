
#text/depression_predictor.py
import torch
import torch.nn as nn
import numpy as np

from transformers import (
    BertTokenizerFast,
    BertModel
)

DEVICE = torch.device(
    "cuda" if torch.cuda.is_available() else "cpu"
)

TOKENIZER_NAME = "bert-base-uncased"

#MODEL_PATH = "models/depression_model.pt"
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

MODEL_PATH = os.path.join(
    BASE_DIR,
    "..",
    "models",
    "depression_model.pt"
)

tokenizer = BertTokenizerFast.from_pretrained(
    TOKENIZER_NAME
)

MAX_LEN = 128

# ============================================================
# MODEL
# ============================================================

class Model(nn.Module):

    def __init__(self):

        super().__init__()

        self.bert = BertModel.from_pretrained(
            TOKENIZER_NAME
        )

        hidden = self.bert.config.hidden_size

        fused_dim = hidden * 2 + 3

        self.classifier = nn.Sequential(
            nn.LayerNorm(fused_dim),
            nn.Linear(fused_dim, 256),
            nn.GELU(),
            nn.Dropout(0.35),
            nn.Linear(256, 64),
            nn.GELU(),
            nn.Dropout(0.25),
            nn.Linear(64, 2),
        )

        self.sentiment_head = nn.Sequential(
            nn.LayerNorm(hidden * 2),
            nn.Linear(hidden * 2, 128),
            nn.GELU(),
            nn.Dropout(0.2),
            nn.Linear(128, 2),
        )

    def forward(
        self,
        ids,
        mask,
        p_neg,
        p_pos,
        strength
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

        bert_features = torch.cat(
            [cls_pooled, mean_pooled],
            dim=1
        )

        sentiment_features = torch.stack(
            [p_neg, p_pos, strength],
            dim=1
        )

        main_input = torch.cat(
            [bert_features, sentiment_features],
            dim=1
        )

        main_logits = self.classifier(main_input)

        sentiment_logits = self.sentiment_head(
            bert_features
        )

        return main_logits, sentiment_logits


# ============================================================
# LOAD MODEL
# ============================================================

model = None

def load_text_model():

    global model

    if model is None:

        model = Model().to(DEVICE)

        checkpoint = torch.load(
            MODEL_PATH,
            map_location=DEVICE
        )

        model.load_state_dict(
            checkpoint["model_state_dict"]
        )

        model.eval()

    return model

# ============================================================
# PREDICTION FUNCTION
# ============================================================

def chunk_text(text, max_tokens=128, stride=64):
  
    tokens = tokenizer.encode(
        text,
        add_special_tokens=False
    )

    chunks = []

    for i in range(0, len(tokens), stride):

        chunk = tokens[i:i + max_tokens]

        if len(chunk) == 0:
            continue

        chunk_text = tokenizer.decode(chunk)

        chunks.append(chunk_text)

        if len(chunk) < max_tokens:
            break

    return chunks

def predict_all(text):
    model = load_text_model()
  
    chunks = chunk_text(text)

    dep_probs_all = []
    sent_probs_all = []

    for chunk in chunks:

        enc = tokenizer(
            chunk,
            padding="max_length",
            truncation=True,
            max_length=MAX_LEN,
            return_tensors="pt"
        )

        ids = enc["input_ids"].to(DEVICE)
        mask = enc["attention_mask"].to(DEVICE)

        p_neg = torch.tensor([0.5]).to(DEVICE)
        p_pos = torch.tensor([0.5]).to(DEVICE)
        strength = torch.tensor([0.0]).to(DEVICE)

        with torch.no_grad():

            main_logits, sent_logits = model(
                ids,
                mask,
                p_neg,
                p_pos,
                strength
            )

            dep_probs = torch.softmax(
                main_logits,
                dim=-1
            )[0]

            sent_probs = torch.softmax(
                sent_logits,
                dim=-1
            )[0]

            dep_probs_all.append(dep_probs.cpu().numpy())
            sent_probs_all.append(sent_probs.cpu().numpy())

    # =========================
    # AVERAGE CHUNK PREDICTIONS
    # =========================

    dep_probs_mean = np.mean(dep_probs_all, axis=0)
    sent_probs_mean = np.mean(sent_probs_all, axis=0)

    dep_class = np.argmax(dep_probs_mean)
    sent_class = np.argmax(sent_probs_mean)

    depression_label = (
        "Depressed"
        if dep_class == 1
        else "Not Depressed"
    )

    sentiment_label = (
        "Negative"
        if sent_class == 1
        else "Positive"
    )

    return {

        "depression": {
            "label": depression_label,
            "confidence": float(dep_probs_mean[dep_class])
        },

        "sentiment": {
            "label": sentiment_label,
            "confidence": float(sent_probs_mean[sent_class])
        }
    }
