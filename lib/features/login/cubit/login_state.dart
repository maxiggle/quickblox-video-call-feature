part of 'login_cubit.dart';

@immutable
class LoginState extends Equatable {
  const LoginState({
    this.login = '',
    this.password = '',
    this.isLoading = false,
  });

  final String login;
  final String password;
  final bool isLoading;

  @override
  List<Object> get props => [login, password, isLoading];

  LoginState copyWith({
    String? login,
    String? password,
    bool? isLoading,
  }) {
    return LoginState(
      login: login ?? this.login,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
