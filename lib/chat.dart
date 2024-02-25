import 'api/chat_api.dart';
import 'models/chat_message.dart';
import 'widgets/message_bubble.dart';
import 'widgets/message_composer.dart';
import 'package:flutter/material.dart';
import 'home.dart';

class Chat extends StatefulWidget {
  final ChatApi chatApi = ChatApi();

  Chat({super.key});
  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final _messages = <ChatMessage>[
    ChatMessage('Hello ${Home.displayName}, how can I help?', false),
  ];
  var _awaitingResponse = false;

  @override
  Widget build(BuildContext context) {
    var userAvatar = 'https://ui-avatars.com/api/?name=${Home.displayName}';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ..._messages.map(
                  (msg) => MessageBubble(
                      content: msg.content,
                      isUserMessage: msg.isUserMessage,
                      avatarUrl: msg.isUserMessage
                          ? userAvatar
                          : "https://ui-avatars.com/api/?name=Micycle"),
                ),
              ],
            ),
          ),
          MessageComposer(
            onSubmitted: _onSubmitted,
            awaitingResponse: _awaitingResponse,
          ),
        ],
      ),
    );
  }

  Future<void> _onSubmitted(String message) async {
    setState(() {
      _messages.add(ChatMessage(message, true));
      _awaitingResponse = true;
    });
    try {
      final response = await widget.chatApi.completeChat(_messages);
      setState(() {
        _messages.add(ChatMessage(response, false));
        _awaitingResponse = false;
      });
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
      setState(() {
        _awaitingResponse = false;
      });
    }
  }
}
