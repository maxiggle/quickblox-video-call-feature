part of 'call_bloc.dart';

@immutable
class CallState extends Equatable {
  const CallState({this.sessionId = ''});

  final String sessionId;

  @override
  List<Object> get props => [sessionId];

  CallState copyWith({
    String? sessionId,
  }) {
    return CallState(
      sessionId: sessionId ?? this.sessionId,
    );
  }
}
