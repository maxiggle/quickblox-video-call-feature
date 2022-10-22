part of 'select_user_bloc.dart';

@immutable
class SelectUserState extends Equatable {
  const SelectUserState({
    this.users = const [],
    this.isLoading = false,
    this.callState = CallState.none,
    this.callSession,
  });

  final List<QBUser?> users;
  final bool isLoading;
  final CallState callState;
  final QBRTCSession? callSession;

  @override
  List<Object?> get props => [users, isLoading, callState, callSession];

  SelectUserState copyWith({
    List<QBUser?>? users,
    bool? isLoading,
    CallState? callState,
    QBRTCSession? callSession,
  }) {
    return SelectUserState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      callState: callState ?? this.callState,
      callSession: callSession ?? this.callSession,
    );
  }
}

enum CallState { none, makingCall, receivingCall }
