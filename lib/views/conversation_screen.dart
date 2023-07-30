import 'package:chat_app_tutorial/helper/constants.dart';
import 'package:chat_app_tutorial/widget/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ConversationScreen extends StatefulWidget {
  final String chatRoomId;
  ConversationScreen(this.chatRoomId);

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  late final TextEditingController messageController;

  late Stream<QuerySnapshot> chatMessagesStream;

  Widget ChatMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: chatMessagesStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                      (snapshot.data!.docs[index].data()
                          as Map<String, dynamic>)['message'] as String,
                      (snapshot.data!.docs[index].data()
                              as Map<String, dynamic>)['sendBy'] as String ==
                          Constants.myName);
                },
              )
            : Container();
      },
    );
  }

  sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> messageMap = {
        'message': messageController.text,
        'sendBy': Constants.myName,
        'time': DateTime.now().millisecondsSinceEpoch,
      };

      FirebaseFirestore.instance
          .collection('ChatRoom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .add(messageMap);
      messageController.text = '';
    }
  }

  @override
  void initState() {
    super.initState();
    messageController = TextEditingController();
    chatMessagesStream = FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(widget.chatRoomId)
        .collection('chats')
        .orderBy('time', descending: false)
        .snapshots();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: Container(
        child: Stack(
          children: [
            ChatMessageList(),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: const Color(0x54FFFFFF),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                      controller: messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          hintText: 'Message...',
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none),
                    )),
                    GestureDetector(
                      onTap: () {
                        sendMessage();
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
                          child: Image.asset('assets/images/send.png')),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool isSendByMe;
  MessageTile(this.message, this.isSendByMe);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: isSendByMe ? 0 : 24,
        right: isSendByMe ? 24 : 0,
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: MediaQuery.of(context).size.width,
      alignment: isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSendByMe
                ? const [
                    Color(0xff007EF4),
                    Color(0xff2A75BC),
                  ]
                : const [
                    Color(0x1AFFFFFF),
                    Color(0x1AFFFFFF),
                  ],
          ),
          borderRadius: isSendByMe
              ? const BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                  bottomLeft: Radius.circular(23),
                )
              : const BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                  bottomRight: Radius.circular(23),
                ),
        ),
        child: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
          ),
        ),
      ),
    );
  }
}
