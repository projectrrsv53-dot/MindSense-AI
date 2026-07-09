// lib/screens/patient/live_record_screen.dart
import 'dart:io';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/analysis_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../router/app_router.dart';

class LiveRecordScreen extends ConsumerStatefulWidget {
  const LiveRecordScreen({super.key});

  @override
  ConsumerState<LiveRecordScreen> createState() => _LiveRecordScreenState();
}

class _LiveRecordScreenState extends ConsumerState<LiveRecordScreen> {

  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  bool isRecording = false;
  bool hasRecording = false;

  String? audioPath;

  Timer? _recordTimer;

Duration recordingDuration = Duration.zero;

Duration audioDuration = Duration.zero;

Duration currentPosition = Duration.zero;

bool isPlaying = false;

  Future<void> startRecording() async {

    final permission = await _recorder.hasPermission();

    debugPrint("Mic Permission: $permission");

    if (!permission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Microphone permission denied"),
        ),
      );
      return;
    }

    final dir = await getTemporaryDirectory();

    audioPath =
    "${dir.path}/record_${DateTime.now().millisecondsSinceEpoch}.m4a";

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: audioPath!,
    );
    final recording = await _recorder.isRecording();

    debugPrint("Recording Started: $recording");

    recordingDuration = Duration.zero;

_recordTimer?.cancel();

_recordTimer = Timer.periodic(
  const Duration(seconds: 1),
  (_) {
    setState(() {
      recordingDuration += const Duration(seconds: 1);
    });
  },
);

setState(() {
  isRecording = true;
});
  }

  Future<void> stopRecording() async {

    await _recorder.stop();

    // await _recorder.stop();

_recordTimer?.cancel();

setState(() {
  isRecording = false;
  hasRecording = true;
});
  }

  Future<void> playRecording() async {

  if (audioPath == null) return;

  if (isPlaying) {

    await _player.pause();

    setState(() {
      isPlaying = false;
    });

    return;
  }

  await _player.play(
    DeviceFileSource(audioPath!),
  );

  setState(() {
    isPlaying = true;
  });
}

@override
void initState() {
  super.initState();

  _player.onDurationChanged.listen((d) {
    setState(() {
      audioDuration = d;
    });
  });

  _player.onPositionChanged.listen((p) {
    setState(() {
      currentPosition = p;
    });
  });

  _player.onPlayerComplete.listen((event) {
    setState(() {
      isPlaying = false;
      currentPosition = Duration.zero;
    });
  });
}

  @override
  void dispose() {
    _recordTimer?.cancel();

_player.dispose();

_recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            context.pop();
          },
        ),
        title: const Text(
          "Live Voice Recording",
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(

          children: [

            const SizedBox(height: 40),

            Icon(
              isRecording
                  ? Icons.mic
                  : Icons.keyboard_voice,
              size: 100,
              color:
              isRecording
                  ? Colors.red
                  : Colors.deepPurple,
            ),

            const SizedBox(height: 20),

            Text(
              isRecording
                  ? "Recording..."
                  : hasRecording
                  ? "Recording Completed"
                  : "Press Start",
                  
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isRecording)
  Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Text(
      "${recordingDuration.inMinutes.toString().padLeft(2, '0')}:"
      "${(recordingDuration.inSeconds % 60).toString().padLeft(2, '0')}",
      style: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Colors.red,
      ),
    ),
  ),
            const SizedBox(height: 40),

            if (!isRecording)

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(

                  icon: const Icon(Icons.mic),

                  label: const Text(
                    "Start Recording",
                  ),

                  onPressed: startRecording,

                ),
              ),

            if (isRecording)

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(

                  icon: const Icon(Icons.stop),

                  label: const Text(
                    "Stop Recording",
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),

                  onPressed: stopRecording,

                ),
              ),

            const SizedBox(height: 20),

            if (hasRecording)

  SizedBox(
    width: double.infinity,
    height: 55,
    child: ElevatedButton.icon(

      icon: Icon(
        isPlaying
            ? Icons.pause
            : Icons.play_arrow,
      ),

      label: Text(
        isPlaying
            ? "Pause"
            : "Play Recording",
      ),

      onPressed: playRecording,

    ),
  ),

if (hasRecording)

  Column(

    children: [

      Slider(

        value: currentPosition.inSeconds.toDouble(),

        min: 0,

        max: audioDuration.inSeconds == 0
            ? 1
            : audioDuration.inSeconds.toDouble(),

        onChanged: (value) async {

          await _player.seek(
            Duration(seconds: value.toInt()),
          );

        },

      ),

      Row(

        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [

          Text(

            "${currentPosition.inMinutes.toString().padLeft(2, '0')}:"
            "${(currentPosition.inSeconds % 60).toString().padLeft(2, '0')}",

          ),

          Text(

            "${audioDuration.inMinutes.toString().padLeft(2, '0')}:"
            "${(audioDuration.inSeconds % 60).toString().padLeft(2, '0')}",

          ),

        ],

      ),

    ],

  ),

            const SizedBox(height: 20),

            if (hasRecording)

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(

                  icon: const Icon(Icons.check),

                  label: const Text(
                    "Use Recording",
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),

                  onPressed: () async {

  if (audioPath == null) return;

  final file = File(audioPath!);

  final platformFile = PlatformFile(
    name: file.path.split('/').last,
    path: file.path,
    size: await file.length(),
  );

  ref
      .read(analysisProvider.notifier)
      .setAudioFile(platformFile);

  // context.push(
  //   AppRoutes.aiProcessing,
  // );
  context.pop();

  // Future.microtask(() {
  //   ref
  //       .read(analysisProvider.notifier)
  //       .runAnalysis();
  // });

},

                ),
              ),

          ],
        ),
      ),
    );
  }
}