import 'package:chatapp/screen/privacy_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../const/textstyle.dart';
import '../provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();

  String name = "";

  late final FirebaseFirestore _firestore;
  late final FirebaseAuth _firebaseAuth;
  late final CollectionReference userNameAgeCollection;
  late final User? currentUser;

  @override
  void initState() {
    _firestore = FirebaseFirestore.instance;
    _firebaseAuth = FirebaseAuth.instance;
    userNameAgeCollection = _firestore.collection("userNameAgeInfo");
    currentUser = _firebaseAuth.currentUser;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // The search area here
          title: Container(
        width: double.infinity,
        height: 40,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(5)),
        child: Center(
          child: TextField(
            controller: searchController,
            onChanged: (value) {
              setState(() {
                name = value;
              });
            },
            decoration: InputDecoration(
                prefixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
                hintText: 'Search...',
                border: InputBorder.none),
          ),
        ),
      )),
      body: StreamBuilder<QuerySnapshot>(
        stream: userNameAgeCollection.snapshots(),
        builder: (context, snapshots) {
          return (snapshots.connectionState == ConnectionState.waiting)
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      "number of users : ${snapshots.data!.docs.length.toString()}",
                      style: showUsersLength,
                    ),
                  ),
                  ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshots.data!.docs.length,
                      itemBuilder: (context, index) {
                        var data = snapshots.data!.docs[index].data()
                            as Map<String, dynamic>;

                        if (name.isEmpty) {
                          return InkWell(
                              onTap: () {
                                Provider.of<MyProvider>(context, listen: false)
                                    .nick = data["nick"];
                                Provider.of<MyProvider>(context, listen: false)
                                    .image = data["image"];
                                Provider.of<MyProvider>(context, listen: false)
                                    .uid = data["userUid"];
                                    print( Provider.of<MyProvider>(context, listen: false)
                                    .uid);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const PrivacyMessage()),
                                );
                              },
                              child: currentUser!.uid == data["userUid"]
                                  ? ListTile(
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            data["nick"],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(width: 10),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("(you)",
                                                  style: showAccountown),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              const Icon(
                                                  FontAwesomeIcons.houseChimney)
                                            ],
                                          )
                                        ],
                                      ),

                                      // subtitle: Text(
                                      //   data["email"],
                                      //   maxLines: 1,
                                      //   overflow: TextOverflow.ellipsis,
                                      //   style: const TextStyle(
                                      //       color: Colors.black54,
                                      //       fontSize: 16,
                                      //       fontWeight: FontWeight.bold),
                                      // ),
                                      leading: CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(data["image"]),
                                      ),
                                    )
                                  : ListTile(
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            data["nick"],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(width: 10),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          IconButton(onPressed: (){}, icon:const Icon(FontAwesomeIcons.userPlus))
                                        ],
                                      ),

                                      // subtitle: Text(
                                      //   data["email"],
                                      //   maxLines: 1,
                                      //   overflow: TextOverflow.ellipsis,
                                      //   style: const TextStyle(
                                      //       color: Colors.black54,
                                      //       fontSize: 16,
                                      //       fontWeight: FontWeight.bold),
                                      // ),
                                      leading: CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(data["image"]),
                                      ),
                                    ));
                        }
                        if (data["nick"]
                            .toString()
                            .toLowerCase()
                            .startsWith(name.toLowerCase())) {
                          return currentUser!.uid == data["userUid"]
                              ? ListTile(
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        data["nick"],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(width: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("(you)", style: showAccountown),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          const Icon(
                                              FontAwesomeIcons.houseChimney)
                                        ],
                                      )
                                    ],
                                  ),

                                  // subtitle: Text(
                                  //   data["email"],
                                  //   maxLines: 1,
                                  //   overflow: TextOverflow.ellipsis,
                                  //   style: const TextStyle(
                                  //       color: Colors.black54,
                                  //       fontSize: 16,
                                  //       fontWeight: FontWeight.bold),
                                  // ),
                                  leading: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(data["image"]),
                                  ),
                                )
                              : ListTile(
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        data["nick"],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(width: 10),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      IconButton(onPressed: (){}, icon:const Icon(FontAwesomeIcons.userPlus))
                                    ],
                                  ),

                                  // subtitle: Text(
                                  //   data["email"],
                                  //   maxLines: 1,
                                  //   overflow: TextOverflow.ellipsis,
                                  //   style: const TextStyle(
                                  //       color: Colors.black54,
                                  //       fontSize: 16,
                                  //       fontWeight: FontWeight.bold),
                                  // ),
                                  leading: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(data["image"]),
                                  ),
                                );
                        }
                        return Container();
                      }),
                ]);
        },
      ),
    );
  }
}
