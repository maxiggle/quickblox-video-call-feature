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

class SelectUserUpdateCallState extends SelectUserEvent {
  const SelectUserUpdateCallState(this.callState);

  final CallState callState;

  @override
  List<Object?> get props => [callState];
}
