import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

import 'package:flutter/material.dart';

snackBarPhotoUpload(context) {
  var snackBar = SnackBar(
    /// need to set following properties for best effect of awesome_snackbar_content

    behavior: SnackBarBehavior.fixed,
    backgroundColor: Colors.transparent,
    content: AwesomeSnackbarContent(
      color: Colors.green,
      title: 'Photo updated',
      message: "",

      /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
      contentType: ContentType.success,
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

snackBarNameChange(context) {
  var snackBar = SnackBar(
    /// need to set following properties for best effect of awesome_snackbar_content

    behavior: SnackBarBehavior.fixed,
    backgroundColor: Colors.transparent,
    content: AwesomeSnackbarContent(
      color: Colors.green,
      title: 'Name changed',
      message: "Name changed",

      /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
      contentType: ContentType.success,
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

snackBarEmptyName(context) {
  var snackBar = SnackBar(
    /// need to set following properties for best effect of awesome_snackbar_content

    behavior: SnackBarBehavior.fixed,
    backgroundColor: Colors.transparent,
    content: AwesomeSnackbarContent(
      color: Colors.red,
      title: 'Please fill name field',
      message: "",

      /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
      contentType: ContentType.failure,
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

showEmptyMessage(BuildContext context) {
  AnimatedSnackBar.material('Please enter the message',
          type: AnimatedSnackBarType.error,
          mobileSnackBarPosition: MobileSnackBarPosition.bottom,
          desktopSnackBarPosition: DesktopSnackBarPosition.topLeft)
      .show(context);
}

snackBarCreateGroup(context) {
  var snackBar = SnackBar(
    /// need to set following properties for best effect of awesome_snackbar_content

    behavior: SnackBarBehavior.fixed,
    backgroundColor: Colors.transparent,
    content: AwesomeSnackbarContent(
      color: Colors.green,
      title: 'Successful',
      message: "group was created",

      /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
      contentType: ContentType.success,
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
