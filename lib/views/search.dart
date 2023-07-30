import 'package:chat_app_tutorial/helper/constants.dart';
import 'package:chat_app_tutorial/views/conversation_screen.dart';
import 'package:chat_app_tutorial/widget/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

String? _myName;

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController searchTextEditingController;

  QuerySnapshot? searchSnapshot;

  Widget searchList() {
    return searchSnapshot != null
        ? ListView.builder(
            itemCount: searchSnapshot!.docs.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return SearchTile(
                userName: (searchSnapshot!.docs[index].data()
                    as Map<String, dynamic>)['name'],
                userEmail: (searchSnapshot!.docs[index].data()
                    as Map<String, dynamic>)['email'],
              );
            },
          )
        : Container();
  }

  void initiateSearch() async {
    searchSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('name', isEqualTo: searchTextEditingController.text)
        .get();
    setState(() {});
  }

  /// create chatroom, send user to conversation screen, pushreplacement
  createChatroomAndStartConversation({required String userName}) async {
    print('${Constants.myName}');
    if (userName != Constants.myName) {
      String chatRoomId = getChatRoomId(userName, Constants.myName);

      List<String> users = [userName, Constants.myName];
      Map<String, dynamic> chatRoomMap = {
        'users': users,
        'chatroomId': chatRoomId,
      };

      await FirebaseFirestore.instance
          .collection('ChatRoom')
          .doc(chatRoomId)
          .set(chatRoomMap);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ConversationScreen(chatRoomId)));
    } else {
      print('you cannot send message to yourself');
    }
  }

  Widget SearchTile({required String userName, required String userEmail}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: mediumTextStyle(),
              ),
              Text(
                userEmail,
                style: mediumTextStyle(),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              createChatroomAndStartConversation(userName: userName);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text(
                'Message',
                style: mediumTextStyle(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    searchTextEditingController = TextEditingController();
  }

  @override
  void dispose() {
    searchTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: Container(
        child: Column(
          children: [
            Container(
              color: const Color(0x54FFFFFF),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: searchTextEditingController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                        hintText: 'Search username...',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none),
                  )),
                  GestureDetector(
                    onTap: () {
                      initiateSearch();
                    },
                    child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0x36FFFFFF),
                              Color(0x0FFFFFFF),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Image.asset('assets/images/search_white.png')),
                  )
                ],
              ),
            ),
            searchList(),
          ],
        ),
      ),
    );
  }
}

getChatRoomId(String a, String b) {
  if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
    return "$b\_$a";
  } else {
    return "$a\_$b";
  }
}
