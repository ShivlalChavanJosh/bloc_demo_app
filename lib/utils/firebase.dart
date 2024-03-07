import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sportskill/models/coach/player_list_response.dart';

import '../models/coach/batch_list_response.dart';
import '../models/coach/coach_login_response.dart';
import '../models/fcm_notification_response_model.dart';
import '../models/player/batch_list_response_mdel.dart';
import '../models/player/login_player_response_model.dart';
import '../view_models/notification_view_model.dart';
import '../views/pages/coach/coach_survey_questions.dart';
import '../views/pages/player/survey_questions.dart';
import 'helpers/APIHelper/shared_preference.dart';
import 'navigator/navigation_pages.dart';
import 'navigator/navigator.dart';

class FirebaseUtil {
  FirebaseUtil._private();

  static final FirebaseUtil _instance = FirebaseUtil._private();

  static FirebaseUtil get instance => _instance;

  static String? _fcmToken;

  static String? get fcmToken => _fcmToken;

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/app_icon');
  static final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
          onDidReceiveLocalNotification:
              _instance.onDidReceiveLocalNotification);
  static final InitializationSettings initializationSettings =
      InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS);

  static Future<void> init() async {
    // Init Firebase App
    //await Firebase.initializeApp();
    await Firebase.initializeApp(
        // options: DefaultFirebaseOptions.currentPlatform,
        );

    // Init FCM
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();

    if (Platform.isIOS) {
      // For exception ofApNS
      _fcmToken = await messaging.getAPNSToken();
    } else {
      _fcmToken = await messaging.getToken();
    }

    log('FCMToken: $_fcmToken');

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('FirebaseUtil: User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      log('FirebaseUtil: User granted provisional permission');
    } else {
      log('FirebaseUtil: User declined or has not accepted permission');
    }

    // Initialize the local notification plugin
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (
      id,
    ) async {
      _instance.onSelectNotification;
    });

    // Attaching Observers
    // When app is in foreground while notification arrived
    FirebaseMessaging.onMessage
        .listen((message) => _instance.onNotificationReceived(message));

    // When app was in background while notification arrived and then opened by clicking on notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      //_instance.onNotificationReceived(message, messageOpenedApp: true);
      _instance.handlePayloadData(jsonEncode(message.data));
    });
  }

  /*void _handleNotificationPayload(String? payload) {
    if (payload != null) {
      final Map<String, dynamic> processedPayload = jsonDecode(payload);
      final target = processedPayload['EVENT_NAME'];

      log('Notification target received: $target, while current route is ${IllumineNavigator.currentRoute}');

      switch (target) {
        case 'SESSION_START':
          switch (IllumineNavigator.currentRoute) {
            case NavigationPages.kActivityLog:
              ActivityLogViewModel.instance.onReloadDataRequested();
              break;

            case NavigationPages.kDashboard:
              DashboardViewModel.instance.onReloadDataRequested();
              break;

            case NavigationPages.kAssessmentScreen:
              AssesmentViewModel.instance.onReloadDataRequested();
              break;

            default:
              log("Notification target '$target' received while current route is '${IllumineNavigator.currentRoute}'");
              break;
          }
          break;

        case 'SESSION_END':
          switch (IllumineNavigator.currentRoute) {
            case NavigationPages.kActivityLog:
              ActivityLogViewModel.instance.onReloadDataRequested();
              break;

            case NavigationPages.kDashboard:
              DashboardViewModel.instance.onReloadDataRequested();
              break;

            case NavigationPages.kClassRoadmapScreen:
              ClassRoadmapViewModel.instance.onReloadDataRequested();
              break;

            default:
              log("Notification target '$target' received while current route is '${IllumineNavigator.currentRoute}'");
              break;
          }
          break;

        case 'ENGAGEMENT_CHANGE':
          switch (IllumineNavigator.currentRoute) {
            case NavigationPages.kAssessmentScreenForPoll:
              AssesmentViewModel.instance.onReloadDataRequested();
              break;

            case NavigationPages.kClassRoadmapScreen:
              ClassRoadmapViewModel.instance.onReloadDataRequested();
              break;

            default:
              log("Notification target '$target' received while current route is '${IllumineNavigator.currentRoute}'");
              break;
          }
          break;

        default:
          log("Unsupported: Notification target '$target' received while current route is '${IllumineNavigator.currentRoute}'");
          break;
      }
    }
  }*/

  Future<void> onNotificationReceived(RemoteMessage message,
      {bool messageOpenedApp = false}) async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    try {
      log('Notification Received: ${message.notification?.title ?? 'No Notification Title'}');
      if (message.data.isNotEmpty) {
        final dynamic payload = message.data;
        FcmNotificationResponseModel? fcmNotificationResponseModel =
            FcmNotificationResponseModel.fromJson(message.data);
        if (message.notification != null) {
          final bool showLocalNotification =
              fcmNotificationResponseModel.showLocalNotification ?? false;
          final bool processPayloadOnReceive =
              fcmNotificationResponseModel.processPayloadOnReceive ?? false;

          if (processPayloadOnReceive) {
            //handlePayloadData(payload);
          }

          if (!messageOpenedApp && message.notification != null) {
            final String localNotificationTitle =
                message.notification?.title ?? 'SportsSkill';
            final String localNotificationBody =
                message.notification?.body ?? '';
            final String localNotificationChannel =
                fcmNotificationResponseModel.channel ?? 'default_channel';
            final bool localNotificationSoundEnabled =
                fcmNotificationResponseModel.enableSound ?? true;
            final bool localNotificationVibrationEnabled =
                fcmNotificationResponseModel.enableVibration ?? true;

            _showLocalNotification(
                notificationId: message.notification.hashCode,
                title: localNotificationTitle,
                body: localNotificationBody,
                chanelId: channel.id, //localNotificationChannel,
                chanelName: channel.name, //localNotificationChannel,
                payload: message.data,
                soundEnabled: localNotificationSoundEnabled,
                vibrationEnabled: localNotificationVibrationEnabled);
          }
        } else {
          handlePayloadData(jsonEncode(payload));
        }
        log('Notification Data: ${message.data.toString()}');
      } else {
        log('Notification Error: Data object is empty');
      }
    } catch (e, stacktrace) {
      print("1${e.toString()} ${stacktrace.toString()}");
    }
  }

  ///[_showLocalNotification] sends local Push notification to the app
  Future<void> _showLocalNotification({
    required final int notificationId,
    required final String title,
    required final String chanelId,
    required final String chanelName,
    final Importance importance = Importance.defaultImportance,
    final Priority priority = Priority.defaultPriority,
    final String? body,
    final Map<String, dynamic>? payload,
    final bool soundEnabled = true,
    final bool vibrationEnabled = true,
  }) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      chanelId,
      chanelName,
      importance: importance,
      priority: priority,
      playSound: soundEnabled,
      enableVibration: vibrationEnabled,
    );
    final DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(presentSound: soundEnabled, subtitle: body);
    final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        notificationId, title, body, platformChannelSpecifics,
        payload: jsonEncode(payload));
  }

  void onSelectNotification(String? payload) async {
    print('Notification payload: $payload');

    handlePayloadData(payload ?? "{}");
  }

  handlePayloadData(String payload) async {
    print("handle notification");

    try {
      FcmNotificationResponseModel fcmNotificationResponseModel =
          FcmNotificationResponseModel.fromJson(jsonDecode(payload.toString()));
      CoachUserModel? coachUser = await SharedPref().getCoachUser();
      PlayerUserModel? playerUser = await SharedPref().getPlayerUser();
      await NotificationViewModel.instance.readNotification(
          notificationId:
              int.parse(fcmNotificationResponseModel.notificationId ?? "0"));
      if (fcmNotificationResponseModel.notificationType == "batch_assignment") {
        if (coachUser != null) {
          AppNavigator.instance.navigateTo(
              name: NavigationPages.coachBatchDetailScreen,
              arguments: BatchDetails(
                  id: int.parse(fcmNotificationResponseModel.batchId ?? "0"),
                  days: [],
                  details: "",
                  endDate: null,
                  endTime: null,
                  feeStructure: 0.0,
                  isActive: true,
                  level: "",
                  name: null,
                  sport: null,
                  startDate: null,
                  startTime: null,
                  playerCount: 0),
              mode: (AppNavigator.currentRoute ==
                      NavigationPages.coachBatchDetailScreen)
                  ? AppNavigationMode.pushAndReplace
                  : AppNavigationMode.push);
        } else if (playerUser != null) {
          AppNavigator.instance.navigateTo(
              name: NavigationPages.playerBatchDetails,
              arguments: Batch(
                  id: int.parse(fcmNotificationResponseModel.batchId ?? "0"),
                  coachesCount: 0,
                  playersCount: 0,
                  sportId: 0,
                  days: [],
                  details: "",
                  endDate: null,
                  endTime: null,
                  feeStructure: 0.0,
                  isActive: true,
                  level: "",
                  name: null,
                  sport: null,
                  startDate: null,
                  startTime: null),
              mode: (AppNavigator.currentRoute ==
                      NavigationPages.playerBatchDetails)
                  ? AppNavigationMode.pushAndReplace
                  : AppNavigationMode.push);
        }
      } else if (fcmNotificationResponseModel.notificationType ==
          "batch_removal") {
        if (coachUser != null || playerUser != null) {
          AppNavigator.instance.navigateTo(
              name: NavigationPages.notification,
              mode: (AppNavigator.currentRoute == NavigationPages.notification)
                  ? AppNavigationMode.pushAndReplace
                  : AppNavigationMode.push);
        }
      } else if (fcmNotificationResponseModel.notificationType ==
          "player_profile_update") {
        if (playerUser != null) {
          log('Player details screen');
          AppNavigator.instance.navigateTo(
              name: NavigationPages.playerProfileTabs,
              mode: (AppNavigator.currentRoute ==
                      NavigationPages.playerProfileTabs)
                  ? AppNavigationMode.pushAndReplace
                  : AppNavigationMode.push);
        }
      } else if (fcmNotificationResponseModel
              .notificationType
              ?.contains("survey") ??
          false) {
        if (playerUser != null) {
          AppNavigator.instance.navigateTo(
              name: NavigationPages.surveyQuestionsScreen,
              arguments: SurveyQuestionsParams(
                  batchId: fcmNotificationResponseModel.batchId ?? "",
                  triggerEvent:
                      fcmNotificationResponseModel.triggerEvent ?? ""),
              mode: (AppNavigator.currentRoute ==
                      NavigationPages.surveyQuestionsScreen)
                  ? AppNavigationMode.pushAndReplace
                  : AppNavigationMode.push);
        } else if (coachUser != null) {
          AppNavigator.instance.navigateTo(
              name: NavigationPages.coachSurveyQuestionsScreen,
              arguments: CoachSurveyQuestionsParams(
                  batchId: fcmNotificationResponseModel.batchId ?? "",
                  triggerEvent:
                      fcmNotificationResponseModel.triggerEvent ?? ""),
              mode: (AppNavigator.currentRoute ==
                      NavigationPages.coachSurveyQuestionsScreen)
                  ? AppNavigationMode.pushAndReplace
                  : AppNavigationMode.push);
        }
      } else if (fcmNotificationResponseModel.notificationType ==
              "match_request_received" ||
          fcmNotificationResponseModel.notificationType ==
              "update_match_result" ||
          fcmNotificationResponseModel.notificationType ==
              "confirm_match_result" ||
          fcmNotificationResponseModel.notificationType ==
              "match_result_declared" ||
          fcmNotificationResponseModel.notificationType ==
              "match_request_accepted" ||
          fcmNotificationResponseModel.notificationType ==
              "match_request_declined") {
        if (coachUser != null || playerUser != null) {
          AppNavigator.instance.isMatchPlayNotification = true;
          AppNavigator.instance.isRequestTab = true;
          AppNavigator.instance.upcomingMatchMasterSportId =
              int.parse(fcmNotificationResponseModel.masterSportId ?? "0");
          if (fcmNotificationResponseModel.notificationType ==
                  "update_match_result" ||
              fcmNotificationResponseModel.notificationType ==
                  "confirm_match_result" ||
              fcmNotificationResponseModel.notificationType ==
                  "match_result_declared") {
            AppNavigator.instance.isMatchPlayedTab = true;
          }
          if (fcmNotificationResponseModel.notificationType ==
              "match_request_accepted") {
            AppNavigator.instance.isUpcomingTab = true;
          }
        }
        if (coachUser != null) {
          AppNavigator.instance.navigateTo(
              name: NavigationPages.coachNavBar,
              arguments: false,
              mode: AppNavigationMode.pushAndRemoveRest);
        }
        if (playerUser != null) {
          AppNavigator.instance.navigateTo(
              name: NavigationPages.playerNavBar,
              arguments: false,
              mode: AppNavigationMode.pushAndRemoveRest);
        }
      } else {
        if (coachUser != null || playerUser != null) {
          AppNavigator.instance.navigateTo(
              name: NavigationPages.notification,
              mode: (AppNavigator.currentRoute == NavigationPages.notification)
                  ? AppNavigationMode.pushAndReplace
                  : AppNavigationMode.push);
        }
      }
    } catch (e, stacktrace) {
      print("2${e.toString()} ${stacktrace.toString()}");
    }
  }

  ///[onDidReceiveLocalNotification]  is only for iOS
  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) => CupertinoAlertDialog(
    //     title: Text(title),
    //     content: Text(body),
    //     actions: [
    //       CupertinoDialogAction(
    //         isDefaultAction: true,
    //         child: Text('Ok'),
    //         onPressed: () async {
    //           Navigator.of(context, rootNavigator: true).pop();
    //           await Navigator.push(
    //             context,
    //             MaterialPageRoute(
    //               builder: (context) => SecondScreen(payload),
    //             ),
    //           );
    //         },
    //       )
    //     ],
    //   ),
    // );
  }

  static Future<void> refreshToken() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      //print("beforedelete $_fcmToken");
      await messaging.deleteToken();
      _fcmToken = await messaging.getToken();
      //print("afterdelete $_fcmToken");
    } catch (e, stacktrace) {
      print("${e}${stacktrace}");
    }
  }

  // Future<dynamic> onDidReceiveLocalNotification(
  //     int id, String? title, String? body, String? payload) async {}
}
