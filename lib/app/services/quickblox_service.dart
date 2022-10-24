import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:quickblox_sdk/models/qb_rtc_session.dart';
import 'package:quickblox_sdk/models/qb_session.dart';
import 'package:quickblox_sdk/models/qb_user.dart';
import 'package:quickblox_sdk/quickblox_sdk.dart';
import 'package:quickblox_sdk/webrtc/constants.dart';
import 'package:quickblox_sdk/webrtc/rtc_video_view.dart';
import 'package:quickblox_video/app/app.dart';
import 'package:quickblox_video/features/select_user/widgets/receive_call_dialog.dart';

class QuickbloxService {
  static final QuickbloxService _instance = QuickbloxService._internal();

  factory QuickbloxService() {
    return _instance;
  }

  QuickbloxService._internal();

  final _navigationService = NavigationService();
  QBUser? qbUser;

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

      qbUser = result.qbUser;

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
    String sessionId, {
    Map<String, Object>? userInfo,
  }) async {
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
    String sessionId, {
    Map<String, Object>? userInfo,
  }) async {
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

  Future<void> enableVideoAndAudio(String sessionId) async {
    try {
      await QB.webrtc.enableAudio(
        sessionId,
        userId: qbUser?.id?.toDouble() ?? 0.0,
      );
      await QB.webrtc.enableVideo(
        sessionId,
        userId: qbUser?.id?.toDouble() ?? 0.0,
      );
    } catch (e, s) {
      // Some error occurred, look at the exception message for more details
      log(
        'QuickbloxService enableVideoAndAudio failed:',
        error: e,
        stackTrace: s,
      );
    }
  }

  StreamSubscription? _callSubscription;
  StreamSubscription? _callEndSubscription;
  StreamSubscription? _rejectSubscription;
  StreamSubscription? _acceptSubscription;
  StreamSubscription? _hangUpSubscription;
  StreamSubscription? _videoTrackSubscription;
  StreamSubscription? _notAnswerSubscription;
  StreamSubscription? _peerConnectionSubscription;

  RTCVideoViewController? _remoteVideoViewController;

  RTCVideoViewController? get remoteVideoViewController {
    return _remoteVideoViewController;
  }

  Future<void> subscribeCall() async {
    if (_callSubscription != null) {
      log("You already have a subscription for: ${QBRTCEventTypes.CALL}");
      return;
    }

    try {
      _callSubscription =
          await QB.webrtc.subscribeRTCEvent(QBRTCEventTypes.CALL, (data) {
        final payloadMap = Map<dynamic, dynamic>.from(data["payload"]);
        final sessionMap = Map<dynamic, dynamic>.from(payloadMap["session"]);

        String sessionId = sessionMap["id"];
        int initiatorId = sessionMap["initiatorId"];

        // show accept call dialog
        final context = _navigationService.navigatorKey.currentContext;
        if (context != null) {
          showDialog(
            context: context,
            builder: (context) => ReceiveCallDialog(
              initiatorId: initiatorId,
              sessionId: sessionId,
            ),
          );
        }
      }, onErrorMethod: (error) {
        log('subscribeCall error: $error');
      });
      log("Subscribed: ${QBRTCEventTypes.CALL}");
    } catch (e) {
      log('subscribeCall error: $e');
    }
  }

  Future<void> subscribeCallEnd() async {
    if (_callEndSubscription != null) {
      log("You already have a subscription for: ${QBRTCEventTypes.CALL_END}");
      return;
    }
    try {
      _callEndSubscription =
          await QB.webrtc.subscribeRTCEvent(QBRTCEventTypes.CALL_END, (data) {
        final payloadMap = Map<dynamic, dynamic>.from(data["payload"]);
        final sessionMap = Map<dynamic, dynamic>.from(payloadMap["session"]);

        String sessionId = sessionMap["id"];

        log("The call with sessionId $sessionId was ended");
      }, onErrorMethod: (error) {
        log('subscribeCallEnd error: $error');
      });
      log("Subscribed: ${QBRTCEventTypes.CALL_END}");
    } catch (e) {
      log('subscribeCallEnd error: $e');
    }
  }

  Future<void> subscribeVideoTrack(String sessionId) async {
    if (_videoTrackSubscription != null) {
      log("You already have a subscription for:${QBRTCEventTypes.RECEIVED_VIDEO_TRACK}");
      return;
    }

    try {
      _videoTrackSubscription = await QB.webrtc
          .subscribeRTCEvent(QBRTCEventTypes.RECEIVED_VIDEO_TRACK, (data) {
        final payloadMap = Map<dynamic, dynamic>.from(data["payload"]);
        int opponentId = payloadMap["userId"];

        startRenderingRemote(opponentId, sessionId);
      }, onErrorMethod: (error) {
        log('subscribeVideoTrack error: $error');
      });
      log("Subscribed: ${QBRTCEventTypes.RECEIVED_VIDEO_TRACK}");
    } catch (e) {
      log('subscribeVideoTrack error: $e');
    }
  }

  void onRemoteVideoViewCreated(RTCVideoViewController controller) {
    _remoteVideoViewController = controller;
  }

  Future<void> startRenderingRemote(int opponentId, String sessionId) async {
    try {
      await _remoteVideoViewController!.play(sessionId, opponentId);
    } catch (e) {
      log('startRenderingRemote error: $e');
    }
  }

  Future<void> subscribeNotAnswer() async {
    if (_notAnswerSubscription != null) {
      log("You already have a subscription for: ${QBRTCEventTypes.NOT_ANSWER}");
      return;
    }

    try {
      _notAnswerSubscription =
          await QB.webrtc.subscribeRTCEvent(QBRTCEventTypes.NOT_ANSWER, (data) {
        int userId = data["payload"]["userId"];
        // show not answer dialog
        final context = _navigationService.navigatorKey.currentContext;
        if (context != null) {
          showAboutDialog(context: context);
        }
      }, onErrorMethod: (error) {
        log('subscribeNotAnswer error: $error');
      });
      log("Subscribed: ${QBRTCEventTypes.NOT_ANSWER}");
    } catch (e) {
      log('subscribeNotAnswer error: $e');
    }
  }

  Future<void> subscribeReject() async {
    if (_rejectSubscription != null) {
      log("You already have a subscription for: ${QBRTCEventTypes.REJECT}");
      return;
    }

    try {
      _rejectSubscription =
          await QB.webrtc.subscribeRTCEvent(QBRTCEventTypes.REJECT, (data) {
        int userId = data["payload"]["userId"];
        // show reject call dialog
        final context = _navigationService.navigatorKey.currentContext;
        if (context != null) {
          showAboutDialog(context: context);
        }
      }, onErrorMethod: (error) {
        log('subscribeReject error: $error');
      });
      log("Subscribed: ${QBRTCEventTypes.REJECT}");
    } catch (e) {
      log('subscribeReject error: $e');
    }
  }

  Future<void> subscribeAccept(void Function(String?)? onAccept) async {
    if (_acceptSubscription != null) {
      log("You already have a subscription for: ${QBRTCEventTypes.ACCEPT}");
      return;
    }

    try {
      _acceptSubscription =
          await QB.webrtc.subscribeRTCEvent(QBRTCEventTypes.ACCEPT, (data) {
        final payloadMap = Map<dynamic, dynamic>.from(data["payload"]);
        final sessionMap = Map<dynamic, dynamic>.from(payloadMap["session"]);

        String sessionId = sessionMap["id"];

        int userId = data["payload"]["userId"];
        log("The user $userId was accepted your call");
        onAccept?.call(sessionId);
      }, onErrorMethod: (error) {
        log('subscribeAccept error: $error');
      });
      log("Subscribed: ${QBRTCEventTypes.ACCEPT}");
    } catch (e) {
      log('subscribeAccept error: $e');
    }
  }

  Future<void> subscribeHangUp() async {
    if (_hangUpSubscription != null) {
      log("You already have a subscription for: ${QBRTCEventTypes.HANG_UP}");
      return;
    }

    try {
      _hangUpSubscription =
          await QB.webrtc.subscribeRTCEvent(QBRTCEventTypes.HANG_UP, (data) {
        int userId = data["payload"]["userId"];
        // show user hanged up dialog
        final context = _navigationService.navigatorKey.currentContext;
        if (context != null) {
          showAboutDialog(context: context);
        }
      }, onErrorMethod: (error) {
        log('subscribeHangUp error: $error');
      });
      log("Subscribed: ${QBRTCEventTypes.HANG_UP}");
    } catch (e) {
      log('subscribeHangUp error: $e');
    }
  }

  Future<void> subscribePeerConnection() async {
    if (_peerConnectionSubscription != null) {
      log("You already have a subscription for: ${QBRTCEventTypes.PEER_CONNECTION_STATE_CHANGED}");
      return;
    }

    try {
      _peerConnectionSubscription = await QB.webrtc.subscribeRTCEvent(
          QBRTCEventTypes.PEER_CONNECTION_STATE_CHANGED, (data) {
        int state = data["payload"]["state"];
        String parsedState = parseState(state);
        log("PeerConnection state: $parsedState");
      }, onErrorMethod: (error) {
        log('subscribePeerConnection error: $error');
      });
      log("Subscribed: ${QBRTCEventTypes.PEER_CONNECTION_STATE_CHANGED}");
    } catch (e) {
      log('subscribePeerConnection error: $e');
    }
  }

  String parseState(int state) {
    String parsedState = "";

    switch (state) {
      case QBRTCPeerConnectionStates.NEW:
        parsedState = "NEW";
        break;
      case QBRTCPeerConnectionStates.FAILED:
        parsedState = "FAILED";
        break;
      case QBRTCPeerConnectionStates.DISCONNECTED:
        parsedState = "DISCONNECTED";
        break;
      case QBRTCPeerConnectionStates.CLOSED:
        parsedState = "CLOSED";
        break;
      case QBRTCPeerConnectionStates.CONNECTED:
        parsedState = "CONNECTED";
        break;
    }

    return parsedState;
  }

  void dispose() {
    if (_callSubscription != null) {
      _callSubscription!.cancel();
      _callSubscription = null;
    }
  }
}
