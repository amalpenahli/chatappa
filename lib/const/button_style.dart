import 'package:flutter/material.dart';

class ButtonStylee {
  static final otpSubmit = ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF087484),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      //padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      textStyle: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold));

  static final register = ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF087484),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      //padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      textStyle: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold));

  static final takeDeleteUploadPhoto = ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 27, 157, 120),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      //padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold));

  static final friendRequestAccept = ElevatedButton.styleFrom(
    backgroundColor: const Color.fromARGB(255, 9, 185, 9),
  );

  static final friendRequestCancel = ElevatedButton.styleFrom(
    backgroundColor: const Color.fromARGB(255, 234, 33, 10),
  );
}
