import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class MyProvider extends ChangeNotifier {
  TextEditingController phoneNumber = TextEditingController();

  String name = "";
  String age = "";
  String phone = "";
  String nick = "";
  String url = "";
  String url1 = "";
  String gender = "";
  String email = "";
  String message = "";
  String image = "";
  String currentUid = "";

  late bool disabledButton = false;
  String? status;
  String currentProfileNick = "";
  String currentProfileImage = "";
  String uidFriend = "";
  String countryName = '';
  String errorMessage = '';
  String callerId = "";
  String fromUid = "";
  String deleteUid = "";
  String deleteFriendRequest = "";
  String groupName = "";
String checkkk="";
  String acceptedNick = "";
  String acceptedImage = "";
  String groupId="";
  List<String> selectedUid = [];
  List<String> selectedUid1 = [];
  List<String> membersNick =[];
  List<String> membersUid =[];
  Future<void> getCountryName() async {
    try {
      bool isLocationServiceEnabled =
          await Geolocator.isLocationServiceEnabled();
      if (!isLocationServiceEnabled) {
        errorMessage = 'Please enable location services.';

        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.deniedForever) {
        errorMessage =
            'Location permissions are permanently denied, we cannot request permissions.';

        return;
      }

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          errorMessage =
              'Location permissions are denied (actual value: $permission).';

          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
        localeIdentifier: 'en',
      );
      if (placemarks.isNotEmpty) {
        countryName = placemarks[0].country ?? "";
      }
    } catch (e) {
      print(e);

      errorMessage = 'Failed to get country name.';
    }
  }
}
