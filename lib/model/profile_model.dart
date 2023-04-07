import 'package:flutter/material.dart';

class PofileModel {
  final String text;
  final Icon icon;

  PofileModel({
    required this.text,
    required this.icon,
  });
}

class ProfileData {
  static List profileDataList = [
    PofileModel(text: "Account", icon: const Icon(Icons.account_box)),
    PofileModel(text: "Chats", icon: const Icon(Icons.chat)),
    PofileModel(
      text: "Notifications",
      icon: const Icon(Icons.notifications),
    ),
    PofileModel(
      text: "Privacy",
      icon: const Icon(Icons.lock),
    ),
    PofileModel(
      text: "Avatar",
      icon: const Icon(Icons.photo),
    ),
    PofileModel(
      text: "App language",
      icon: const Icon(Icons.language),
    ),
    PofileModel(
      text: "Help",
      icon: const Icon(Icons.help),
    ),
    PofileModel(
      text: "Exit",
      icon: const Icon(Icons.exit_to_app),
    ),
  ];
}
