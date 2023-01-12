import 'package:permission_handler/permission_handler.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:flutter/material.dart';

class Preview extends StatefulWidget {
  const Preview({super.key});

  @override
  State<Preview> createState() => _PreviewState();
}

class _PreviewState extends State<Preview> {
  late ZegoEngineProfile profile;
  ZegoUser user = ZegoUser("1920", "Fred");
  late Widget? playViewWidget;
  late int? playViewID;
  String streamId = "1";
  bool isLoading = true;
  late ZegoCanvas canvas;
  @override
  void initState() {
    _startTeleconsult().then((_) {
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            body: playViewWidget,
          );
  }

  startPublishingStream() async {
    await ZegoExpressEngine.instance.startPublishingStream(streamId);
  }

  _startTeleconsult() async {
    await requestPermissions();
    await startRoom();
    await startPublishingStream();
    await feedBack();
    await startPreview();
    await startPlayStream();
  }

  feedBack() async {
    // Stream status update callback
    ZegoExpressEngine.onRoomStreamUpdate = (String roomID,
        ZegoUpdateType updateType,
        List<ZegoStream> streamList,
        Map<String, dynamic> map) {
      print('👉$streamList');
      // Implement the event callback as required.
    };
  }

  startPlayStream() async {
    await ZegoExpressEngine.instance.startPlayingStream(streamId);
  }

  startPreview() async {
    playViewWidget =
        await ZegoExpressEngine.instance.createCanvasView((viewID) {
      print("👉$viewID");
      playViewID = viewID;

      // Set the playing canvas.
      canvas = ZegoCanvas.view(viewID);

      // Start playing.
      ZegoExpressEngine.instance.startPlayingStream('1', canvas: canvas);
    });
  }

  startRoom() async {
    profile = ZegoEngineProfile(
      319827890,
      ZegoScenario.StandardVideoCall,
      appSign:
          "3145561c2977a59ab654d9a42a5d5c71605bda3871828a8d1f4c3eb3e2b727e4",
      enablePlatformView: false,
    );
    await ZegoExpressEngine.createEngineWithProfile(profile);
    ZegoRoomConfig config = ZegoRoomConfig.defaultConfig();
    await ZegoExpressEngine.instance.loginRoom('room1', user, config: config);
  }

  requestPermissions() async {
    await [Permission.camera, Permission.microphone].request();
  }
}
