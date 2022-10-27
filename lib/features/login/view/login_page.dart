import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickblox_video/features/login/cubit/login_cubit.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<LoginCubit, bool>(
      (_) => _.state.isLoading,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Text(
                'Enter your login and password',
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 64),
              TextFormField(
                decoration: const InputDecoration(hintText: 'Login'),
                onChanged: (val) {
                  context.read<LoginCubit>().onLoginUpdated(val);
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 32),
              TextFormField(
                decoration: const InputDecoration(hintText: 'Password'),
                onChanged: (val) {
                  context.read<LoginCubit>().onPasswordUpdated(val);
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed:
                    isLoading ? null : context.read<LoginCubit>().onLogin,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Login'),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).errorColor,
                ),
                onPressed:
                    isLoading ? null : context.read<LoginCubit>().onLogout,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
