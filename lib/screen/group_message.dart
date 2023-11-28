import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../const/textformfield.dart';
import '../const/textstyle.dart';
import '../provider/provider.dart';

class GroupNamesScreen extends StatefulWidget {
  const GroupNamesScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _GroupNamesScreenState createState() => _GroupNamesScreenState();
}

class _GroupNamesScreenState extends State<GroupNamesScreen> {
  // late Stream<List<String>> _groupNamesStream;

  Future<void> createGroup(String groupName) async {
    // Add code to create the group in Firebase Firestore
    // ...

    // Fetch group names after creating the group
    // setState(() {
    //   _groupNamesStream = fetchGroupNames();
    // });
  }
  final TextEditingController _messageController = TextEditingController();
  late final FirebaseFirestore _firestore;
  late final FirebaseAuth _firebaseAuth;
  late final CollectionReference userNameAgeCollection;
  late final CollectionReference groupMessageCollection;
  late final User? currentUser;
  late String latestGroupName;
  @override
  void initState() {
    latestGroupName = "";
    _firestore = FirebaseFirestore.instance;
    _firebaseAuth = FirebaseAuth.instance;
    userNameAgeCollection = _firestore.collection("userNameAgeInfo");
    groupMessageCollection = _firestore.collection("groupMessages");
    currentUser = _firebaseAuth.currentUser;
    // _groupNamesStream = fetchGroupNames();
    fetchLatestGroupName();

    super.initState();
  }

