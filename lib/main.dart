import 'package:chatapp/api/firebase_api.dart';
import 'package:chatapp/provider/provider.dart';
import 'package:chatapp/screen/home_page.dart';
import 'package:chatapp/screen/notifications_page.dart';
import 'package:chatapp/screen/splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';


final navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseApi().initNotifications();

  SharedPreferences pref = await SharedPreferences.getInstance();

  var phone = pref.getString("phone");
  print(phone);

  // This widget is the root of your application.

  runApp(MultiProvider(
    providers: [ChangeNotifierProvider(create: (context) => MyProvider())],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorKey: navigatorKey,
      home: phone == null ? const SplashScreen() : MyHomePage(),
      routes: {
        NotificationsPage.route:(context) =>const  NotificationsPage(),
      },
    ),
  ));
}
