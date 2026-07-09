from huggingface_hub import HfApi
import os

USERNAME = "RRSV"
REPO_NAME = "MindSense-AI-Models"

repo_id = f"{USERNAME}/{REPO_NAME}"

api = HfApi()

models = [
    "models/depression_model.pt",
    "models/redesign_audio_model.pt",
    "models/redesign_fusion_model.pt",
]

for model in models:

    print(f"\nUploading {model} ...")

    api.upload_file(
        path_or_fileobj=model,
        path_in_repo=os.path.basename(model),
        repo_id=repo_id,
        repo_type="model",
    )

    print(f"Finished uploading {model}")

print("\n🎉 All models uploaded successfully!")