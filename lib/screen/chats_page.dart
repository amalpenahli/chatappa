import 'package:chatapp/model/users_model.dart';
import 'package:flutter/material.dart';


class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title:const Text("Chats"),
      ),
      body: SizedBox(
        width: 200,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: UserData.userDataList.length,
          itemBuilder: (BuildContext context, int index){
            UsersInfo usersInfo = UserData.userDataList[index];
            return ListTile(
            leading: CircleAvatar(
             child: ClipOval(
              child: Image.asset(usersInfo.Iconurl),
             ),
            )
            );
          }),
      )
    );
  }
}