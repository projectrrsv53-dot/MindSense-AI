#text/clean_text.py
import re
import pandas as pd

def preprocess_text(text):

    if pd.isna(text):
        return ""

    text = text.lower()

    text = re.sub(r"\b(um|uh)\b", "", text)

    text = text.replace("ellie", "")

    text = re.sub(r"[^\w\s]", "", text)

    text = re.sub(r"\s+", " ", text).strip()

    return text