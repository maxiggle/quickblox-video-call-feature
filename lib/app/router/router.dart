// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:quickblox_video/features/call/call.dart';
import 'package:quickblox_video/features/login/login.dart';
import 'package:quickblox_video/features/select_user/select_user.dart';
import 'package:quickblox_video/features/splash/splash.dart';

/// Created by Injoit in 2021.
/// Copyright © 2021 Quickblox. All rights reserved.

const String SplashRoute = '/';
const String LoginRoute = 'login';
const String CallRoute = 'call';
const String SelectUserRoute = 'select-user';

Route<dynamic>? generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case SplashRoute:
      return MaterialPageRoute(builder: (context) => const SplashPage());
    case LoginRoute:
      return MaterialPageRoute(builder: (context) => const LoginPage());
    case CallRoute:
      return MaterialPageRoute(builder: (context) => const CallPage());
    case SelectUserRoute:
      return MaterialPageRoute(builder: (context) => const SelectUserPage());
    default:
      return MaterialPageRoute(builder: (context) => const LoginPage());
  }
}
