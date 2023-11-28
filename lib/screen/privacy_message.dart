import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:chatapp/screen/search_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../const/button_style.dart';
import '../const/textformfield.dart';
import '../const/textstyle.dart';
import '../model/users_model.dart';
import '../provider/provider.dart';
import '../snackbar/snackbar_show.dart';

class PrivacyMessage extends StatefulWidget {
  //final UsersInfo userModel;

  const PrivacyMessage({
    super.key,
  });

  @override
  State<PrivacyMessage> createState() => _PrivacyMessageState();
}

UserData userData = UserData();

class _PrivacyMessageState extends State<PrivacyMessage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;
  TextEditingController messageController = TextEditingController();
  bool emojiShowing = false;
  File? _pickedImage;
  bool isUploading = true;
  late final ScrollController scrollController;
  late final FirebaseFirestore _firestore;
  late final FirebaseAuth _firebaseAuth;
  late final CollectionReference userNameAgeCollection;
  late final User? currentUser;
  late final ref = FirebaseDatabase.instance.ref().child("users");

  @override
  void initState() {
    scrollController = ScrollController();
    _firestore = FirebaseFirestore.instance;
    _firebaseAuth = FirebaseAuth.instance;
    userNameAgeCollection = _firestore.collection("userNameAgeInfo");
    currentUser = _firebaseAuth.currentUser;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _animation = Tween<Offset>(
      begin: const Offset(0.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();

    // Auto-dismiss the message after 3 seconds
    Future.delayed(const Duration(seconds: 2), () {
      _animationController.reverse();
    });
    super.initState();
  }

  @override
  void dispose() {
    messageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: StreamBuilder<QuerySnapshot>(
          stream: userNameAgeCollection
              .doc(currentUser!.uid)
              .collection("chatMessages")
              .doc(Provider.of<MyProvider>(context, listen: false).currentUid)
              .collection("messages")
              .orderBy('timestamp2', descending: false)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
              return Center(
                  child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(fontSize: 20),
              ));
            }
            if (!snapshot.hasData) {
              return const SpinKitSpinningLines(
                lineWidth: 10,
                itemCount: 10,
                color: Colors.orange,
                size: 100.0,
              );
            }
            List<DocumentSnapshot> documents = snapshot.data!.docs;
            return Scaffold(
              appBar: AppBar(
                toolbarHeight: 60,
                centerTitle: false,
                leadingWidth: 100,
                elevation: 3,
                backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
                title: Column(
                  children: [
                    Column(
                      children: [
                        Text(
                          Provider.of<MyProvider>(context, listen: false).nick,
                          style: const TextStyle(color: Colors.black),
                        ),
                        StreamBuilder<DatabaseEvent>(
                          stream: ref.onValue,
                          builder:
                              (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                            if (snapshot.hasData &&
                                !snapshot.hasError &&
                                snapshot.data!.snapshot.value != null) {
                              DataSnapshot dataValues = snapshot.data!.snapshot;
                              Map<dynamic, dynamic> data =
                                  dataValues.value as Map<dynamic, dynamic>;
                              String status = data[Provider.of<MyProvider>(
                                      context,
                                      listen: false)
                                  .currentUid]["status"];
                              //print(data);
                              // Display data
                              return Text(
                                status.toString(),
                                style: TextStyle(
                                    color: status == "online"
                                        ? Colors.green
                                        : Colors.red,
                                    fontSize: 17),
                              );
                            } else if (snapshot.hasError) {
                              // Display error message
                              return Text('Error: ${snapshot.error}');
                            } else {
                              // Display loading spinner
                              return const CircularProgressIndicator();
                            }
                          },
                        )
                      ],
                    ),
                    // Text(
                    //   widget.userModel.text,
                    //   style: TextStyle(
                    //     color: widget.userModel.color,
                    //     fontSize: 15,
                    //   ),
                    // ),
                  ],
                ),
                leading: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const BackButton(
                      color: Colors.black,
                    ),
                    CircleAvatar(
                        backgroundImage: NetworkImage(
                      Provider.of<MyProvider>(context, listen: false).image,
                    )),
                  ],
                ),
                actions: [
                  Row(children: [
                    IconButton(
                        onPressed: () {
                          showFriendRequest(context);
                        },
                        icon: const Icon(
                          FontAwesomeIcons.userGroup,
                          color: Colors.black,
                        )),
                    // IconButton(
                    //     onPressed: () {
                    //       setState(() {
                    //         sendFriendRequest();
                    //       });
                    //     },
                    //     icon:const Icon(
                    //       FontAwesomeIcons.userPlus,
                    //       color: Colors.black,
                    //     )),
                    IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SearchPage()),
                          );
                        },
                        icon: const Icon(
                          Icons.search,
                          color: Colors.black,
                        )),
                  ]),
                ],
              ),
              body: Container(
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/amalo.jpeg"),
                      fit: BoxFit.cover),
                ),
                child: SafeArea(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height / 1.2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: ListView.builder(
                              controller: scrollController,
                              shrinkWrap: true,
                              itemCount: documents
                                  .length, //snapshot.data!.docs.length + 1,
                              physics: const ScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {
                                Map<String, dynamic> doc = documents[index]
                                    .data() as Map<String, dynamic>;
                                if (index == snapshot.data!.docs.length) {
                                  return Container(
                                    height: 70,
                                  );
                                }

                                Provider.of<MyProvider>(context, listen: false)
                                    .message = doc["message"];

                                //DocumentSnapshot doc = snapshot.data!.docs[index];
                                return ListTile(
                                  title: Align(
                                    alignment:
                                        currentUser!.uid == doc["senderId"]
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                    child: Text(
                                      Provider.of<MyProvider>(context,
                                                      listen: false)
                                                  .currentProfileNick ==
                                              doc["senderNick"]
                                          ? doc["senderNick"]
                                          : doc["senderNick"],
                                      style: const TextStyle(
                                          fontSize: 15, color: Colors.black),
                                    ),
                                  ),
                                  subtitle: Align(
                                    alignment:
                                        currentUser!.uid == doc["senderId"]
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                    child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      'Delete Message'),
                                                  content: const Text(
                                                      'Are you sure you want to delete this message?'),
                                                  actions: [
                                                    TextButton(
                                                      child:
                                                          const Text('Cancel'),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                    TextButton(
                                                      child:
                                                          const Text('Delete'),
                                                      onPressed: () async {
                                                        DocumentSnapshot
                                                            documentSnapshot =
                                                            snapshot.data!
                                                                .docs[index];
                                                        await userNameAgeCollection
                                                            .doc(currentUser!
                                                                .uid)
                                                            .collection(
                                                                "chatMessages")
                                                            .doc(Provider.of<
                                                                        MyProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .currentUid)
                                                            .collection(
                                                                "messages")
                                                            .doc(
                                                                documentSnapshot
                                                                    .id)
                                                            .delete();

                                                        // ignore: use_build_context_synchronously
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          });
                                        },
                                        child: doc["messageType"] == "text"
                                            ? SlideTransition(
                                                position: _animation,
                                                child: Align(
                                                  alignment: currentUser!.uid ==
                                                          doc["senderId"]
                                                      ? Alignment.centerRight
                                                      : Alignment.centerLeft,
                                                  child: Padding(
                                                    padding: currentUser!
                                                                    .uid ==
                                                                doc["senderId"] ? const EdgeInsets.only(left:32.0) : EdgeInsets.only(right:32.0) ,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color: currentUser!
                                                                      .uid ==
                                                                  doc["senderId"]
                                                              ? Colors.lightGreen
                                                              : Colors.grey,
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .only(
                                                            topLeft: Radius.circular(
                                                                20.0), // Radius for top left corner
                                                            bottomRight:
                                                                Radius.circular(
                                                                    30.0),
                                                          )),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                       doc["message"].length >20 ?   Expanded(
                                                        
                                                            child:  Text(
                                                                doc["message"],
                                                                //  overflow: TextOverflow.ellipsis,
                                                                //maxLines:10,
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                          
                                                          ) :  Text(
                                                              doc["message"],
                                                              //  overflow: TextOverflow.ellipsis,
                                                              //maxLines:10,
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          const SizedBox(
                                                            width: 20,
                                                          ),
                                                          Column(
                                                            children: [
                                                              Text(
                                                                doc["timestamp"],
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            11),
                                                              ),
                                                              Text(
                                                                doc["timestamp1"],
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            11),
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ))
                                            : Container(
                                                decoration: BoxDecoration(
                                                    color: currentUser!.uid ==
                                                            doc["senderId"]
                                                        ? Colors.lightGreen
                                                        : Colors.grey,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                                // index % 2 == 0 ? 16 : 160),
                                                padding:
                                                    const EdgeInsets.all(16),
                                                child: Column(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(context,
                                                            MaterialPageRoute(
                                                                builder: (_) {
                                                          return Scaffold(
                                                            backgroundColor:
                                                                Colors.white,
                                                            appBar: AppBar(
                                                              elevation: 0,
                                                              backgroundColor:
                                                                  Colors.white,
                                                              actions: [
                                                                IconButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    icon:
                                                                        const Icon(
                                                                      Icons
                                                                          .cancel,
                                                                      color: Colors
                                                                          .red,
                                                                    )),
                                                              ],
                                                            ),
                                                            body: Center(
                                                              child: Image
                                                                  .network(doc[
                                                                      "message"]),
                                                            ),
                                                          );
                                                        }));
                                                      },
                                                      child: isUploading ==
                                                              false
                                                          ? const CircularProgressIndicator()
                                                          : Image.network(
                                                              doc["message"],
                                                              width: 100,
                                                              height: 100,
                                                              fit: BoxFit.cover,
                                                            ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      doc["timestamp"],
                                                      style: const TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                      doc["timestamp1"],
                                                      style: const TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ],
                                                ))),
                                  ),
                                );
                              }),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 14.0, right: 14),
                                    child: TextField(
                                      // enabled: Provider.of<MyProvider>(context, listen: false).dataAccept,
                                      onTap: () {
                                        if (emojiShowing) {
                                          setState(() =>
                                              emojiShowing = !emojiShowing);
                                        }
                                      },
                                      controller: messageController,
                                      decoration: InputDecoration(
                                          hintText: "enter the message",
                                          fillColor:
                                              Colors.grey.withOpacity(0.3),
                                          filled: true,
                                          enabledBorder: messageContainer,
                                          focusedBorder: messageContainer,
                                          suffixIcon: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    AwesomeDialog(
                                                      context: context,
                                                      animType:
                                                          AnimType.bottomSlide,
                                                      dialogType:
                                                          DialogType.success,
                                                      body: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          SizedBox(
                                                              height: 90,
                                                              width: 100,
                                                              child:
                                                                  ElevatedButton(
                                                                      onPressed:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          pickImageCamera();
                                                                        });
                                                                      },
                                                                      child:
                                                                          const Text(
                                                                        "camera",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                17,
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      ))),
                                                          const SizedBox(
                                                            width: 50,
                                                          ),
                                                          SizedBox(
                                                              height: 90,
                                                              width: 100,
                                                              child:
                                                                  ElevatedButton(
                                                                      onPressed:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          pickImageGallery();
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        });
                                                                      },
                                                                      child: const Text(
                                                                          "gallery",
                                                                          style: TextStyle(
                                                                              fontSize: 17,
                                                                              fontWeight: FontWeight.bold)))),
                                                        ],
                                                      ),
                                                      title: 'This is Ignored',
                                                      desc:
                                                          'This is also Ignored',
                                                      btnOkOnPress: () {},
                                                    ).show();
                                                  });
                                                },
                                                icon: const Icon(
                                                    Icons.attach_file),
                                              ),
                                              IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      FocusScope.of(context)
                                                          .unfocus();
                                                      emojiShowing =
                                                          !emojiShowing;
                                                    });
                                                  },
                                                  icon: const Icon(
                                                      Icons.emoji_emotions)),
                                            ],
                                          )),
                                    )),
                              ),
                            ),
                            IconButton(
                                onPressed: () {
                                  scrollDown();
                                  setState(() {
                                    if (messageController.text.isEmpty) {
                                      showEmptyMessage(context);
                                    } else {
                                      Provider.of<MyProvider>(context,
                                              listen: false)
                                          .disabledButton = true;
                                      // addNickImage();
                                      sendMessage();
                                      userSendMessage();
                                      userTalkList();
                                      userTalkListt();
                                    }
                                    messageController.clear();
                                    print(DateFormat("HH:mm:ss")
                                        .format(DateTime.now()));
                                  });
                                },
                                icon: const Icon(Icons.send))
                          ],
                        ),
                        if (emojiShowing)
                          SizedBox(
                            height: 200,
                            child: EmojiPicker(
                              textEditingController:
                                  messageController, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                              config: Config(
                                bgColor: Colors.white,
                                iconColor: Colors.green,
                                columns: 8,
                                emojiSizeMax: 30 *
                                    (Platform.isIOS
                                        ? 1.30
                                        : 1.0), // Issue: https://github.com/flutter/flutter/issues/28894
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              floatingActionButton: Stack(children: [
                Positioned(
                  bottom: 100,
                  right: 0,
                  child: FloatingActionButton(
                    onPressed: Provider.of<MyProvider>(context, listen: false)
                                    .disabledButton ==
                                false ||
                            documents.length < 1 - 0
                        ? null
                        : () {
                            setState(() {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Delete Messages'),
                                    content: const Text(
                                        'Are you sure you want to delete all messages?'),
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
                                          Provider.of<MyProvider>(context,
                                                  listen: false)
                                              .disabledButton = false;
                                          QuerySnapshot querySnapshot =
                                              await userNameAgeCollection
                                                  .doc(currentUser!.uid)
                                                  .collection("chatMessages")
                                                  .doc(Provider.of<MyProvider>(
                                                          context,
                                                          listen: false)
                                                      .currentUid)
                                                  .collection("messages")
                                                  .get();
                                          for (var document
                                              in querySnapshot.docs) {
                                            document.reference.delete();
                                          }
                                          // ignore: use_build_context_synchronously
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            });
                          },
                    backgroundColor:
                        Provider.of<MyProvider>(context, listen: false)
                                        .disabledButton ==
                                    false ||
                                documents.length < 1 - 0
                            ? Colors.grey
                            : Colors.red,
                    child: const Icon(Icons.delete),
                  ),
                ),
              ]),
            );
          }),
    );
  }

