part of 'select_user_bloc.dart';

@immutable
abstract class SelectUserEvent extends Equatable {
  const SelectUserEvent();

  @override
  List<Object?> get props => [];
}

class SelectUserFetchUsers extends SelectUserEvent {
  const SelectUserFetchUsers();
}

class SelectUserCallUser extends SelectUserEvent {
  const SelectUserCallUser(this.user);

  final QBUser? user;

  @override
  List<Object?> get props => [user];
}

class SelectUserEndCall extends SelectUserEvent {
  const SelectUserEndCall();
}

class SelectUserAcceptCall extends SelectUserEvent {
  const SelectUserAcceptCall(this.sessionId);

  final String sessionId;

  @override
  List<Object?> get props => [sessionId];
}

class SelectUserRejectCall extends SelectUserEvent {
  const SelectUserRejectCall(this.sessionId);

  final String sessionId;

  @override
  List<Object?> get props => [sessionId];
}

class SelectUserUpdateCallState extends SelectUserEvent {
  const SelectUserUpdateCallState(this.callState);

  final CallState callState;

  @override
  List<Object?> get props => [callState];
}
