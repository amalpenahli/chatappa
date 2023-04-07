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
