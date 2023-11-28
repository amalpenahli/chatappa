import 'dart:async';
import 'dart:math';

import 'package:chatapp/const/textstyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import '../provider/provider.dart';
import '../snackbar/snackbar_show.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController nameController;
  late final FirebaseFirestore _firestore;
  late final FirebaseAuth _firebaseAuth;
  late final CollectionReference userNameAgeCollection;
  late final User? currentUser;
  final Geolocator geolocator = Geolocator();
  Position? currentPosition;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<LiquidPullToRefreshState> _refreshIndicatorKey =
      GlobalKey<LiquidPullToRefreshState>();

  static int refreshNum = 10; // number that changes when refreshed
  Stream<int> counterStream =
      Stream<int>.periodic(const Duration(seconds: 3), (x) => refreshNum);

  @override
  void initState() {
    nameController = TextEditingController();
    _firestore = FirebaseFirestore.instance;
    _firebaseAuth = FirebaseAuth.instance;
    userNameAgeCollection = _firestore.collection("userNameAgeInfo");
    currentUser = _firebaseAuth.currentUser;

    late final myProvider = Provider.of<MyProvider>(context, listen: false);
    myProvider.getCountryName();

    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() {
    final Completer<void> completer = Completer<void>();
    Timer(const Duration(seconds: 3), () {
      completer.complete();
    });
    setState(() {
      refreshNum = Random().nextInt(100);
    });
    return completer.future.then<void>((_) {
      ScaffoldMessenger.of(_scaffoldKey.currentState!.context).showSnackBar(
        SnackBar(
          content: const Text('Refresh complete'),
          action: SnackBarAction(
            label: 'RETRY',
            onPressed: () {
              _refreshIndicatorKey.currentState!.show();
            },
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // MyProvider myState = Provider.of<MyProvider>(context);
    return StreamBuilder<DocumentSnapshot>(
        stream: userNameAgeCollection.doc(currentUser!.uid).snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          Provider.of<MyProvider>(context, listen: false).name = data["name"];
          Provider.of<MyProvider>(context, listen: false).age = data["age"];
          Provider.of<MyProvider>(context, listen: false).gender =
              data["gender"];
          Provider.of<MyProvider>(context, listen: false).email = data["email"];
          Provider.of<MyProvider>(context, listen: false).phone = data["phone"];
          Provider.of<MyProvider>(context, listen: false).nick = data["nick"];
          return Scaffold(
            appBar: AppBar(
              title: const Text('Profile'),
            ),
            body: LiquidPullToRefresh(
              key: _refreshIndicatorKey,
              onRefresh: _handleRefresh,
              showChildOpacityTransition: false,
              child: SingleChildScrollView(
                physics:const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: data['image'] == null
                          ? const AssetImage("assets/images/profileImage.png")
                          : NetworkImage(data['image'].toString())
                              as ImageProvider,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(data["name"], style: accountEmail),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Change name"),
                                      content: TextField(
                                        controller: nameController,
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text("OK"),
                                          onPressed: () {
                                            if (nameController.text == "") {
                                              print("bos ola bilmez");
                                              snackBarEmptyName(context);
                                            } else {
                                              snackBarNameChange(context);
                                              Navigator.of(context).pop();
                                            }

                                            setState(() {
                                              DocumentReference
                                                  documentReference =
                                                  userNameAgeCollection
                                                      .doc(currentUser!.uid);
                                              Map<String, String> updateName = {
                                                "name": nameController.text
                                              };
                                              documentReference.set(updateName,
                                                  SetOptions(merge: true));
                                            });
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              });
                            },
                            icon: const Icon(Icons.edit))
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (Provider.of<MyProvider>(context, listen: false)
                        .errorMessage
                        .isNotEmpty)
                      Text(
                        Provider.of<MyProvider>(context, listen: false)
                            .errorMessage,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    if (Provider.of<MyProvider>(context, listen: false)
                            .errorMessage
                            .isEmpty &&
                        Provider.of<MyProvider>(context, listen: false)
                            .countryName
                            .isNotEmpty)
                      const SizedBox(height: 20),
                    buildInfoCard(Icons.email, 'Email', data["email"]),
                    buildInfoCard(Icons.phone, 'Phone', data["phone"]),
                    buildInfoCard(
                      FontAwesomeIcons.globe,
                      'Country',
                      Provider.of<MyProvider>(context, listen: false)
                          .countryName,
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

Widget buildInfoCard(IconData icon, String title, String value) {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(value),
    ),
  );
}
