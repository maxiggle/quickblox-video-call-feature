import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickblox_video/features/call/call.dart';
import 'package:quickblox_video/features/login/login.dart';
import 'package:quickblox_video/features/select_user/select_user.dart';
import 'package:quickblox_video/features/splash/splash.dart';

import '../router/router.dart' as router;
import '../services/services.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return MultiBlocProvider(
      providers: [
        BlocProvider<CallBloc>(create: (_) => CallBloc()),
        BlocProvider<LoginCubit>(create: (_) => LoginCubit()),
        BlocProvider<SelectUserBloc>(
          create: (_) => SelectUserBloc()..add(const SelectUserFetchUsers()),
        ),
        BlocProvider<SplashCubit>(create: (_) => SplashCubit()),
      ],
      child: MaterialApp(
        title: 'P2P Video',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          textTheme:
              Theme.of(context).textTheme.apply(bodyColor: Colors.black87),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.blue,
            accentColor: Colors.blue,
          ),
        ),
        navigatorKey: NavigationService().navigatorKey,
        onGenerateRoute: router.generateRoute,
        initialRoute: router.SplashRoute,
      ),
    );
  }
}
