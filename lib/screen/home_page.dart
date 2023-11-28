import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:chatapp/const/button_style.dart';
import 'package:chatapp/const/textstyle.dart';
import 'package:chatapp/model/profile_model.dart';
import 'package:chatapp/screen/app_language_page.dart';
import 'package:chatapp/screen/avatar_page.dart';
import 'package:chatapp/screen/create_group.dart';
import 'package:chatapp/screen/help_page.dart';
import 'package:chatapp/screen/notifications_page.dart';
import 'package:chatapp/screen/privacy_message.dart';
import 'package:chatapp/screen/privacy_page.dart';
import 'package:chatapp/screen/search_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import '../provider/provider.dart';
import '../snackbar/snackbar_show.dart';
import 'account_page.dart';
import 'common_chat.dart';

import 'group_message.dart';

// ignore: use_key_in_widget_constructors
class MyHomePage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  List pages = [
    const ProfilePage(),
    const ChatPage(),
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
  late final CollectionReference homeNickImageCollection;
  late final CollectionReference acceptedFriends;
  late final CollectionReference groupMessageCollection;
  late final User? currentUser;

  DatabaseReference? databaseReference;

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    _firestore = FirebaseFirestore.instance;
    _firebaseAuth = FirebaseAuth.instance;
    userNameAgeCollection = _firestore.collection("userNameAgeInfo");
    acceptedFriends = _firestore.collection("acceptedFriends");
    homeNickImageCollection = _firestore.collection("nickNameImage");
    currentUser = _firebaseAuth.currentUser;
    databaseReference = FirebaseDatabase.instance
        .ref()
        .child('users/${currentUser!.uid}/status');
    WidgetsBinding.instance.addObserver(this);
    databaseReference!.set('online');
    groupMessageCollection = _firestore.collection("groupMessages");
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    databaseReference!.onDisconnect().cancel(); // disconnect from Firebase
    databaseReference!.set('offline'); // set status to offline
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      databaseReference!.set('offline'); // set status to offline
    } else if (state == AppLifecycleState.resumed) {
      databaseReference!.set('online'); // set status to online
    }
  }

  File? _pickedImage;
  String url = "";
  Color color = Colors.green;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<LiquidPullToRefreshState> _refreshIndicatorKey =
      GlobalKey<LiquidPullToRefreshState>();

  static int refreshNum = 10; // number that changes when refreshed
  Stream<int> counterStream =
      Stream<int>.periodic(const Duration(seconds: 3), (x) => refreshNum);
  Future<void> handleRefresh() {
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
          Provider.of<MyProvider>(context, listen: false).currentUid =
              data["userUid"];
          Provider.of<MyProvider>(context, listen: false).currentProfileNick =
              data["nick"];
          Provider.of<MyProvider>(context, listen: false).currentProfileImage =
              data["image"];

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
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => const SearchPage()));
                            },
                            icon: const Icon(FontAwesomeIcons.magnifyingGlass)),
                        Stack(
                          children: [
                            Positioned(
                              left: 30,
                              child: StreamBuilder<QuerySnapshot>(
                                  stream: userNameAgeCollection
                                      .doc(currentUser!.uid)
                                      .collection("userFriendRequest")
                                      .snapshots(),
                                  builder: (context,
                                      AsyncSnapshot<QuerySnapshot>
                                          snapshotNumber) {
                                    if (!snapshotNumber.hasData) {
                                      return const CircularProgressIndicator();
                                    }

                                    return snapshotNumber.data!.docs.isNotEmpty
                                        ? Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              color: Colors.red,
                                            ),
                                            width: 15,
                                            height: 15,
                                            child: Center(
                                              child: Text(
                                                snapshotNumber.data!.docs.length
                                                    .toString(),
                                                style: const TextStyle(
                                                    fontSize: 13),
                                              ),
                                            ),
                                          )
                                        : Container();
                                  }),
                            ),
                            IconButton(
                                onPressed: () {
                                  showFriendRequest(context);
                                },
                                icon: const Icon(FontAwesomeIcons.userGroup)),
                            Padding(
                              padding: const EdgeInsets.only(left: 50.0),
                              child: PopupMenuButton(
                                offset: const Offset(0, 100),
                                icon: const Icon(Icons.more_vert),
                                onSelected: (value) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const GroupChat()),
                                  );
                                },
                                itemBuilder: (BuildContext bc) {
                                  return const [
                                    PopupMenuItem(
                                      value: '/hello',
                                      child: Text("Create group"),
                                    ),
                                  ];
                                },
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  )
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
                                  backgroundImage: data['image'] == ""
                                      ? const AssetImage(
                                          "assets/images/profileImage.png")
                                      : NetworkImage(data['image'].toString())
                                          as ImageProvider,
                                ),
                              ),
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
                                      //             print(Provider.of<MyProvider>(context, listen: false)
                                      // .countryName,);
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
              body: StreamBuilder<QuerySnapshot>(
                  stream: userNameAgeCollection
                      .doc(currentUser!.uid)
                      .collection("acceptedFriendRequest")
                      .snapshots(),
                  builder:
                      (context, AsyncSnapshot<QuerySnapshot> snapshotList1) {
                    if (snapshotList1.hasError) {
                      return Text('Error: ${snapshotList1.error}');
                    }

                    if (snapshotList1.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    if (!snapshotList1.hasData || snapshotList1.data == null) {
                      return const Text('No data found');
                    }
                    final List<DocumentSnapshot> firstCollectionDocs =
                        snapshotList1.data!.docs;
                    return StreamBuilder<QuerySnapshot>(
                        stream: userNameAgeCollection
                            .doc(currentUser!.uid)
                            .collection("groupMessages")
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                        builder: (context, snapshotList2) {
                          if (snapshotList2.hasError) {
                            return Text('Error: ${snapshotList2.error}');
                          }

                          if (snapshotList2.connectionState ==
                              ConnectionState.waiting) {
                            return const Text('Loading...');
                          }

                          // Extract the documents from the snapshot
                          final List<DocumentSnapshot> secondCollectionDocs =
                              snapshotList2.data!.docs;

                          final List<DocumentSnapshot> combinedDocs = [];
                          combinedDocs.addAll(firstCollectionDocs);
                          combinedDocs.addAll(secondCollectionDocs);
                          return TabBarView(
                            controller: tabController,
                            children: [
                              SingleChildScrollView(
                                child: SizedBox(
                                    child: Column(
                                  children: [
                                    ListView.builder(
                                        physics: const BouncingScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: combinedDocs.length,
                                        itemBuilder: (context, index) {
                                          // QueryDocumentSnapshot<Object?> user =
                                          //     snapshotList.data!.docs[index];
                                          // Map<String, dynamic> data =
                                          //     user.data() as Map<String, dynamic>;
                                          final document = combinedDocs[index];
                                          Map<String, dynamic> data1 = document
                                              .data() as Map<String, dynamic>;

                                          return InkWell(
                                            onTap: () {
                                              Provider.of<MyProvider>(context,
                                                          listen: false)
                                                      .groupId =
                                                  combinedDocs[index].id;

                                              Provider.of<MyProvider>(context,
                                                      listen: false)
                                                  .nick = data1["fromNick"];

                                              Provider.of<MyProvider>(context,
                                                          listen: false)
                                                      .image =
                                                  data1["fromProfileImage"];

                                              Provider.of<MyProvider>(context,
                                                          listen: false)
                                                      .currentUid =
                                                  data1["fromUid"];
                                              print(
                                                  'groupId: ${Provider.of<MyProvider>(context, listen: false).groupId}');
                                              //  print(documentData["fromUid"]);
                                              print(Provider.of<MyProvider>(
                                                      context,
                                                      listen: false)
                                                  .currentUid);

                                              print(Provider.of<MyProvider>(
                                                      context,
                                                      listen: false)
                                                  .groupName);

                                              if (data1["type"] == "group") {
                                                Provider.of<MyProvider>(context,
                                                            listen: false)
                                                        .groupName =
                                                    data1["fromNick"];
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const GroupNamesScreen()),
                                                );

                                                print(Provider.of<MyProvider>(
                                                        context,
                                                        listen: false)
                                                    .groupId);
                                              } else {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const PrivacyMessage()),
                                                );
                                              }
                                            },
                                            child: data1["fromUid"] ==
                                                        Provider.of<MyProvider>(
                                                                context,
                                                                listen: false)
                                                            .currentUid &&
                                                    data1["type"] == "group"
                                                ? ListTile(
                                                    title: Text(
                                                      data1["fromNick"],
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    subtitle: const Text(
                                                      "you create new group :)",
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    ),
                                                    leading: CircleAvatar(
                                                      backgroundImage: data1[
                                                                  'fromProfileImage'] ==
                                                              ""
                                                          ? const AssetImage(
                                                              "assets/images/profileImage.png")
                                                          : NetworkImage(data1[
                                                                      'fromProfileImage']
                                                                  .toString())
                                                              as ImageProvider,
                                                    ),
                                                  )
                                                : data1["type"] == "group"
                                                    ? ListTile(
                                                        title: Text(
                                                          data1["fromNick"],
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        subtitle: Text(
                                                          "${data1["whoCreateGroup"]} create new group :)",
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .red),
                                                        ),
                                                        leading: CircleAvatar(
                                                          backgroundImage: data1[
                                                                      'fromProfileImage'] ==
                                                                  ""
                                                              ? const AssetImage(
                                                                  "assets/images/profileImage.png")
                                                              : NetworkImage(data1[
                                                                          'fromProfileImage']
                                                                      .toString())
                                                                  as ImageProvider,
                                                        ),
                                                      )
                                                    : ListTile(
                                                        title: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              data1["fromNick"],
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            IconButton(
                                                                onPressed: () {
                                                                  setState(() {
                                                                    Provider.of<MyProvider>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .deleteUid = data1["fromUid"];
                                                                    showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (BuildContext
                                                                              context) {
                                                                        return AlertDialog(
                                                                          title:
                                                                              const Text('Delete User'),
                                                                          content:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: [
                                                                              const Text('Are you sure you want to delete user?'),
                                                                              Text(data1["fromUid"])
                                                                            ],
                                                                          ),
                                                                          actions: [
                                                                            TextButton(
                                                                              child: const Text('Cancel'),
                                                                              onPressed: () {
                                                                                Navigator.of(context).pop();
                                                                              },
                                                                            ),
                                                                            TextButton(
                                                                              child: const Text('Delete'),
                                                                              onPressed: () async {
                                                                                deleteFriend();
                                                                                Navigator.of(context).pop();
                                                                              },
                                                                            ),
                                                                          ],
                                                                        );
                                                                      },
                                                                    );
                                                                  });
                                                                  print(data1[
                                                                      "fromUid"]);
                                                                },
                                                                icon: const Icon(
                                                                    FontAwesomeIcons
                                                                        .userMinus))
                                                          ],
                                                        ),
                                                        subtitle: const Text(
                                                          "now you are friend :)",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red),
                                                        ),
                                                        leading: CircleAvatar(
                                                          backgroundImage:
                                                              NetworkImage(data1[
                                                                  "fromProfileImage"]),
                                                        ),
                                                      ),
                                          );
                                        }),
                                  ],
                                )),
                              ),
                              const Text("Status Screen"),
                              StreamBuilder<QuerySnapshot>(
                                  stream: userNameAgeCollection
                                      .doc(currentUser!.uid)
                                      .collection("acceptedFriendRequest")
                                      .snapshots(),
                                  builder: (context,
                                      AsyncSnapshot<QuerySnapshot>
                                          snapshotList2) {
                                    if (snapshotList2.hasError) {
                                      return Text(
                                          'Error: ${snapshotList2.error}');
                                    }

                                    if (snapshotList2.connectionState ==
                                        ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    }

                                    if (!snapshotList2.hasData ||
                                        snapshotList2.data == null) {
                                      return const Text('No data found');
                                    }

                                    //List < Map<String, dynamic> >map = snapshotList.data!.docs as List< Map<String, dynamic>>;
                                    return SizedBox(
                                        child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount:
                                          snapshotList2.data!.docs.length,
                                      itemBuilder: (context, index) {
                                        QueryDocumentSnapshot<Object?> user =
                                            snapshotList2.data!.docs[index];
                                        Map<String, dynamic> data =
                                            user.data() as Map<String, dynamic>;

                                        return ListTile(
                                          title: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                data["fromNick"],
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Row(
                                                children: [
                                                  IconButton(
                                                      onPressed: () {},
                                                      icon: const Icon(
                                                          Icons.call)),
                                                  IconButton(
                                                      onPressed: () {},
                                                      icon: const Icon(
                                                          Icons.video_call)),
                                                ],
                                              )
                                            ],
                                          ),
                                          leading: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                data["fromProfileImage"]),
                                          ),

                                          // ignore: iterable_contains_unrelated_type
                                        );
                                      },
                                    ));
                                  }),
                            ],
                          );
                        });

                    //print( Provider.of<MyProvider>(context, listen: false).uidList);
                  }));
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
        .update({"image": ""});
  }

  void showFriendRequest(BuildContext context) {
    AwesomeDialog(
      context: context,
      animType: AnimType.bottomSlide,
      dialogType: DialogType.info,
      body: StreamBuilder<QuerySnapshot>(
          stream: userNameAgeCollection
              .doc(currentUser!.uid)
              .collection("userFriendRequest")
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshotFriend) {
            if (!snapshotFriend.hasData) {
              return const CircularProgressIndicator();
            } else {
              return SizedBox(
                // width: MediaQuery.of(context).size.width,
                // height: MediaQuery.of(context).size.height,
                child: ListView(
                    shrinkWrap: true,
                    children: snapshotFriend.data!.docs.map((documentFriend) {
                      Provider.of<MyProvider>(context, listen: false).fromUid =
                          documentFriend["fromUid"];
                      print(Provider.of<MyProvider>(context, listen: false)
                          .fromUid);

                      return ListTile(
                          title: Text("${documentFriend["fromNick"]}",
                              style: friendRequest),
                          leading: ClipOval(
                            child: SizedBox(
                                width: 50,
                                height: 50,
                                child: Image.network(
                                  documentFriend["fromImage"],
                                  fit: BoxFit.cover,
                                )),
                          ),
                          subtitle: Text(documentFriend["fromUid"]),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                  width: 50,
                                  height: 30,
                                  child: ElevatedButton(
                                      style: ButtonStylee.friendRequestAccept,
                                      onPressed: () {
                                        Provider.of<MyProvider>(context,
                                                    listen: false)
                                                .fromUid =
                                            documentFriend["fromUid"];
                                        Provider.of<MyProvider>(context,
                                                    listen: false)
                                                .deleteFriendRequest =
                                            documentFriend["fromUid"];
                                        Provider.of<MyProvider>(context,
                                                    listen: false)
                                                .acceptedNick =
                                            documentFriend["fromNick"];
                                        Provider.of<MyProvider>(context,
                                                    listen: false)
                                                .acceptedImage =
                                            documentFriend["fromImage"];
                                        print(Provider.of<MyProvider>(context,
                                                listen: false)
                                            .fromUid);
                                        acceptedFriendRequest();
                                        deleteFriendRequest();
                                      },
                                      child:
                                          const Icon(FontAwesomeIcons.check))),
                              const SizedBox(
                                width: 10,
                              ),
                              SizedBox(
                                  width: 50,
                                  height: 30,
                                  child: ElevatedButton(
                                      style: ButtonStylee.friendRequestCancel,
                                      onPressed: () {
                                        deleteFriendRequest();
                                        // ignore: use_build_context_synchronously
                                      },
                                      child:
                                          const Icon(FontAwesomeIcons.xmark)))
                            ],
                          ));
                    }).toList()),
              );
            }
          }),
      btnOkOnPress: () {},
    ).show();
  }

  void acceptedFriendRequest() async {
    await userNameAgeCollection
        //kimden dostluq gelib, onun uid-ne qebul etmek barede  melumat gonderirem
        .doc(Provider.of<MyProvider>(context, listen: false).fromUid)
        .collection("acceptedFriendRequest")
        //hazirki user-in uid-i
        .doc(currentUser!.uid)
        .set(
      {
        "fromNick":
            Provider.of<MyProvider>(context, listen: false).currentProfileNick,
        "fromProfileImage":
            Provider.of<MyProvider>(context, listen: false).currentProfileImage,
        "fromUid": currentUser!.uid,
        // "sendUid":Provider.of<MyProvider>(context, listen: false).uidFriend
      },
    ).whenComplete(() => acceptedFriendRequest1());
  }

  void acceptedFriendRequest1() async {
    await userNameAgeCollection
        //kimden dostluq gelib, onun uid-ne qebul etmek barede  melumat gonderirem
        .doc(currentUser!.uid)
        .collection("acceptedFriendRequest")
        //hazirki user-in uid-i
        .doc(Provider.of<MyProvider>(context, listen: false).fromUid)
        .set(
      {
        "fromNick":
            Provider.of<MyProvider>(context, listen: false).acceptedNick,
        "fromProfileImage":
            Provider.of<MyProvider>(context, listen: false).acceptedImage,
        "fromUid": Provider.of<MyProvider>(context, listen: false).fromUid,
        // "sendUid":Provider.of<MyProvider>(context, listen: false).uidFriend
      },
    );
  }

  void deleteFriend() async {
    await userNameAgeCollection
        //kimden dostluq gelib, onun uid-ne qebul etmek barede  melumat gonderirem
        .doc(Provider.of<MyProvider>(context, listen: false).deleteUid)
        .collection("acceptedFriendRequest")
        //hazirki user-in uid-i
        .doc(currentUser!.uid)
        .delete()
        .whenComplete(() => deleteFriend1());
  }

  void deleteFriend1() async {
    await userNameAgeCollection
        //kimden dostluq gelib, onun uid-ne qebul etmek barede  melumat gonderirem
        .doc(currentUser!.uid)
        .collection("acceptedFriendRequest")
        //hazirki user-in uid-i
        .doc(Provider.of<MyProvider>(context, listen: false).deleteUid)
        .delete();
  }

  void deleteFriendRequest() async {
    await userNameAgeCollection
        .doc(currentUser!.uid)
        .collection("userFriendRequest")
        .doc(
            Provider.of<MyProvider>(context, listen: false).deleteFriendRequest)
        .delete();
  }

  Stream<List<String>> fetchGroupNames() {
    return groupMessageCollection
        .doc(currentUser!.uid)
        .collection("groupMessages") // Replace with your collection name
        .snapshots()
        .map((QuerySnapshot snapshot) {
      return snapshot.docs.map((DocumentSnapshot document) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        return data['groupName'] as String;
      }).toList();
    });
  }
}
