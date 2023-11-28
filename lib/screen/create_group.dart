import 'dart:ffi';
import 'dart:io';
import 'package:chatapp/screen/group_message.dart';
import 'package:chatapp/screen/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../const/textstyle.dart';
import '../provider/provider.dart';
import '../snackbar/snackbar_show.dart';

class GroupChat extends StatefulWidget {
  const GroupChat({super.key});

  @override
  State<GroupChat> createState() => _GroupChatState();
}

class _GroupChatState extends State<GroupChat> {
  late TextEditingController nameGroupController;
  late ValueNotifier<bool> isButtonEnabledNotifier;
  late final FirebaseFirestore _firestore;
  late final FirebaseAuth _firebaseAuth;
  late final CollectionReference userNameAgeCollection;
  late final CollectionReference groupMessageCollection;
  late final User? currentUser;
  bool _isEmpty = true;
  @override
  void initState() {
    isButtonEnabledNotifier = ValueNotifier<bool>(false);
    nameGroupController = TextEditingController();
    _firestore = FirebaseFirestore.instance;
    _firebaseAuth = FirebaseAuth.instance;
    userNameAgeCollection = _firestore.collection("userNameAgeInfo");
    groupMessageCollection = _firestore.collection("groupMessages");
    currentUser = _firebaseAuth.currentUser;
    nameGroupController.addListener(_checkTextEmpty);
    //_handleButtonPress();
    super.initState();
    //_handleButtonPress();
  }

