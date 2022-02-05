import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mentor_mate/splashscreen.dart';
import 'package:mentor_mate/welcome_and_other.dart';

Future<void> _messageHandler(RemoteMessage message) async {
  print('background message ${message.notification!.body}');
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.instance.getToken();
  

  /*FirebaseMessaging.onBackgroundMessage(_messageHandler);

  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    print('Message clicked!');
  });*/
  runApp(MyApp());
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //systemNavigationBarColor: Colors.blue, // navigation bar color
    statusBarColor: Colors.transparent, // status bar color
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        builder: (BuildContext context, Widget? widget) {
          ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
            return Container();
          };
          return widget!;
        },
        theme: ThemeData(
                   
          primarySwatch: Colors.blue,
          // This makes the visual density adapt to the platform that you run
          // the app on. For desktop platforms, the controls will be smaller and
          // closer together (more dense) than on mobile platforms.
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SplashScreen());
  }
}
