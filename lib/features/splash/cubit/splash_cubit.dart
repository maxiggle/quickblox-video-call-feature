import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:quickblox_video/app/router/router.dart' as router;
import 'package:quickblox_video/app/services/services.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit({
    NavigationService? navigationService,
    QuickbloxService? quickbloxService,
  })  : _navigationService = navigationService ?? NavigationService(),
        _quickbloxService = quickbloxService ?? QuickbloxService(),
        super(SplashInitial());

  final NavigationService _navigationService;
  final QuickbloxService _quickbloxService;

  Future<void> navigateToLogin() async {
    // init quickblox
    await _quickbloxService.init();

    _navigationService.pushReplacementNamed(router.LoginRoute);
  }
}
