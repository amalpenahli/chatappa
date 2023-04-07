import 'package:flutter/material.dart';

class UsersInfo{
 final String name;
 final String message;
 // ignore: non_constant_identifier_names
 final String Iconurl;
 // ignore: prefer_typing_uninitialized_variables
 final color;
 // ignore: prefer_typing_uninitialized_variables
 final text;

  // ignore: prefer_typing_uninitialized_variables
  static var messageContainer;
 const UsersInfo({
   // ignore: non_constant_identifier_names
   required this.name ,required this.message, required this.Iconurl, required this.color, required this.text,
 });
}


class UserData{
   static List userDataList = [
  const UsersInfo(name: "Amal Penahli", message: "Salam Amal", Iconurl: "assets/images/man1.png", color: Colors.red, text:"offline"),
  const UsersInfo(name: "Anar Penahli", message: "Salam Anar", Iconurl: "assets/images/man2.png",color: Colors.yellow, text:"now exit"),
  const UsersInfo(name: "Kemine Penahli", message: "Salam Kemine", Iconurl: "assets/images/woman1.png",color: Colors.green, text:"online"),
  const UsersInfo(name: "Husnu Penahli", message: "Salam Husnu", Iconurl: "assets/images/man1.png",color: Colors.green, text:"online"),
  const UsersInfo(name: "Nezrin Penahli", message: "Salam Nezrin", Iconurl: "assets/images/woman2.png",color: Colors.red, text: "offline"),
];
List messageContainer = [];
}