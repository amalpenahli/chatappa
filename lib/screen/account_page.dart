import 'package:chatapp/const/textstyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../const/container_border.dart';
import '../provider/provider.dart';
import '../snackbar/snackbar_show.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late TextEditingController nameController;
  late final FirebaseFirestore _firestore;
  late final FirebaseAuth _firebaseAuth;
  late final CollectionReference userNameAgeCollection;
  late final User? currentUser;

  @override
  void initState() {
    nameController = TextEditingController();
    _firestore = FirebaseFirestore.instance;
    _firebaseAuth = FirebaseAuth.instance;
    userNameAgeCollection = _firestore.collection("userNameAgeInfo");
    currentUser = _firebaseAuth.currentUser;

    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              title: const Text("Account"),
            ),
            body: Container(
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/amalo.jpeg"),
                    fit: BoxFit.cover),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 18.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.white,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: data['image'] == null
                                ? Image.asset("assets/images/profileImage.png")
                                : Image.network(data['image'].toString()))),
                    const SizedBox(
                      height: 10,
                    ),
                    Column(
                      children: [
                        Text( Provider.of<MyProvider>(context, listen: false).nick),
                        Text(
                          Provider.of<MyProvider>(context, listen: false).email,
                          
                          style: accountEmail,
                        ),
                         Text(
                          Provider.of<MyProvider>(context, listen: false).phone,
                          
                          style: accountEmail,
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      decoration: boxDecoration,
                      width: 200,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Name: ${Provider.of<MyProvider>(context, listen: false).name}",
                            style: accountText,
                          ),
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
                                                Map<String, String> updateName =
                                                    {
                                                  "name": nameController.text
                                                };
                                                documentReference.set(
                                                    updateName,
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
                              icon:const Icon(Icons.edit))
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      decoration: boxDecoration,
                      width: 200,
                      child: Center(
                        child: Text(
                          "Gender: ${Provider.of<MyProvider>(context, listen: false).gender}",
                          style: accountText,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: 200,
                      decoration: boxDecoration,
                      child: Center(
                        child: Text(
                          "Age: ${Provider.of<MyProvider>(context, listen: false).age}",
                          style: accountText,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