  Future<void> fetchLatestGroupName() async {
    try {
      final QuerySnapshot snapshot = await userNameAgeCollection
          .doc(currentUser!.uid)
          .collection("groupMessages") // Replace with your collection name
          .orderBy('timestamp',
              descending:
                  true) // Replace 'timestamp' with the field representing the timestamp in your documents
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final DocumentSnapshot latestDoc = snapshot.docs.first;
        setState(() {
          latestGroupName = latestDoc.get('fromNick') as String;
        });
      } else {
        setState(() {
          latestGroupName = 'No group found';
        });
      }
    } catch (e) {
      setState(() {
        latestGroupName = 'Error fetching latest group name';
      });
      print('Error fetching latest group name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            Provider.of<MyProvider>(context, listen: false).groupName == ""
                ? latestGroupName
                : Provider.of<MyProvider>(context, listen: false).groupName),
        actions: [
          IconButton(
              onPressed: () {}, icon: const Icon(FontAwesomeIcons.userPlus)),
          IconButton(
              onPressed: () {
                showGroupUsers(context);
              },
              icon: const Icon(Icons.info))
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/amalo.jpeg"), fit: BoxFit.cover),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                  stream: userNameAgeCollection
                      .doc(currentUser!.uid)
                      .collection("groupMessages")
                      .doc(Provider.of<MyProvider>(context, listen: false)
                          .groupId)
                      .snapshots(),
                  builder: (context,
                      AsyncSnapshot<DocumentSnapshot> snapshotGroupUsers1) {
                    if (snapshotGroupUsers1.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshotGroupUsers1.hasError) {
                      return const Center(
                        child: Text('Error fetching data from Firebase'),
                      );
                    }

                    if (!snapshotGroupUsers1.hasData) {
                      return const Center(
                        child: Text('No data available'),
                      );
                    }

                    Map<String, dynamic> data2 = snapshotGroupUsers1.data!.data()
                         as Map<String, dynamic>;
                    Provider.of<MyProvider>(context, listen: false).membersUid =
                        List.castFrom(data2['membersUid']);
                    print(Provider.of<MyProvider>(context, listen: false)
                        .membersUid);
                    return StreamBuilder<QuerySnapshot>(
                      stream: userNameAgeCollection
                          .doc(currentUser!.uid)
                          .collection("groupMessages")
                          .doc(Provider.of<MyProvider>(context, listen: false)
                              .groupId)
                          .collection("messages")
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshotGroupMessages) {
                        if (snapshotGroupMessages.hasData) {
                          List<QueryDocumentSnapshot> messages =
                              snapshotGroupMessages.data!.docs.reversed
                                  .toList();

                          return ListView.builder(
                            reverse: true,
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> message = messages[index]
                                  .data() as Map<String, dynamic>;
                              return ListTile(
                                subtitle: Align(
                                    alignment:
                                        currentUser!.uid == message["senderId"]
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                    child: Container(
                                        decoration: BoxDecoration(
                                            color: currentUser!.uid ==
                                                    message["senderId"]
                                                ? Colors.lightBlue
                                                : Colors.grey,
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(
                                                  20.0), // Radius for top left corner
                                              bottomRight:
                                                  Radius.circular(30.0),
                                            )),
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              message['groupMessage'],
                                              style: messageStyle,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Column(
                                              children: [
                                                Text(
                                                  message["timestamp1"],
                                                  style: dateStyle,
                                                ),
                                                Text(
                                                  message["timestamp2"],
                                                  style: dateStyle,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ))),
                                title: Align(
                                  alignment:
                                      currentUser!.uid == message["senderId"]
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                  child: Text(
                                    Provider.of<MyProvider>(context,
                                                    listen: false)
                                                .currentProfileNick ==
                                            message["nick"]
                                        ? message["nick"]
                                        : message["nick"],
                                    style: const TextStyle(
                                        fontSize: 15, color: Colors.black),
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    );
                  }),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 14.0, right: 14, bottom: 15),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Enter message',
                          fillColor: Colors.grey.withOpacity(0.3),
                          filled: true,
                          enabledBorder: messageContainer,
                          focusedBorder: messageContainer,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: IconButton(
                      onPressed: () {
                               
                       // groupChatCurrent();
                        groupChatAllUser();
                        // print( Provider.of<MyProvider>(context, listen: false).membersUid);
                        print(Provider.of<MyProvider>(context, listen: false)
                            .membersNick);
                             
                      },
                      icon: const Icon(Icons.send),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showGroupUsers(BuildContext context) {
    AwesomeDialog(
      context: context,
      animType: AnimType.bottomSlide,
      dialogType: DialogType.success,
      body: Column(children: [
        Text(
          "Group users",
          style: groupUsersHeader,
        ),
        StreamBuilder<DocumentSnapshot>(
            stream: userNameAgeCollection
                .doc(currentUser!.uid)
                .collection("groupMessages")
                .doc(Provider.of<MyProvider>(context, listen: false).groupId)
                .snapshots(),
            builder:
                (context, AsyncSnapshot<DocumentSnapshot> snapshotGroupUsers) {
              if (snapshotGroupUsers.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshotGroupUsers.hasError) {
                return const Center(
                  child: Text('Error fetching data from Firebase'),
                );
              }

              if (!snapshotGroupUsers.hasData) {
                return const Center(
                  child: Text('No data available'),
                );
              }

              Map<String, dynamic> data1 =
                  snapshotGroupUsers.data!.data() as Map<String, dynamic>;
              Provider.of<MyProvider>(context, listen: false).membersNick =
                  List.castFrom(data1['membersNick']);
              // Provider.of<MyProvider>(context, listen: false).membersUid = List.castFrom(data1['membersUid']);

              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: Provider.of<MyProvider>(context, listen: false)
                      .membersNick
                      .length,
                  itemBuilder: (context, index) {
                    // final groupData =
                    //     data1[index].data() as Map<String, dynamic>;
                    // final groupId = data1[index].id;

                    return Provider.of<MyProvider>(context, listen: false)
                                .currentProfileNick ==
                            Provider.of<MyProvider>(context, listen: false)
                                .membersNick[index]
                        ? ListTile(
                            title: Row(
                              children: [
                                Text(
                                  Provider.of<MyProvider>(context,
                                          listen: false)
                                      .membersNick[index]
                                      .toString(),
                                  style: groupUsersColor,
                                ),
                                const Text(" (you)")
                              ],
                            ),

                            // Column(
                            //   crossAxisAlignment: CrossAxisAlignment.start,
                            //   children: members
                            //       .map((member) => Text('Member: $member'))
                            //       .toList(),
                            // ),
                          )
                        : ListTile(
                            title: Text(
                              Provider.of<MyProvider>(context, listen: false)
                                  .membersNick[index]
                                  .toString(),
                              style: groupUsersColor,
                            ),

                            // Column(
                            //   crossAxisAlignment: CrossAxisAlignment.start,
                            //   children: members
                            //       .map((member) => Text('Member: $member'))
                            //       .toList(),
                            // ),
                          );
                  });
            })
      ]),
      btnOkOnPress: () {},
    ).show();
  }

  // void groupChatCurrent() async {
 
  //     await userNameAgeCollection
  //         .doc(currentUser!.uid)
  //         .collection("groupMessages")
  //         .doc(Provider.of<MyProvider>(context, listen: false).groupId)
  //         .collection("messages")
  //         .add({
  //       "messageId": "messageId",
  //       "groupMessage": _messageController.text,
  //       'senderId': currentUser!.uid,
  //       "nick":
  //           Provider.of<MyProvider>(context, listen: false).currentProfileNick,
  //       'timestamp': DateTime.now().millisecondsSinceEpoch,
  //       'timestamp1': DateFormat("dd-MM-yyyy").format(DateTime.now()),
  //       'timestamp2': DateFormat("hh:mm").format(DateTime.now()),
  //     }).whenComplete(() => groupChatAllUser());
    
  // }

  void groupChatAllUser() async {

   
      // ignore: dead_code, avoid_function_literals_in_foreach_calls
 Provider.of<MyProvider>(context, listen: false)
          .membersUid.forEach((element)async { 
        await userNameAgeCollection
            .doc(element)
            .collection("groupMessages")
            .doc(Provider.of<MyProvider>(context, listen: false).groupId)
            .collection("messages")
            .add({
          "groupMessage": _messageController.text,
         'recipientUid': Provider.of<MyProvider>(context, listen: false)
          .membersUid,
          'senderId': currentUser!.uid,
          "nick": Provider.of<MyProvider>(context, listen: false)
              .currentProfileNick,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'timestamp1': DateFormat("dd-MM-yyyy").format(DateTime.now()),
          'timestamp2': DateFormat("hh:mm").format(DateTime.now()),
        }).whenComplete(() => _messageController.clear()).whenComplete(() => Provider.of<MyProvider>(context, listen: false)
          .membersUid.clear());
      });
   
  }
}