// qaleriyadan sekil goturmek ucun
  void pickImageGallery() async {
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
    Provider.of<MyProvider>(context, listen: false).url = await ref
        .getDownloadURL()
        .whenComplete(
            () => Future.delayed(const Duration(seconds: 4)).whenComplete(() {
                  setState(() {
                    sendImage();
                  
                  });
                }));
    // ignore: use_build_context_synchronously
    // print(Provider.of<MyProvider>(context, listen: false).url);
    // print(_pickedImage);
  }

// kamera ile cekilen sekili goturmek ucun
  void pickImageCamera() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);
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
        await ref.getDownloadURL();
    // ignore: use_build_context_synchronously
    // print(Provider.of<MyProvider>(context, listen: false).url);
    // print(_pickedImage);
  }

//mesaji gonderenin  ekraninda  gonderdiyi mesaji gormesi ucun
  void sendMessage() async {
    await userNameAgeCollection
        .doc(currentUser!.uid)
        .collection("chatMessages")
        .doc(Provider.of<MyProvider>(context, listen: false).currentUid)
        .collection("messages")
        .add({
      'message': messageController.text,
      'messageType': "text",
      'senderId': currentUser!.uid,
      'senderNick':
          Provider.of<MyProvider>(context, listen: false).currentProfileNick,
      "receiverId": Provider.of<MyProvider>(context, listen: false).currentUid,
      'receiverNick': Provider.of<MyProvider>(context, listen: false).nick,
      'timestamp': DateFormat("dd-MM-yyyy").format(DateTime.now()),
      'timestamp1': DateFormat("hh:mm").format(DateTime.now()),
      "timestamp2": FieldValue.serverTimestamp(),
    });
  }

