import 'package:flutter/material.dart';
import 'package:instagram_clone/screens/chat_profile_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/new_message.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: ListTile(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const ChatProfileScreen(),
          )),
          leading: const CircleAvatar(
            backgroundImage: NetworkImage(
              'https://images.unsplash.com/photo-1720631442759-6a6a95395f62?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxmZWF0dXJlZC1waG90b3MtZmVlZHwxOHx8fGVufDB8fHx8fA%3D%3D',
            ),
          ),
          title: const Text(
            'username',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: const Text('Active 39m ago'),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: Container()),
          const NewMessage(),
        ],
      ),
    );
  }
}
