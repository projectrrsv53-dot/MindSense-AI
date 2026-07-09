from pydub import AudioSegment


def convert_to_standard_wav(input_path, output_path):

    audio = AudioSegment.from_file(input_path)

    audio = (
        audio
        .set_frame_rate(16000)
        .set_channels(1)
        .set_sample_width(2)
    )

    audio.export(
        output_path,
        format="wav"
    )

    return output_path