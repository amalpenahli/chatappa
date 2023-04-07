
import 'package:chatapp/provider/provider.dart';
import 'package:chatapp/screen/home_page.dart';
import 'package:chatapp/screen/splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
      home:phone == null ? const SplashScreen() : MyHomePage(),
    ),
  ));
}
