import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:quickblox_sdk/webrtc/rtc_video_view.dart';
import 'package:quickblox_video/app/app.dart';

part 'call_event.dart';
part 'call_state.dart';

class CallBloc extends Bloc<CallEvent, CallState> {
  CallBloc({
    QuickbloxService? quickbloxService,
    NavigationService? navigationService,
  })  : _quickbloxService = quickbloxService ?? QuickbloxService(),
        _navigationService = navigationService ?? NavigationService(),
        super(const CallState()) {
    on<CallUpdateSessionId>(_onUpdateSessionId);
    on<CallUpdateController>(_onUpdateController);
  }

  final QuickbloxService _quickbloxService;
  final NavigationService _navigationService;

  FutureOr<void> _onUpdateSessionId(
    CallUpdateSessionId event,
    Emitter<CallState> emit,
  ) {
    emit(state.copyWith(sessionId: event.sessionId));
  }

  FutureOr<void> _onUpdateController(
    CallUpdateController event,
    Emitter<CallState> emit,
  ) async {
    final sessionId = _navigationService.args as String;

    // initialize _remoteVideoViewController in video screen
    // subscribe to _quickbloxService.subscribeVideoTrack();
    // enable audio & video
    _quickbloxService.onRemoteVideoViewCreated(event.controller);
    await _quickbloxService.subscribeVideoTrack(sessionId);
    await _quickbloxService.enableVideoAndAudio(sessionId);
  }
}
