from huggingface_hub import hf_hub_download

REPO_ID = "RRSV/MindSense-AI-Models"

MODELS = [
    "depression_model.pt",
    "redesign_fusion_model.pt",
]

for file in MODELS:
    print(f"Downloading {file}...")

    hf_hub_download(
        repo_id=REPO_ID,
        filename=file,
        local_dir="models",
        local_dir_use_symlinks=False,
    )

print("All models downloaded.")