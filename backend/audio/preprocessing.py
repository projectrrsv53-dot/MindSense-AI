#=========================================================
# FINAL PRODUCTION PIPELINE (CLIPPING-SAFE VERSION)
# =========================================================

# audio/preprocessing.py
import os
import numpy as np
import librosa
import soundfile as sf
import webrtcvad
import parselmouth
from tqdm import tqdm
from resemblyzer import VoiceEncoder, preprocess_wav
from sklearn.cluster import KMeans
from scipy.signal import butter, lfilter

# ---------------- PATHS ----------------
# INPUT_DIR = r"E:/Audio"
# OUT_DIR   = r"E:/processed_audio_test3"
# os.makedirs(OUT_DIR, exist_ok=True)

SR = 16000

# encoder = VoiceEncoder()
# vad = webrtcvad.Vad(0)
encoder = None
vad = webrtcvad.Vad(0)

def get_encoder():
    global encoder

    if encoder is None:
        print("Loading VoiceEncoder...")
        encoder = VoiceEncoder()

    return encoder

# =========================================================
# STEP 1 — HIGH PASS (very light)
# =========================================================
def highpass(audio, sr):
    b, a = butter(2, 60/(sr/2), btype='high')
    return lfilter(b, a, audio)

# =========================================================
# STEP 2 — DECLIP (repair flattened waveform)
# =========================================================
def declip(audio, threshold=0.97):

    clipped = np.where(np.abs(audio) >= threshold)[0]
    if len(clipped) == 0:
        return audio

    repaired = np.copy(audio)

    for idx in clipped:
        start = max(0, idx-200)
        end   = min(len(audio), idx+200)

        left  = repaired[start]
        right = repaired[end-1]

        repaired[start:end] = np.linspace(left, right, end-start)

    return repaired

# =========================================================
# STEP 3 — IMPULSE SPIKE REMOVAL (z-score)
# =========================================================
def remove_spikes(audio):
    mean = np.mean(audio)
    std  = np.std(audio)

    z = (audio - mean) / (std + 1e-8)
    spike_idx = np.where(np.abs(z) > 7)[0]

    for idx in spike_idx:
        start = max(0, idx-120)
        end   = min(len(audio), idx+120)
        audio[start:end] = np.median(audio[start:end])

    return audio

# =========================================================
# STEP 4 — SOFT COMPRESSOR (for bursts)
# =========================================================
def soft_compressor(audio, threshold=0.7, ratio=3.0):

    out = np.copy(audio)

    for i in range(len(audio)):
        if abs(audio[i]) > threshold:
            excess = abs(audio[i]) - threshold
            out[i] = np.sign(audio[i]) * (threshold + excess/ratio)

    return out

# =========================================================
# FINAL TARGETED CLEAN
# =========================================================
def targeted_noise(audio, sr):

    audio = highpass(audio, sr)
    audio = declip(audio)
    audio = remove_spikes(audio)
    audio = soft_compressor(audio,
                            threshold=0.75,
                            ratio=4.0)

    return audio

# =========================================================
# VAD SEGMENTATION
# =========================================================
def get_segments(audio, sr):
    frame = int(0.03 * sr)
    segments = []
    current = []

    for i in range(0, len(audio)-frame, frame):
        chunk = audio[i:i+frame]
        pcm = (chunk * 32768).astype(np.int16).tobytes()

        if vad.is_speech(pcm, sr):
            current.extend(chunk)
        else:
            if len(current) > 0.25 * sr:
                segments.append(np.array(current))
            current = []

    if len(current) > 0.25 * sr:
        segments.append(np.array(current))

    return segments

# =========================================================
# SPEAKER FEATURE
# =========================================================
def pitch_var(seg, sr):
    snd = parselmouth.Sound(seg, sr)
    pitch = snd.to_pitch()
    vals = pitch.selected_array['frequency']
    vals = vals[vals > 0]
    return np.std(vals) if len(vals) else 0


def process_file(path):
    encoder = get_encoder()
  
    audio, sr = librosa.load(path, sr=SR)

    # if len(audio) > (120 * sr):
    #     audio = audio[70*sr : -40*sr]

    segments = get_segments(audio, sr)

    if len(segments) < 4:
        return audio

    embeddings = []

    for seg in segments:

        wav = preprocess_wav(seg, source_sr=sr)

        emb = encoder.embed_utterance(wav)

        embeddings.append(emb)

    embeddings = np.array(embeddings)

    kmeans = KMeans(
        n_clusters=2,
        random_state=0
    ).fit(embeddings)

    labels = kmeans.labels_

    scores = {}

    for lab in set(labels):

        idx = np.where(labels == lab)[0]

        total = sum(len(segments[i]) for i in idx)

        pv = np.mean([
            pitch_var(segments[i], sr)
            for i in idx
        ])

        scores[lab] = pv * total

    patient_cluster = max(scores, key=scores.get)

    patient_audio = [
        seg for seg, lab in zip(segments, labels)
        if lab == patient_cluster
    ]

    if len(patient_audio) == 0:
        return audio

    cleaned = np.concatenate(patient_audio)

    cleaned = targeted_noise(cleaned, sr)

    peak = np.max(np.abs(cleaned))

    if peak > 0:
        cleaned = cleaned / peak * 0.9

    return cleaned