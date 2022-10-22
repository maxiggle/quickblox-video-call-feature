import 'dart:async';
import 'dart:developer';

import 'package:quickblox_sdk/models/qb_rtc_session.dart';
import 'package:quickblox_sdk/models/qb_session.dart';
import 'package:quickblox_sdk/models/qb_user.dart';
import 'package:quickblox_sdk/quickblox_sdk.dart';
import 'package:quickblox_sdk/webrtc/constants.dart';

import '../constants/constants.dart';

class QuickbloxService {
  static final QuickbloxService _instance = QuickbloxService._internal();

  factory QuickbloxService() {
    return _instance;
  }

  QuickbloxService._internal();

  Future<void> init() async {
    try {
      await QB.settings.init(
        APPLICATION_ID,
        AUTH_KEY,
        AUTH_SECRET,
        ACCOUNT_KEY,
      );
    } catch (e, s) {
      // Some error occurred, look at the exception message for more details
      log('QuickbloxService init failed:', error: e, stackTrace: s);
    }
  }

  Future<QBSession?> getSession() async {
    try {
      final session = await QB.auth.getSession();
      return session;
    } catch (e, s) {
      // Some error occurred, look at the exception message for more details
      log('QuickbloxService getSession failed:', error: e, stackTrace: s);
      return null;
    }
  }

  Future<QBUser?> login({
    required String login,
    required String password,
  }) async {
    try {
      final result = await QB.auth.login(login, password);
      await QB.chat.connect(result.qbUser?.id ?? 0, password);

      return result.qbUser;
    } catch (e, s) {
      // Some error occurred, look at the exception message for more details
      log('QuickbloxService login failed:', error: e, stackTrace: s);
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await QB.chat.disconnect();
      await QB.auth.logout();
    } catch (e, s) {
      // Some error occurred, look at the exception message for more details
      log('QuickbloxService login failed:', error: e, stackTrace: s);
    }
  }

  Future<void> initializeWebRTC() async {
    try {
      await QB.webrtc.init();
    } catch (e, s) {
      // Some error occurred, look at the exception message for more details
      log('QuickbloxService initializeWebRTC failed:', error: e, stackTrace: s);
    }
  }

  StreamSubscription? _callSubscription;

  // WebRTC Events
  // QBRTCEventTypes.CALL
  // QBRTCEventTypes.CALL_END
  // QBRTCEventTypes.NOT_ANSWER
  // QBRTCEventTypes.REJECT
  // QBRTCEventTypes.ACCEPT
  // QBRTCEventTypes.HANG_UP
  // QBRTCEventTypes.RECEIVED_VIDEO_TRACK
  Future<void> subscribeRTCEvent(String event) async {
    try {
      _callSubscription = await QB.webrtc.subscribeRTCEvent(
        event,
        (data) {
          log('Payload incoming');
          final payloadMap = Map<dynamic, dynamic>.from(data["payload"]);
          final sessionMap = Map<dynamic, dynamic>.from(payloadMap["session"]);

          String sessionId = sessionMap["id"];
          int initiatorId = sessionMap["initiatorId"];
          int callType = sessionMap["type"];
          print(payloadMap);
        },
        onErrorMethod: (e) {
          log('error');
        },
      );
    } catch (e, s) {
      // Some error occurred, look at the exception message for more details
      log(
        'QuickbloxService subscribeRTCEvent failed:',
        error: e,
        stackTrace: s,
      );
    }
  }

  void dispose() {
    if (_callSubscription != null) {
      _callSubscription!.cancel();
      _callSubscription = null;
    }
  }

  // Session types
  // QBRTCSessionTypes.VIDEO
  // QBRTCSessionTypes.AUDIO
  Future<QBRTCSession?> initiateCall(List<int> opponentIds) async {
    try {
      final session = await QB.webrtc.call(
        opponentIds,
        QBRTCSessionTypes.VIDEO,
      );
      return session;
    } catch (e, s) {
      // Some error occurred, look at the exception message for more details
      log('QuickbloxService initiateCall failed:', error: e, stackTrace: s);
      return null;
    }
  }

  Future<QBRTCSession?> acceptCall(
    String sessionId,
    Map<String, Object> userInfo,
  ) async {
    try {
      final session = await QB.webrtc.accept(sessionId, userInfo: userInfo);
      return session;
    } catch (e, s) {
      // Some error occurred, look at the exception message for more details
      log('QuickbloxService acceptCall failed:', error: e, stackTrace: s);
      return null;
    }
  }

  Future<QBRTCSession?> rejectCall(
    String sessionId,
    Map<String, Object> userInfo,
  ) async {
    try {
      final session = await QB.webrtc.reject(sessionId, userInfo: userInfo);
      return session;
    } catch (e, s) {
      // Some error occurred, look at the exception message for more details
      log('QuickbloxService rejectCall failed:', error: e, stackTrace: s);
      return null;
    }
  }

  Future<QBRTCSession?> endCall(
    String sessionId, {
    Map<String, Object>? userInfo,
  }) async {
    try {
      final session = await QB.webrtc.hangUp(sessionId, userInfo: userInfo);
      return session;
    } catch (e, s) {
      // Some error occurred, look at the exception message for more details
      log('QuickbloxService endCall failed:', error: e, stackTrace: s);
      return null;
    }
  }

  Future<List<QBUser?>?> getUsers() async {
    try {
      final userList = await QB.users.getUsers();
      return userList;
    } catch (e, s) {
      // Some error occurred, look at the exception message for more details
      log('QuickbloxService getUsers failed:', error: e, stackTrace: s);
      return null;
    }
  }
}
