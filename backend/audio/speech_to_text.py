import whisper

model = whisper.load_model("small")

def transcribe_audio(path):

    result = model.transcribe(
        path,
        verbose=False
    )

    return result["text"]