import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickblox_sdk/webrtc/rtc_video_view.dart';

import '../bloc/call_bloc.dart';

class CallPage extends StatelessWidget {
  const CallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video')),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
          width: MediaQuery.of(context).size.width,
          height: 200.0,
          decoration: const BoxDecoration(color: Colors.black54),
          child: RTCVideoView(
            onVideoViewCreated: (controller) {
              context.read<CallBloc>().add(CallUpdateController(controller));
            },
          ),
        ),
      ),
    );
  }
}
