import 'package:animated_snack_bar/animated_snack_bar.dart';

import 'package:flutter/material.dart';

showEmptyMessage(BuildContext context) {
  AnimatedSnackBar.material('This a snackbar with info type',
                          type: AnimatedSnackBarType.info,
                          mobileSnackBarPosition: MobileSnackBarPosition.bottom,
                          desktopSnackBarPosition:
                              DesktopSnackBarPosition.bottomLeft)
                      .show(context);
}