  List<String> selectedUsers = [];
  //List<String> selectedUid = [];
  bool isUploading = true;
  void _handleButtonPress() {
    setState(() {
      isUploading = false;
    });
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isUploading = true;
      });
    });
  }

  void _checkTextEmpty() {
    setState(() {
      _isEmpty = nameGroupController.text.isEmpty;
      isButtonEnabledNotifier.value = !_isEmpty;
    });
  }

  void _toggleUserSelection(String user, String id) {
    setState(() {
      if (selectedUsers.contains(user) &&
          Provider.of<MyProvider>(context, listen: false)
              .selectedUid
              .contains(id)) {
        selectedUsers.remove(user);
        Provider.of<MyProvider>(context, listen: false).selectedUid.remove(id);
      } else {
        selectedUsers.add(user);
        Provider.of<MyProvider>(context, listen: false).selectedUid.add(id);
      }
    });
  }

  @override
  void dispose() {
    nameGroupController.dispose();
    isButtonEnabledNotifier.dispose();
    super.dispose();
  }

  File? _pickedImage;

  String generateGroupId() {
    return userNameAgeCollection
        .doc(currentUser!.uid)
        .collection("groupMessages")
        .doc()
        .id;
  }

  late String groupId = generateGroupId();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create group"),
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Your friend list",
                  style: friendList,
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                  stream: userNameAgeCollection
                      .doc(currentUser!.uid)
                      .collection("acceptedFriendRequest")
                      .snapshots(),
                  builder:
                      (context, AsyncSnapshot<QuerySnapshot> snapshotList) {
                    if (snapshotList.hasError) {
                      return Text('Error: ${snapshotList.error}');
                    }

                    if (snapshotList.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    if (!snapshotList.hasData || snapshotList.data == null) {
                      return const Text('No data found');
                    }

                    //List < Map<String, dynamic> >map = snapshotList.data!.docs as List< Map<String, dynamic>>;
                    return SizedBox(
                        child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshotList.data!.docs.length,
                      itemBuilder: (context, index) {
                        QueryDocumentSnapshot<Object?> user =
                            snapshotList.data!.docs[index];
                        Map<String, dynamic> data =
                            user.data() as Map<String, dynamic>;

                        return InkWell(
                          onTap: () {
                            Provider.of<MyProvider>(context, listen: false)
                                .currentUid = data["fromUid"];
                            Provider.of<MyProvider>(context, listen: false)
                                .nick = data["fromNick"];
                            //  print(documentData["fromUid"]);
                            print(
                                Provider.of<MyProvider>(context, listen: false)
                                    .currentUid);
                          },
                          child: data["fromUid"] ==
                                  Provider.of<MyProvider>(context,
                                          listen: false)
                                      .currentUid
                              ? ListTile(
                                  title: Text(
                                    data["fromNick"],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  leading: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(data["fromProfileImage"]),
                                  ),
                                )
                              : ListTile(
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        data["fromNick"],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  leading: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(data["fromProfileImage"]),
                                  ),

                                  onTap: () {
                                    _toggleUserSelection(
                                        data["fromNick"], data["fromUid"]);
                                    print(Provider.of<MyProvider>(context,
                                            listen: false)
                                        .selectedUid);
                                  },
                                  // ignore: iterable_contains_unrelated_type
                                  tileColor:
                                      selectedUsers.contains(data["fromNick"])
                                          ? Colors.blue.withOpacity(0.5)
                                          : null,
                                ),
                        );
                      },
                    ));
                  }),
            ],
          ),
          if (selectedUsers.isNotEmpty &&
              Provider.of<MyProvider>(context, listen: false)
                  .selectedUid
                  .isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Colors.grey,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected Users:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: selectedUsers
                          .map((selectedUsers) => Chip(
                                label: Text(selectedUsers),
                                backgroundColor: Colors.blue,
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: selectedUsers.isNotEmpty ? Colors.blue : Colors.grey,
        onPressed: selectedUsers.isNotEmpty
            ? () {
                // Perform action with selected users
                print(Provider.of<MyProvider>(context, listen: false)
                    .selectedUid);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Row(children: [
                        Text("Add group name and photo", style: groupNamePhoto),
                        CircleAvatar(
                          radius: 40,
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
                        )
                      ]),
                      content: TextField(
                        controller: nameGroupController,
                      ),
                      actions: <Widget>[
                        ValueListenableBuilder<bool>(
                            valueListenable: isButtonEnabledNotifier,
                            builder: (BuildContext context,
                                bool isButtonEnabled, Widget? child) {
                              return isUploading
                                  ? Column(
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isButtonEnabled
                                                ? Colors.blue
                                                : Colors.grey,
                                          ),
                                          onPressed: isButtonEnabled
                                              ? () {
                                                  Provider.of<MyProvider>(
                                                          context,
                                                          listen: false)
                                                      .groupName = "";
                                                  setState(() {
                                                    _handleButtonPress();
                                                  });

                                                  print(Provider.of<MyProvider>(
                                                          context,
                                                          listen: false)
                                                      .selectedUid);

                                                  createGroup();
                                                  // createGroupForFriends();
                                                  Navigator.of(context).pop();

                                                  //}
                                                }
                                              : null,
                                          child: const Text("create group"),
                                        )
                                      ],
                                    )
                                  : const CircularProgressIndicator();
                            }),
                      ],
                    );
                  },
                );
              }
            : null,
        child: const Icon(Icons.edit),
      ),
    );
  }

  void createGroup() async {
    setState(() {
      selectedUsers.add(
          Provider.of<MyProvider>(context, listen: false).currentProfileNick);
    });

    await userNameAgeCollection
        .doc(currentUser!.uid)
        .collection("groupMessages")
        .doc(groupId)
        .set({
          'fromNick': nameGroupController.text,
          // ignore: use_build_context_synchronously
          "fromProfileImage":
              Provider.of<MyProvider>(context, listen: false).url,
          "type": "group",
          "fromUid": currentUser!.uid,
          "currentNick": Provider.of<MyProvider>(context, listen: false)
              .currentProfileNick,
          'membersUid':
              Provider.of<MyProvider>(context, listen: false).selectedUid,

          "membersNick": selectedUsers,
          "timestamp": FieldValue.serverTimestamp(),
        })
        .whenComplete(() => createGroupForFriends())
        .whenComplete(() => Future.delayed(const Duration(seconds: 4))
            .whenComplete(() => snackBarCreateGroup(context))
            .whenComplete(() => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage()),
                ))
            .whenComplete(() => nameGroupController.clear())
            .whenComplete(() => selectedUsers.clear()))
        .whenComplete(() {});
  }

//////////////////////////////////////////////////////////
  void createGroupForFriends() async {
    setState(() {
      Provider.of<MyProvider>(context, listen: false)
          .selectedUid
          .add(currentUser!.uid);
    });
    // ignore: dead_code, avoid_function_literals_in_foreach_calls
    Provider.of<MyProvider>(context, listen: false)
        .selectedUid
        .forEach((element) async {
      await userNameAgeCollection
          .doc(element)
          .collection("groupMessages")
          .doc(groupId)
          .set({
        'fromNick': nameGroupController.text,
        // ignore: use_build_context_synchronously
        "fromProfileImage":
            // ignore: use_build_context_synchronously
            Provider.of<MyProvider>(context, listen: false).url,
        "currentNick":
            Provider.of<MyProvider>(context, listen: false).currentProfileNick,
        "type": "group",
        "fromUid": currentUser!.uid,
        'membersUid':
            Provider.of<MyProvider>(context, listen: false).selectedUid,
        "membersNick": selectedUsers,
        "whoCreateGroup":
            Provider.of<MyProvider>(context, listen: false).currentProfileNick,
        "timestamp": FieldValue.serverTimestamp(),
        // Add other fields as needed
      }).whenComplete(() => Provider.of<MyProvider>(context, listen: false)
              .selectedUid
              .clear());

      //return groupDoc1.id;
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
