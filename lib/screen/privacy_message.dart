import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/users_model.dart';
import '../provider/provider.dart';

class PrivacyMessage extends StatefulWidget {
  //final UsersInfo userModel;

  const PrivacyMessage({
    super.key,
  });

  @override
  State<PrivacyMessage> createState() => _PrivacyMessageState();
}

UserData userData = UserData();

class _PrivacyMessageState extends State<PrivacyMessage> {
  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();
  late final FirebaseFirestore _firestore;
  late final FirebaseAuth _firebaseAuth;
  late final CollectionReference chatCollection;
  late final CollectionReference userNameAgeCollection;
  late final CollectionReference getMessage;
  late final User? currentUser;
  @override
  void initState() {
    _firestore = FirebaseFirestore.instance;
    _firebaseAuth = FirebaseAuth.instance;
    chatCollection = _firestore.collection("chatMessages");
    userNameAgeCollection = _firestore.collection("userNameAgeInfo");
    getMessage =  _firestore.collection("getessage");

    currentUser = _firebaseAuth.currentUser;
    super.initState();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: chatCollection
            .doc(currentUser!.uid)
            .collection(
                "userMessages${Provider.of<MyProvider>(context, listen: false).uid}")
           
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return Scaffold(
            appBar: AppBar(
                toolbarHeight: 60,
                centerTitle: false,
                leadingWidth: 100,
                elevation: 2,
                backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
                title: Column(
                  children: [
                    Text(
                      Provider.of<MyProvider>(context, listen: false).nick,
                      style: const TextStyle(color: Colors.black),
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
                  IconButton(
                      onPressed: (() {}),
                      icon: Row(
                        children: const [
                          Icon(
                            Icons.phone,
                            color: Colors.black,
                          ),
                        ],
                      )),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.search,
                        color: Colors.black,
                      ))
                ]),
            body: SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height / 1.2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: ListView.builder(
                          controller: scrollController,
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length + 1,
                          physics: const ScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            if (index == snapshot.data!.docs.length) {
                              return Container(
                                height: 70,
                              );
                            }
                            DocumentSnapshot doc = snapshot.data!.docs[index];
                            return ListTile(
                                title: Align(
                              alignment: currentUser!.uid == doc["sender"]
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: currentUser!.uid == doc["sender"]
                                        ? Colors.pink.shade200
                                        : Colors.green,
                                    borderRadius: BorderRadius.circular(20)),
                                // index % 2 == 0 ? 16 : 160),
                                padding: const EdgeInsets.all(16),
                                child: Text(doc["message"]),
                              ),
                            ));
                          }),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: TextField(
                                controller: messageController,
                                decoration: InputDecoration(
                                    hintText: "enter the message",
                                    fillColor: Colors.grey.withOpacity(0.3),
                                    filled: true,
                                    icon: const Icon(
                                      Icons.attach_file,
                                      color: Colors.black,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: const BorderSide(
                                            width: 1,
                                            color: Colors.transparent)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: const BorderSide(
                                            width: 1,
                                            color: Colors.transparent)),
                                    suffixIcon: const Icon(
                                      Icons.emoji_emotions_rounded,
                                      color: Colors.black,
                                    )),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                //userData.messageContainer.add(data["message"]);
                                // sendMessage();
                                addMessage();
                               // usersMessage();
                                messageController.clear();
                                scrollDown();
                              });
                            },
                            icon: const Icon(Icons.send))
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

// void addMessage() {
//     Map<String, String> message = {
//       "message": messageController.text,
//       'messageType': "sender",
//       'sender': currentUser!.uid,
//       'timestamp': DateTime.now() as String,
//     };
//     chatCollection
//         .doc(currentUser!.uid)
//         .set(message, SetOptions(merge: true));

//   }
// void sendMessage() {

//   FirebaseFirestore.instance.collection('chatMessages').doc(currentUser!.uid).collection("chatMessages${Provider.of<MyProvider>(context, listen: false).uid}").add({
//     'senderUid': currentUser!.uid,
//     'receiverUid': Provider.of<MyProvider>(context, listen: false).uid,
//     'message': messageController.text,
//     'timestamp': FieldValue.serverTimestamp(),
//   });
// }
  void addMessage() {
    FirebaseFirestore.instance
        .collection("chatMessages")
        .doc(currentUser!.uid)
        .collection(
            "userMessages${Provider.of<MyProvider>(context, listen: false).uid}")
        .add({
      'message': messageController.text,
      'messageType': "sender",
      'sender': currentUser!.uid,
      'timestamp': DateTime.now(),
    });
  }

  void usersMessage() {
    FirebaseFirestore.instance
        .collection("chatMessages")
        .doc(
          Provider.of<MyProvider>(context, listen: false).uid,
        )
        .collection("userMessages${Provider.of<MyProvider>(context, listen: false).uid}")
        .add({
      'message': messageController.text,
      'messageType': "sender",
      'receiver': Provider.of<MyProvider>(context, listen: false).uid,
      //'sender': currentUser!.uid,
      'timestamp': DateTime.now(),
    });

   }

  void scrollDown() async {
    await scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }
}
