// import 'package:awesome_dialog/awesome_dialog.dart';
// import 'package:chatapp/model/users_model.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:intl/intl.dart';

// import '../const/textformfield.dart';

// class ChatsPage extends StatefulWidget {
//   const ChatsPage({super.key});

//   @override
//   State<ChatsPage> createState() => _ChatsPageState();
// }

// class _ChatsPageState extends State<ChatsPage> {
//   TextEditingController messageController = TextEditingController();
//   late final FirebaseFirestore _firestore;
//   late final FirebaseAuth _firebaseAuth;
//   late final CollectionReference commonMessages;
//   late final CollectionReference userNameAgeCollection;
//   late final User? currentUser;
//   // late final AnimationController _animationController;
//   // late  final Animation<Offset> _animation;

//     bool isUploading = true;
//   void initState() {
//     _firestore = FirebaseFirestore.instance;
//     _firebaseAuth = FirebaseAuth.instance;
//     commonMessages = _firestore.collection("commonMessages");
//      userNameAgeCollection = _firestore.collection("userNameAgeInfo");
//     currentUser = _firebaseAuth.currentUser;

//     // Auto-dismiss the message after 3 seconds

//     super.initState();
//   }

//   @override
//   void dispose() {
//     messageController.dispose();

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//         stream: userNameAgeCollection
//             .doc(currentUser!.uid)
//             .collection("commonChatMessages")

//             .orderBy('timestamp2', descending: false)
//             .snapshots(),
//         builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (snapshot.hasError) {
//             print(snapshot.error);
//             return Center(
//                 child: Text(
//               'Error: ${snapshot.error}',
//               style: const TextStyle(fontSize: 20),
//             ));
//           }
//           if (!snapshot.hasData) {
//             return const SpinKitSpinningLines(
//               lineWidth: 10,
//               itemCount: 10,
//               color: Colors.orange,
//               size: 100.0,
//             );
//           }
//           List<DocumentSnapshot> documents = snapshot.data!.docs;
//           return Scaffold(
//             appBar: AppBar(
//               title: const Text("Chats with all users"),
//             ),
//             body: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: ListView.builder(
//                       shrinkWrap: true,
//                       itemCount: documents.length,
//                       itemBuilder: (BuildContext context, int index) {
//                         Map<String, dynamic> doc =
//                             documents[index].data() as Map<String, dynamic>;
//                         if (index == snapshot.data!.docs.length) {
//                           return Container(
//                             height: 70,
//                           );
//                         }

//                           return ListTile(
//                                     title: Align(
//                                   alignment: currentUser!.uid == doc["senderId"]
//                                       ? Alignment.centerRight
//                                       : Alignment.centerLeft,
//                                   child: Padding(
//                                     padding: const EdgeInsets.only(top: 15.0),
//                                     child: GestureDetector(
//                                         onTap: () {

//                                         },
//                                         child: doc["messageType"] == "text"
//                                             ? Container(
//                                               decoration: BoxDecoration(
//                                                   color: currentUser!.uid ==
//                                                           doc["senderId"]
//                                                       ? Colors.lightGreen
//                                                       : Colors.grey,
//                                                   borderRadius:
//                                                       const BorderRadius
//                                                           .only(
//                                                     topLeft: Radius.circular(
//                                                         20.0), // Radius for top left corner
//                                                     bottomRight:
//                                                         Radius.circular(
//                                                             30.0),
//                                                   )),
//                                               // index % 2 == 0 ? 16 : 160),
//                                               padding:
//                                                   const EdgeInsets.all(16),
//                                               child: Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceBetween,
//                                                 mainAxisSize:
//                                                     MainAxisSize.min,
//                                                 children: [
//                                                   Column(
//                                                     children: [
//                                                       // Text(Provider.of<MyProvider>(
//                                                       //                 context,
//                                                       //                 listen:
//                                                       //                     false)
//                                                       //             .currentProfileNick ==
//                                                       //         doc[
//                                                       //             "senderNick"]
//                                                       //     ? doc[
//                                                       //         "senderNick"]
//                                                       //     : doc[
//                                                       //         "senderNick"],
//                                                       //         style: TextStyle(fontSize: 15,color: Colors.white),

