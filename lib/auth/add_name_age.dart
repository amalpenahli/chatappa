import 'dart:io';
import 'package:chatapp/const/button_style.dart';
import 'package:chatapp/const/textstyle.dart';
import 'package:chatapp/screen/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../const/textformfield.dart';
import '../provider/provider.dart';

class RegisterNameAge extends StatefulWidget {
  const RegisterNameAge({super.key});

  @override
  State<RegisterNameAge> createState() => _RegisterNameAgeState();
}

class _RegisterNameAgeState extends State<RegisterNameAge> {
  late final TextEditingController nameController;
  late final TextEditingController ageController;
  late final TextEditingController emailController;
  late final TextEditingController nickController;
  late final FirebaseFirestore _firestore;
  late final FirebaseAuth _firebaseAuth;
  late final CollectionReference userNameAgeCollection;
  late final User? currentUser;
  @override
  void initState() {
    _firestore = FirebaseFirestore.instance;
    _firebaseAuth = FirebaseAuth.instance;
    userNameAgeCollection = _firestore.collection("userNameAgeInfo");
    emailController = TextEditingController();
    nameController = TextEditingController();
    ageController = TextEditingController();
    nickController = TextEditingController();
    currentUser = _firebaseAuth.currentUser;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    ageController.dispose();
    nameController.dispose();
    emailController.dispose();
  }

  File? _pickedImage;

  String? gender;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFffffff),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Press icon and select photo",
                    style: profilePhoto,
                  ),
                  Image.asset(
                    "assets/icons/down_arrow.png",
                    scale: 5,
                  ),
                  CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            showModalBottomSheet<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return SizedBox(
                                  height: 200,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 130,
                                              child: ElevatedButton(
                                                  child:
                                                      const Text('Take photo'),
                                                  onPressed: () {}),
                                            ),
                                            const SizedBox(
                                              width: 15,
                                            ),
                                            const Icon(
                                              FontAwesomeIcons.camera,
                                              size: 40,
                                              color: Colors.grey,
                                            )
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 130,
                                              child: ElevatedButton(
                                                  child: const Text(
                                                      'Upload photo'),
                                                  onPressed: () async {
                                                    _pickImageGallery();
                                                  }),
                                            ),
                                            const SizedBox(
                                              width: 15,
                                            ),
                                            const Icon(
                                              FontAwesomeIcons.upload,
                                              size: 40,
                                              color: Colors.grey,
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          });
                        },
                        child: _pickedImage == null
                            ? Image.asset(
                                "assets/images/profile_image.png",
                              )
                            : Image.file(
                                _pickedImage!,
                                fit: BoxFit.fill,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: nameController,
                    decoration: registerName,
                    style: registerInputText,
                  ),
                   const SizedBox(height: 10),
                  TextFormField(
                    controller: nickController,
                    decoration: usersNick,
                    style: registerInputText,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: ageController,
                    decoration: registerAge,
                    style: registerInputText,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: registerEmail,
                    style: registerInputText,
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Select your gender",
                    style: genderText,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile(
                          activeColor: Colors.orange,
                          title: const Text("Male"),
                          value: "male",
                          groupValue: gender,
                          onChanged: (value) {
                            setState(() {
                              gender = value.toString();
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile(
                          activeColor: Colors.orange,
                          title: const Text("Female"),
                          value: "female",
                          groupValue: gender,
                          onChanged: (value) {
                            setState(() {
                              gender = value.toString();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                        style: ButtonStylee.register,
                        onPressed: () async {
                        
                          addNameAge();
                          SharedPreferences pref =
                              await SharedPreferences.getInstance();
                          // ignore: use_build_context_synchronously
                          pref.setString(
                              "phone",
                              // ignore: use_build_context_synchronously
                              Provider.of<MyProvider>(context, listen: false)
                                  .phone);
                        },
                        child: const Text("Submit")),
                  )
                ],
              ),
            ),
          ),
        ));
  }

  void addNameAge() {
    Map<String, String> info = {
      "name": nameController.text,
      "nick": nickController.text,
      "age": ageController.text,
      "userUid": currentUser!.uid,
      "gender": gender.toString(),
      "email": emailController.text,
      "image": Provider.of<MyProvider>(context, listen: false).url,
      "phone": Provider.of<MyProvider>(context, listen: false).phone,
      "uid": currentUser!.uid
    };
    userNameAgeCollection
        .doc(currentUser!.uid)
        .set(info, SetOptions(merge: true))
        .whenComplete(() => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => MyHomePage())),);
  }

  void _pickImageGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    final pickedImagefile = File(pickedImage!.path);
    setState(() {
      _pickedImage = pickedImagefile;
    });

    final ref = FirebaseStorage.instance
        .ref()
        .child('usersImages')
        // ignore: use_build_context_synchronously
        .child("user${Provider.of<MyProvider>(context, listen: false).phone}"
            '.jpg');
    await ref.putFile(_pickedImage!);

    // ignore: use_build_context_synchronously
    Provider.of<MyProvider>(context, listen: false).url =
        await ref.getDownloadURL();
    // ignore: use_build_context_synchronously
    print(Provider.of<MyProvider>(context, listen: false).url);
    print(_pickedImage);
  }

  
}
