import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:quickblox_video/app/app.dart';
import 'package:quickblox_video/app/router/router.dart' as router;

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({
    NavigationService? navigationService,
    QuickbloxService? quickbloxService,
  })  : _navigationService = navigationService ?? NavigationService(),
        _quickbloxService = quickbloxService ?? QuickbloxService(),
        super(const LoginState());

  final NavigationService _navigationService;
  final QuickbloxService _quickbloxService;

  void onLoginUpdated(String login) {
    emit(state.copyWith(login: login));
  }

  void onPasswordUpdated(String password) {
    emit(state.copyWith(password: password));
  }

  Future<void> onLogin() async {
    // set state to loading while we try to login
    emit(state.copyWith(isLoading: true));
    // perform request
    final response = await _quickbloxService.login(
      login: state.login,
      password: state.password,
    );
    // set state to not loading, request have finish
    emit(state.copyWith(isLoading: false));

    // if login failed
    if (response == null) return;

    // if login succeeded
    _navigationService.pushReplacementNamed(router.SelectUserRoute);
  }

  Future<void> onLogout() async {
    emit(state.copyWith(isLoading: true));
    await _quickbloxService.logout();
    emit(state.copyWith(isLoading: false));
  }
}