//                                                       //         ),
//                                                       Text(
//                                                         doc["message"],
//                                                         style: const TextStyle(
//                                                             fontWeight:
//                                                                 FontWeight
//                                                                     .bold),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                   const SizedBox(
//                                                     width: 20,
//                                                   ),
//                                                   Column(
//                                                     children: [
//                                                       Text(
//                                                         doc["timestamp"],
//                                                         style:
//                                                             const TextStyle(
//                                                                 fontSize:
//                                                                     11),
//                                                       ),
//                                                       Text(
//                                                         doc["timestamp1"],
//                                                         style:
//                                                             const TextStyle(
//                                                                 fontSize:
//                                                                     11),
//                                                       ),
//                                                     ],
//                                                   )
//                                                 ],
//                                               ),
//                                             )
//                                             : Container(
//                                                 decoration: BoxDecoration(
//                                                     color: currentUser!.uid ==
//                                                             doc["senderId"]
//                                                         ? Colors.lightGreen
//                                                         : Colors.grey,
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             20)),
//                                                 // index % 2 == 0 ? 16 : 160),
//                                                 padding:
//                                                     const EdgeInsets.all(16),
//                                                 child: Column(
//                                                   children: [
//                                                     GestureDetector(
//                                                       onTap: () {
//                                                         Navigator.push(context,
//                                                             MaterialPageRoute(
//                                                                 builder: (_) {
//                                                           return Scaffold(
//                                                             backgroundColor:
//                                                                 Colors.white,
//                                                             appBar: AppBar(
//                                                               elevation: 0,
//                                                               backgroundColor:
//                                                                   Colors.white,
//                                                               actions: [
//                                                                 IconButton(
//                                                                     onPressed:
//                                                                         () {
//                                                                       Navigator.pop(
//                                                                           context);
//                                                                     },
//                                                                     icon:
//                                                                         const Icon(
//                                                                       Icons
//                                                                           .cancel,
//                                                                       color: Colors
//                                                                           .red,
//                                                                     )),
//                                                               ],
//                                                             ),
//                                                             body: Center(
//                                                               child: Image
//                                                                   .network(doc[
//                                                                       "message"]),
//                                                             ),
//                                                           );
//                                                         }));
//                                                       },
//                                                       child: isUploading ==
//                                                               false
//                                                           ? const CircularProgressIndicator()
//                                                           : Image.network(
//                                                               doc["message"],
//                                                               width: 100,
//                                                               height: 100,
//                                                               fit: BoxFit.cover,
//                                                             ),
//                                                     ),
//                                                     const SizedBox(
//                                                       height: 5,
//                                                     ),
//                                                     Text(
//                                                       doc["timestamp"],
//                                                       style: const TextStyle(
//                                                           fontSize: 11,
//                                                           fontWeight:
//                                                               FontWeight.bold),
//                                                     ),
//                                                     Text(
//                                                       doc["timestamp1"],
//                                                       style: const TextStyle(
//                                                           fontSize: 11,
//                                                           fontWeight:
//                                                               FontWeight.bold),
//                                                     ),
//                                                   ],
//                                                 ))),
//                                   ),
//                                 ));
//                       }),
//                 ),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: SizedBox(
//                         width: MediaQuery.of(context).size.width,
//                         child: Padding(
//                             padding: const EdgeInsets.only(
//                                 left: 14.0, right: 14, bottom: 20, top: 20),
//                             child: TextField(
//                               controller: messageController,
//                               // enabled: Provider.of<MyProvider>(context, listen: false).dataAccept,
//                               onTap: () {},
//                               //controller: messageController,
//                               decoration: InputDecoration(
//                                   hintText: "enter the message",
//                                   fillColor: Colors.grey.withOpacity(0.3),
//                                   filled: true,
//                                   enabledBorder: messageContainer,
//                                   focusedBorder: messageContainer,
//                                   suffixIcon: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       IconButton(
//                                         onPressed: () {
//                                           setState(() {
//                                             AwesomeDialog(
//                                               context: context,
//                                               animType: AnimType.bottomSlide,
//                                               dialogType: DialogType.success,
//                                               body: Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.center,
//                                                 children: [
//                                                   SizedBox(
//                                                       height: 90,
//                                                       width: 100,
//                                                       child: ElevatedButton(
//                                                           onPressed: () {
//                                                             setState(() {});
//                                                           },
//                                                           child: const Text(
//                                                             "camera",
//                                                             style: TextStyle(
//                                                                 fontSize: 17,
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .bold),
//                                                           ))),
//                                                   const SizedBox(
//                                                     width: 50,
//                                                   ),
//                                                   SizedBox(
//                                                       height: 90,
//                                                       width: 100,
//                                                       child: ElevatedButton(
//                                                           onPressed: () {
//                                                             setState(() {
//                                                               Navigator.of(
//                                                                       context)
//                                                                   .pop();
//                                                             });
//                                                           },
//                                                           child: const Text(
//                                                               "gallery",
//                                                               style: TextStyle(
//                                                                   fontSize: 17,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .bold)))),
//                                                 ],
//                                               ),
//                                               title: 'This is Ignored',
//                                               desc: 'This is also Ignored',
//                                               btnOkOnPress: () {},
//                                             ).show();
//                                           });
//                                         },
//                                         icon: const Icon(Icons.attach_file),
//                                       ),
//                                       IconButton(
//                                           onPressed: () {
//                                             setState(() {});
//                                           },
//                                           icon:
//                                               const Icon(Icons.emoji_emotions)),
//                                     ],
//                                   )),
//                             )),
//                       ),
//                     ),
//                     IconButton(onPressed: () {
//                       setState(() {
//                        //  sendMessage();
//                       userSendMessage();
//                       });

