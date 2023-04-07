import 'dart:io';
import 'package:chatapp/const/button_style.dart';
import 'package:chatapp/const/textstyle.dart';
import 'package:chatapp/model/profile_model.dart';
import 'package:chatapp/screen/app_language_page.dart';
import 'package:chatapp/screen/avatar_page.dart';
import 'package:chatapp/screen/help_page.dart';
import 'package:chatapp/screen/notifications_page.dart';
import 'package:chatapp/screen/privacy_message.dart';
import 'package:chatapp/screen/privacy_page.dart';
import 'package:chatapp/screen/search_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../model/users_model.dart';
import '../provider/provider.dart';
import '../snackbar/snackbar_show.dart';
import 'account_page.dart';
import 'chats_page.dart';

// ignore: use_key_in_widget_constructors
class MyHomePage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  List pages = [
    const AccountPage(),
    const ChatsPage(),
    const NotificationsPage(),
    const PrivacyPage(),
    const AvatarPage(),
    const Applanguage(),
    const HelpPage()
  ];
  late TabController tabController;
  late final FirebaseFirestore _firestore;
  late final FirebaseAuth _firebaseAuth;
  late final CollectionReference userNameAgeCollection;
  late final User? currentUser;

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    _firestore = FirebaseFirestore.instance;
    _firebaseAuth = FirebaseAuth.instance;
    userNameAgeCollection = _firestore.collection("userNameAgeInfo");
    currentUser = _firebaseAuth.currentUser;

    super.initState();
  }

  File? _pickedImage;
  String url = "";
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
          return Scaffold(
            appBar: AppBar(
              centerTitle: false,
              title: const Text(
                "Amalo",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 32.0,
                    fontWeight: FontWeight.w600),
              ),
              actions: <Widget>[
                IconButton(onPressed: () {
                  Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const SearchPage()));
                }, icon: const Icon(Icons.search)),
                
              ],
              backgroundColor: Colors.blue,
              bottom: TabBar(
                tabs: const [
                  Tab(
                    child: Text("CHATS"),
                  ),
                  Tab(
                      child: Text(
                    "STATUS",
                  )),
                  Tab(
                      child: Text(
                    "CALLS",
                  )),
                ],
                indicatorColor: Colors.white,
                controller: tabController,
              ),
            ),
            drawer: SizedBox(
                width: 250,
                child: Drawer(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 50.0, left: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            InkWell(
                                onTap: () {
                                  setState(() {
                                    showModalBottomSheet<void>(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      backgroundColor: Colors.white,
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
                                                          style: ButtonStylee
                                                              .takeDeleteUploadPhoto,
                                                          child: const Text(
                                                              'Take photo'),
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
                                                          style: ButtonStylee
                                                              .takeDeleteUploadPhoto,
                                                          child: const Text(
                                                              'Change photo'),
                                                          onPressed: () async {
                                                            setState(() {
                                                              _pickImageGallery();
                                                            });
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
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                        width: 130,
                                                        child: ElevatedButton(
                                                            style: ButtonStylee
                                                                .takeDeleteUploadPhoto,
                                                            onPressed:
                                                                () async {
                                                              setState(() {
                                                                imageDelete();
                                                              });
                                                            },
                                                            child: const Text(
                                                                "delete photo"))),
                                                    const SizedBox(width: 15),
                                                    const Icon(
                                                      Icons.delete,
                                                      size: 40,
                                                      color: Colors.grey,
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  });
                                },
                                child: CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.white,
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: data['image'] == null
                                            ? Image.asset(
                                                "assets/images/profileImage.png")
                                            : Image.network(
                                                data['image'].toString())))),
                            const SizedBox(
                              width: 40,
                            ),
                            Column(
                              children: [
                                Text(
                                  Provider.of<MyProvider>(context,
                                          listen: false)
                                      .name,
                                  style: profileName,
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Text(
                                      "${Provider.of<MyProvider>(context, listen: false).age} yaş",
                                      style: profileAge,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        //height: MediaQuery.of(context).size.height,
                        child: InkWell(
                          onTap: () {
                            /*   Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const RegisterPhone()),
                            ); */
                          },
                          child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: ProfileData.profileDataList.length,
                              itemBuilder: (BuildContext context, int index) {
                                PofileModel pofileModel =
                                    ProfileData.profileDataList[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => pages[index]),
                                    );

                                    print(index);
                                  },
                                  child: ListTile(
                                    leading: pofileModel.icon,
                                    title: Text(pofileModel.text),
                                  ),
                                );
                              }),
                        ),
                      )
                    ],
                  ),
                )),
            // endDrawer: SizedBox(
            //     width: 250,
            //     child: Drawer(
            //       child: Column(
            //         children: [
            //           Padding(
            //             padding: const EdgeInsets.only(top: 50.0, left: 10),
            //             child: Row(
            //               mainAxisAlignment: MainAxisAlignment.start,
            //               children: [
            //                 InkWell(
            //                     onTap: () {
            //                       setState(() {
            //                         showModalBottomSheet<void>(
            //                           shape: RoundedRectangleBorder(
            //                             borderRadius:
            //                                 BorderRadius.circular(10.0),
            //                           ),
            //                           backgroundColor: Colors.white,
            //                           context: context,
            //                           builder: (BuildContext context) {
            //                             return SizedBox(
            //                               height: 200,
            //                               child: Center(
            //                                 child: Column(
            //                                   mainAxisAlignment:
            //                                       MainAxisAlignment.center,
            //                                   mainAxisSize: MainAxisSize.min,
            //                                   children: <Widget>[
            //                                     Row(
            //                                       mainAxisAlignment:
            //                                           MainAxisAlignment.center,
            //                                       children: [
            //                                         SizedBox(
            //                                           width: 130,
            //                                           child: ElevatedButton(
            //                                               style: ButtonStylee
            //                                                   .takeDeleteUploadPhoto,
            //                                               child: const Text(
            //                                                   'Take photo'),
            //                                               onPressed: () {}),
            //                                         ),
            //                                         const SizedBox(
            //                                           width: 15,
            //                                         ),
            //                                         const Icon(
            //                                           FontAwesomeIcons.camera,
            //                                           size: 40,
            //                                           color: Colors.grey,
            //                                         )
            //                                       ],
            //                                     ),
            //                                     Row(
            //                                       mainAxisAlignment:
            //                                           MainAxisAlignment.center,
            //                                       children: [
            //                                         SizedBox(
            //                                           width: 130,
            //                                           child: ElevatedButton(
            //                                               style: ButtonStylee
            //                                                   .takeDeleteUploadPhoto,
            //                                               child: const Text(
            //                                                   'Change photo'),
            //                                               onPressed: () async {
            //                                                 setState(() {
            //                                                   _pickImageGallery();
            //                                                 });
            //                                               }),
            //                                         ),
            //                                         const SizedBox(
            //                                           width: 15,
            //                                         ),
            //                                         const Icon(
            //                                           FontAwesomeIcons.upload,
            //                                           size: 40,
            //                                           color: Colors.grey,
            //                                         )
            //                                       ],
            //                                     ),
            //                                     Row(
            //                                       mainAxisAlignment:
            //                                           MainAxisAlignment.center,
            //                                       children: [
            //                                         SizedBox(
            //                                             width: 130,
            //                                             child: ElevatedButton(
            //                                                 style: ButtonStylee
            //                                                     .takeDeleteUploadPhoto,
            //                                                 onPressed:
            //                                                     () async {
            //                                                   setState(() {
            //                                                     imageDelete();
            //                                                   });
            //                                                 },
            //                                                 child: const Text(
            //                                                     "delete photo"))),
            //                                         const SizedBox(width: 15),
            //                                         const Icon(
            //                                           Icons.delete,
            //                                           size: 40,
            //                                           color: Colors.grey,
            //                                         )
            //                                       ],
            //                                     )
            //                                   ],
            //                                 ),
            //                               ),
            //                             );
            //                           },
            //                         );
            //                       });
            //                     },
            //                     child: CircleAvatar(
            //                         radius: 50,
            //                         backgroundColor: Colors.white,
            //                         child: ClipRRect(
            //                             borderRadius: BorderRadius.circular(50),
            //                             child: data['image'] == null
            //                                 ? Image.asset(
            //                                     "assets/images/profileImage.png")
            //                                 : Image.network(
            //                                     data['image'].toString())))),
            //                 const SizedBox(
            //                   width: 40,
            //                 ),
            //                 Column(
            //                   children: [
            //                     Text(
            //                       Provider.of<MyProvider>(context,
            //                               listen: false)
            //                           .name,
            //                       style: profileName,
            //                     ),
            //                     const SizedBox(height: 5),
            //                     Row(
            //                       children: [
            //                         Text(
            //                           "${Provider.of<MyProvider>(context, listen: false).age} yaş",
            //                           style: profileAge,
            //                         ),
            //                       ],
            //                     ),
            //                   ],
            //                 ),
            //               ],
            //             ),
            //           ),
            //           SizedBox(
            //             width: 250,
            //             //height: MediaQuery.of(context).size.height,
            //             child: InkWell(
            //               onTap: () {
            //                 /*   Navigator.push(
            //                   context,
            //                   MaterialPageRoute(
            //                       builder: (context) => const RegisterPhone()),
            //                 ); */
            //               },
            //               child: ListView.builder(
            //                   physics: const NeverScrollableScrollPhysics(),
            //                   shrinkWrap: true,
            //                   itemCount: ProfileData.profileDataList.length,
            //                   itemBuilder: (BuildContext context, int index) {
            //                     PofileModel pofileModel =
            //                         ProfileData.profileDataList[index];
            //                     return GestureDetector(
            //                       onTap: () {
            //                         Navigator.push(
            //                           context,
            //                           MaterialPageRoute(
            //                               builder: (context) => pages[index]),
            //                         );

            //                         print(index);
            //                       },
            //                       child: ListTile(
            //                         leading: pofileModel.icon,
            //                         title: Text(pofileModel.text),
            //                       ),
            //                     );
            //                   }),
            //             ),
            //           )
            //         ],
            //       ),
            //     )),
            body: TabBarView(
              controller: tabController,
              children: [
                SizedBox(
                  width: 200,
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: UserData.userDataList.length,
                      itemBuilder: (BuildContext context, int index) {
                        UsersInfo usersInfo = UserData.userDataList[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const PrivacyMessage()
                                        ),
                                        
                              );
                            });
                          },
                          child: ListTile(
                            leading: CircleAvatar(
                              child: ClipOval(
                                child: Image.asset(usersInfo.Iconurl),
                              ),
                            ),
                            title: Text(usersInfo.name),
                            subtitle: Text(usersInfo.message),
                          ),
                        );
                      }),
                ),
               const Text("Status Screen"),
               const Text("Call Screen"),
              ],
            ),
          );
        });
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
            '.jpg,png');
    await ref.putFile(_pickedImage!);

    // ignore: use_build_context_synchronously
    Provider.of<MyProvider>(context, listen: false).url =
        await ref.getDownloadURL().whenComplete(() => imageChange());
    // ignore: use_build_context_synchronously
    print(Provider.of<MyProvider>(context, listen: false).url);
    print(_pickedImage);
  }

  void imageChange() async {
    FirebaseFirestore.instance
        .collection("userNameAgeInfo")
        .doc(currentUser!.uid)
        .update({
      "image": Provider.of<MyProvider>(context, listen: false).url
    }).whenComplete(() => snackBarPhotoUpload(context));
  }

  void imageDelete() async {
    FirebaseFirestore.instance
        .collection("userNameAgeInfo")
        .doc(currentUser!.uid)
        .update({"image": FieldValue.delete()});
  }
}
