
import 'package:flutter/material.dart';


class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});
  static const route ='/notification-screen';

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    final message = ModalRoute.of(context)!.settings.arguments;
    return  Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body:const Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
                  
          ],
        ),
      ),
    );
  }
}