//sekili  gonderenin  ekraninda  gonderdiyi sekili gormesi ucun
  void sendImage() async {
    await userNameAgeCollection
        .doc(currentUser!.uid)
        .collection("chatMessages")
        .doc(Provider.of<MyProvider>(context, listen: false).currentUid)
        .collection("messages")
        .add({
      'message': Provider.of<MyProvider>(context, listen: false).url,
      'messageType': "image",
      'senderId': currentUser!.uid,
      'senderNick':
          Provider.of<MyProvider>(context, listen: false).currentProfileNick,
      "receiverId": Provider.of<MyProvider>(context, listen: false).currentUid,
      'timestamp': DateFormat("dd-MM-yyyy").format(DateTime.now()),
      'timestamp1': DateFormat("hh:mm").format(DateTime.now()),
      "timestamp2": FieldValue.serverTimestamp(),
    }).whenComplete(() => userSendImage());
  }

//qarsi terefe mesaj gondermek ucun
  void userSendMessage() async {
    await userNameAgeCollection
        .doc(Provider.of<MyProvider>(context, listen: false).currentUid)
        .collection("chatMessages")
        .doc(currentUser!.uid)
        .collection("messages")
        .add({
      'message': messageController.text,
      'messageType': "text",
      'senderId': currentUser!.uid,
      'senderNick':
          Provider.of<MyProvider>(context, listen: false).currentProfileNick,
      "receiverId": Provider.of<MyProvider>(context, listen: false).currentUid,
      'receiverNick': Provider.of<MyProvider>(context, listen: false).nick,
      'timestamp': DateFormat("dd-MM-yyyy").format(DateTime.now()),
      'timestamp1': DateFormat("hh:mm").format(DateTime.now()),
      "timestamp2": FieldValue.serverTimestamp(),
    });
  }

