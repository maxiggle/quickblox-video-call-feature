import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:quickblox_sdk/models/qb_rtc_session.dart';
import 'package:quickblox_sdk/models/qb_user.dart';
import 'package:quickblox_video/app/app.dart';

part 'select_user_event.dart';
part 'select_user_state.dart';

class SelectUserBloc extends Bloc<SelectUserEvent, SelectUserState> {
  SelectUserBloc({
    QuickbloxService? quickbloxService,
    NavigationService? navigationService,
  })  : _quickbloxService = quickbloxService ?? QuickbloxService(),
        _navigationService = navigationService ?? NavigationService(),
        super(const SelectUserState()) {
    on<SelectUserFetchUsers>(_onFetchUsers);
    on<SelectUserCallUser>(_onCallUser);
    on<SelectUserEndCall>(_onEndCall);
    on<SelectUserUpdateCallState>(_onUpdateCallState);
    on<SelectUserAcceptCall>(_onAcceptCall);
    on<SelectUserRejectCall>(_onRejectCall);
  }

  final QuickbloxService _quickbloxService;
  final NavigationService _navigationService;

  FutureOr<void> _onFetchUsers(
    SelectUserFetchUsers event,
    Emitter<SelectUserState> emit,
  ) async {
    await _quickbloxService.initializeWebRTC();

    await _quickbloxService.subscribeCall();
    await _quickbloxService.subscribeCallEnd();
    await _quickbloxService.subscribeReject();
    await _quickbloxService.subscribeAccept(_onAccept);
    await _quickbloxService.subscribeHangUp();
    // _quickbloxService.subscribeVideoTrack();
    await _quickbloxService.subscribeNotAnswer();
    await _quickbloxService.subscribePeerConnection();

    emit(state.copyWith(isLoading: true));
    final response = await _quickbloxService.getUsers();
    emit(state.copyWith(isLoading: false));

    // if failed
    if (response == null) return;

    emit(state.copyWith(users: response));
  }

  Future<void> _onAccept(String? sessionId) async {
    _navigationService.pop();
    // go to video screen with session id
    await _navigationService.pushNamed(
      CallRoute,
      args: sessionId ?? '',
    );

    add(const SelectUserEndCall());
  }

  FutureOr<void> _onCallUser(
    SelectUserCallUser event,
    Emitter<SelectUserState> emit,
  ) async {
    final userId = event.user?.id ?? 0;

    emit(state.copyWith(isLoading: true));
    final response = await _quickbloxService.initiateCall([userId]);
    emit(
      state.copyWith(
        isLoading: false,
        callSession: response,
        callState: CallState.makingCall,
      ),
    );
  }

  FutureOr<void> _onEndCall(
    SelectUserEndCall event,
    Emitter<SelectUserState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
    ));
    final response = await _quickbloxService.endCall(
      state.callSession?.id ?? '',
    );
    emit(
      state.copyWith(
        isLoading: false,
        callSession: response,
        callState: CallState.none,
      ),
    );

    _navigationService.pop();
  }

  FutureOr<void> _onUpdateCallState(
    SelectUserUpdateCallState event,
    Emitter<SelectUserState> emit,
  ) {
    emit(state.copyWith(callState: event.callState));
  }

  FutureOr<void> _onAcceptCall(
    SelectUserAcceptCall event,
    Emitter<SelectUserState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final response = await _quickbloxService.acceptCall(event.sessionId);
    emit(state.copyWith(isLoading: false, callSession: response));

    _navigationService.pop();
    // go to video screen with session id
    _navigationService.pushNamed(CallRoute, args: response?.id ?? '');
  }

  FutureOr<void> _onRejectCall(
    SelectUserRejectCall event,
    Emitter<SelectUserState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final response = await _quickbloxService.rejectCall(event.sessionId);
    emit(state.copyWith(isLoading: false, callSession: response));

    _navigationService.pop();
  }
}
