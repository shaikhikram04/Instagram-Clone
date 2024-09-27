import 'package:flutter/material.dart';
import 'package:instagram_clone/screens/chat_screen.dart';

class ChatCard extends StatelessWidget {
  const ChatCard({super.key, required this.isActiveChat});

  final bool isActiveChat;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (!isActiveChat) {
          Navigator.of(context).pop();
        }
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const ChatScreen(),
        ));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: SizedBox(
          height: 80,
          child: Row(
            children: [
              const CircleAvatar(
                backgroundImage: NetworkImage(
                  'https://images.unsplash.com/photo-1727262436067-6ac6dfc03e27?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxmZWF0dXJlZC1waG90b3MtZmVlZHwxN3x8fGVufDB8fHx8fA%3D%3D',
                ),
                radius: 33,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'username',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w500),
                      ),
                      isActiveChat
                          ? const Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Hii! ',
                                    style: TextStyle(fontSize: 16),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text('   25/9/24'),
                              ],
                            )
                          : const Text(
                              'User Bio : ajsdnciwenxoewihncwejbucniweoncwoieasd',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
