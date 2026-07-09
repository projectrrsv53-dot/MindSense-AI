# import whisper

# model = whisper.load_model("small")

# def transcribe_audio(path):

#     result = model.transcribe(
#         path,
#         verbose=False
#     )

#     return result["text"]
import whisper

model = None

def get_model():
    global model

    if model is None:
        model = whisper.load_model("small")

    return model


def transcribe_audio(path):

    model = get_model()

    result = model.transcribe(path)

    return result["text"]