import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Micycle/theme/theme_provider.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    required this.content,
    required this.isUserMessage,
    this.avatarUrl,
    Key? key,
  }) : super(key: key);

  final String content;
  final bool isUserMessage;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Row(
      children: [
        if (avatarUrl != null)
          CircleAvatar(
            backgroundImage: NetworkImage(avatarUrl!),
          ),
        Flexible(
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUserMessage
                  ? Colors.blueAccent.withOpacity(0.4)
                  : Colors.greenAccent.withOpacity(0.4),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUserMessage ? 'You' : 'Micycle',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: themeProvider.fontSize,
                    color: themeProvider.themeData.colorScheme.secondary,
                  ),
                ),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: themeProvider.fontSize,
                    color: themeProvider.themeData.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
