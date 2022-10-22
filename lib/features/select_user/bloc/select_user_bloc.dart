import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:quickblox_sdk/models/qb_rtc_session.dart';
import 'package:quickblox_sdk/models/qb_user.dart';
import 'package:quickblox_sdk/webrtc/constants.dart';
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
  }

  final QuickbloxService _quickbloxService;
  final NavigationService _navigationService;

  FutureOr<void> _onFetchUsers(
    SelectUserFetchUsers event,
    Emitter<SelectUserState> emit,
  ) async {
    await _quickbloxService.subscribeRTCEvent(QBRTCEventTypes.CALL);

    emit(state.copyWith(isLoading: true));
    final response = await _quickbloxService.getUsers();
    emit(state.copyWith(isLoading: false));

    // if failed
    if (response == null) return;

    emit(state.copyWith(users: response));
  }

  FutureOr<void> _onCallUser(
    SelectUserCallUser event,
    Emitter<SelectUserState> emit,
  ) async {
    final userId = event.user?.id ?? 0;

    emit(state.copyWith(isLoading: true));
    await _quickbloxService.initializeWebRTC();
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
}