//qarsi terefe sekil gondermek ucun
  void userSendImage() async {
    await userNameAgeCollection
        .doc(Provider.of<MyProvider>(context, listen: false).currentUid)
        .collection("chatMessages")
        .doc(currentUser!.uid)
        .collection("messages")
        .add({
      'message': Provider.of<MyProvider>(context, listen: false).url,
      'messageType': "image",
      'senderId': currentUser!.uid,
      'senderNick':
          Provider.of<MyProvider>(context, listen: false).currentProfileNick,
      "receiverId": Provider.of<MyProvider>(context, listen: false).currentUid,
      'timestamp': DateFormat("dd-MM-yyyy").format(DateTime.now()),
      'timestamp1': DateFormat("hh:mm").format(DateTime.now()),
      "timestamp2": FieldValue.serverTimestamp(),
    });
  }

// ana ekranda kiminle  danisdigimi gormek ucun
  void userTalkList() async {
    await userNameAgeCollection
        .doc(currentUser!.uid)
        .collection("chatMessages")
        .doc(Provider.of<MyProvider>(context, listen: false).currentUid)
        .set({
      "nickList": Provider.of<MyProvider>(context, listen: false).nick,
      "imageList": Provider.of<MyProvider>(context, listen: false).image,
      "lastMessage": messageController.text,
      "usersUid": Provider.of<MyProvider>(context, listen: false).currentUid,
      'timestamp': DateFormat("dd-MM-yyyy").format(DateTime.now()),
      'timestamp1': DateFormat("hh:mm").format(DateTime.now()),
    });
  }