//                     }, icon: const Icon(Icons.send))
//                   ],
//                 ),
//               ],
//             ),
//           );
//         });
//   }

//   void sendMessage() async {
//     await userNameAgeCollection
//         .doc()
//         .collection("commonChatMessages")
//         .doc(currentUser!.uid)
//         .collection("allMessages")
//         .add({
//       'message': messageController.text,
//       'messageType': "text",
//       'senderId': currentUser!.uid,
//       // 'senderNick':
//       //     Provider.of<MyProvider>(context, listen: false).currentProfileNick,
//       // "receiverId": Provider.of<MyProvider>(context, listen: false).uid,
//       // 'receiverNick': Provider.of<MyProvider>(context, listen: false).nick,
//       'timestamp': DateFormat("dd-MM-yyyy").format(DateTime.now()),
//       'timestamp1': DateFormat("hh:mm").format(DateTime.now()),
//       "timestamp2": FieldValue.serverTimestamp(),
//     });
//   }

//   void userSendMessage() async {
//     await userNameAgeCollection
//         .doc(currentUser!.uid)
//         .collection("commonChatMessages")

//         .add({
//       'message': messageController.text,
//       'messageType': "text",
//       'senderId': currentUser!.uid,
//       // 'senderNick':
//       //     Provider.of<MyProvider>(context, listen: false).currentProfileNick,
//       // "receiverId": Provider.of<MyProvider>(context, listen: false).uid,
//       // 'receiverNick': Provider.of<MyProvider>(context, listen: false).nick,
//       'timestamp': DateFormat("dd-MM-yyyy").format(DateTime.now()),
//       'timestamp1': DateFormat("hh:mm").format(DateTime.now()),
//       "timestamp2": FieldValue.serverTimestamp(),
//     });
//   }

// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../const/textformfield.dart';
import '../const/textstyle.dart';
import '../provider/provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  late final FirebaseAuth _firebaseAuth;

  late final User? currentUser;
  final CollectionReference _messagesCollection =
      FirebaseFirestore.instance.collection('messages');

  @override
  void initState() {
    _firebaseAuth = FirebaseAuth.instance;

    currentUser = _firebaseAuth.currentUser;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text('Common Chat'),
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
              child: StreamBuilder<QuerySnapshot>(
                stream: _messagesCollection
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      reverse: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var message = snapshot.data!.docs[index];
                        return ListTile(
                          subtitle: Align(
                              alignment: currentUser!.uid == message["senderId"]
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: currentUser!.uid ==
                                              message["senderId"]
                                          ? Colors.lightBlue
                                          : Colors.grey,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(
                                            20.0), // Radius for top left corner
                                        bottomRight: Radius.circular(30.0),
                                      )),
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [

                                      Text(message['content'],style: messageStyle,),
                                     const SizedBox(width: 10,),
                                      Column(
                                        children: [
                                          Text(message["timestamp1"],style: dateStyle,),
                                          Text(message["timestamp2"],style: dateStyle,),
                                        ],
                                      ),
                                    ],
                                  ))),
                          title: Align(
                            alignment: currentUser!.uid == message["senderId"]
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Text(
                              Provider.of<MyProvider>(context, listen: false)
                                          .currentProfileNick ==
                                      message["nick"]
                                  ? message["nick"]
                                  : message["nick"],
                              style:
                                const  TextStyle(fontSize: 15, color: Colors.black),
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
              ),
            ),
            Padding(
              padding:const EdgeInsets.all(8.0),
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
                      onPressed: _sendMessage,
                      icon:const Icon(Icons.send),
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

  void _sendMessage() {
    String messageContent = _messageController.text.trim();

    if (messageContent.isNotEmpty) {
      var message = {
        'content': messageContent,
        "nick":
            Provider.of<MyProvider>(context, listen: false).currentProfileNick,
        'senderId': currentUser!.uid, // Replace with the actual user ID
        'timestamp': Timestamp.now(),
        'timestamp1': DateFormat("dd-MM-yyyy").format(DateTime.now()),
        'timestamp2': DateFormat("hh:mm").format(DateTime.now()),
      };

      _messagesCollection.add(message);

      _messageController.clear();
    }
  }
}
