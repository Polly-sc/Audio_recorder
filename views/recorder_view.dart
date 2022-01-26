import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class RecorderView extends StatefulWidget {
  final Function onSaved;

  const RecorderView({Key? key, required this.onSaved}) : super(key: key);
  @override
  _RecorderViewState createState() => _RecorderViewState();
}

enum RecordingState {
  UnSet,
  Set,
  Recording,
  Stopped,
}

class _RecorderViewState extends State<RecorderView> {
  IconData _recordIcon = Icons.mic_none;
  String _recordText = 'Click To Start';
  RecordingState _recordingState = RecordingState.UnSet;
  String _filePath = '';

  // Recorder properties
  late FlutterSoundRecorder audioRecorder;

  @override
  void initState() {
    super.initState();

    final hasPermission = Permission.microphone.request();
    if (hasPermission == PermissionStatus.granted) {
      _recordingState = RecordingState.Set;
      _recordIcon = Icons.mic;
      _recordText = 'Record';
    }
  }

    @override
    void dispose() {
      _recordingState = RecordingState.UnSet;
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return Stack(
        alignment: Alignment.center,
        children: [
          MaterialButton(
            onPressed: () async {
              await _onRecordButtonPressed();
              setState(() {});
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            child: Container(
              width: 150,
              height: 150,
              child: Icon(
                _recordIcon,
                size: 50,
              ),
            ),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                child: Text(_recordText),
                padding: const EdgeInsets.all(8),
              ))
        ],
      );
    }

    Future<void> _onRecordButtonPressed() async {
      switch (_recordingState) {
        case RecordingState.Set:
          await _recordVoice();
          break;

        case RecordingState.Recording:
          await _stopRecording();
          _recordingState = RecordingState.Stopped;
          _recordIcon = Icons.fiber_manual_record;
          _recordText = 'Record new one';
          break;

        case RecordingState.Stopped:
          await _recordVoice();
          break;

        case RecordingState.UnSet:
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Camera Permission'),
                    content: Text(
                        'This app needs microphone access to take records'),
                    actions: <Widget>[
                      CupertinoDialogAction(
                        child: Text('Deny'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      CupertinoDialogAction(
                        child: Text('Settings'),
                        onPressed: () => openAppSettings(),
                      ),
                    ],
                  ),
            );

           ScaffoldMessenger.of(context).hideCurrentSnackBar();

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Please allow recording from settings.'),
          ));
          break;
      }
    }

  // void showMySimpleDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) => CupertinoAlertDialog(
  //       title: Text('Camera Permission'),
  //       content: Text(
  //           'This app needs camera access to take pictures for upload user profile photo'),
  //       actions: <Widget>[
  //         CupertinoDialogAction(
  //           child: Text('Deny'),
  //           onPressed: () => Navigator.of(context).pop(),
  //         ),
  //         CupertinoDialogAction(
  //           child: Text('Settings'),
  //           onPressed: () => openAppSettings(),
  //         ),
  //       ],
  //     ),
  //   );
  // }

    _initRecorder() async {
      Directory appDirectory = await getApplicationDocumentsDirectory();
      String _filePath = appDirectory.path +
          '/' +
          DateTime
              .now()
              .millisecondsSinceEpoch
              .toString() +
          '.aac';

      // audioRecorder =
      //     FlutterSoundRecorder(filePath, audioFormat: AudioFormat.AAC);
      // await audioRecorder.initialized;
    }

    _startRecording() async {
      await audioRecorder.startRecorder(toFile: _filePath);
      // await audioRecorder.current(channel: 0);
    }

    _stopRecording() async {
      await audioRecorder.stopRecorder();

      widget.onSaved();
    }

    Future<void> _recordVoice() async {
      final hasPermission = Permission.microphone.request();
      if (hasPermission != PermissionStatus.granted) {
        await _initRecorder();

        await _startRecording();
        _recordingState = RecordingState.Recording;
        _recordIcon = Icons.stop;
        _recordText = 'Recording';
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please allow recording from settings.'),
        ));
      }
    }
}