// ana ekranda kimden mesaj geldiyini gormek ucun
  void userTalkListt() async {
    await userNameAgeCollection
        .doc(Provider.of<MyProvider>(context, listen: false).currentUid)
        .collection("chatMessages")
        .doc(currentUser!.uid)
        .set({
      "nickList":
          Provider.of<MyProvider>(context, listen: false).currentProfileNick,
      "imageList":
          Provider.of<MyProvider>(context, listen: false).currentProfileImage,
      "lastMessage": messageController.text,
      "usersUid": currentUser!.uid,
      'timestamp': DateFormat("dd-MM-yyyy").format(DateTime.now()),
      'timestamp1': DateFormat("hh:mm").format(DateTime.now()),
    });
  }

  // ekran mesaj ile dolanda avtomatik olaraq asagi dusmesi ucun
  void scrollDown() async {
    await scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

//dostluq sorgusu
  void sendFriendRequest() async {
    await userNameAgeCollection
        .doc(Provider.of<MyProvider>(context, listen: false).uidFriend)
        .collection("userFriendRequest")
        .doc(currentUser!.uid)
        .set({
      "fromNick":
          Provider.of<MyProvider>(context, listen: false).currentProfileNick,
      "fromImage":
          Provider.of<MyProvider>(context, listen: false).currentProfileImage,
      "fromUid": currentUser!.uid,
      // "sendUid":Provider.of<MyProvider>(context, listen: false).uidFriend
    });
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
                                        print(Provider.of<MyProvider>(context,
                                                listen: false)
                                            .fromUid);
                                        acceptedFriendRequest();
                                        //acceptedFriendRequest2();
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
                                      onPressed: () async {
                                        DocumentSnapshot documentSnapshot =
                                            snapshotFriend.data!.docs[0];
                                        await userNameAgeCollection
                                            .doc(currentUser!.uid)
                                            .collection("userFriendRequest")
                                            .doc(documentSnapshot.id)
                                            .delete();

                                        // ignore: use_build_context_synchronously
                                        Navigator.pop(context);
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
        .update(
      {
        "currentNick":
            Provider.of<MyProvider>(context, listen: false).currentProfileNick,
        "accepted": true,
        "currentUid": currentUser!.uid,
        // "sendUid":Provider.of<MyProvider>(context, listen: false).uidFriend
      },
    ).whenComplete(() => acceptedFriendRequest2());
  }

  void acceptedFriendRequest2() async {
    await userNameAgeCollection
        //kimden dostluq gelib, onun uid-ne qebul etmek barede  melumat gonderirem
        .doc(currentUser!.uid)
        .collection("acceptedFriendRequest")
        //hazirki user-in uid-i
        .doc(Provider.of<MyProvider>(context, listen: false).fromUid)
        .set(
      {
        "accepted": true,

        // "sendUid":Provider.of<MyProvider>(context, listen: false).uidFriend
      },
    );
  }
}
