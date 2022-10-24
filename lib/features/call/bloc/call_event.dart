part of 'call_bloc.dart';

@immutable
abstract class CallEvent extends Equatable {
  const CallEvent();

  @override
  List<Object?> get props => [];
}

class CallUpdateSessionId extends CallEvent {
  const CallUpdateSessionId(this.sessionId);

  final String sessionId;

  @override
  List<Object?> get props => [sessionId];
}

class CallUpdateController extends CallEvent {
  const CallUpdateController(this.controller);

  final RTCVideoViewController controller;

  @override
  List<Object?> get props => [controller];
}
