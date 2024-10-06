import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/models/chat.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/firestore_method.dart';
import 'package:instagram_clone/resources/storage_methods.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';

class TypeNewMessage extends ConsumerStatefulWidget {
  const TypeNewMessage({
    super.key,
    this.isNewChat = false,
    required this.username,
    required this.uid,
    required this.photoUrl,
    this.conversationId,
  });

  final bool isNewChat;
  final String? conversationId;
  final String username;
  final String uid;
  final String photoUrl;

  @override
  ConsumerState<TypeNewMessage> createState() => _TypeNewMessageState();
}

class _TypeNewMessageState extends ConsumerState<TypeNewMessage> {
  late TextEditingController _messageController;
  late String message;
  bool isMessaging = false;
  late User user;
  late bool isNewChat;
  late String id;
  late FocusNode _focusNode;
  final List<Uint8List> _selectedImages = [];

  @override
  void initState() {
    super.initState();

    _messageController = TextEditingController();
    _focusNode = FocusNode();
    message = '';
    user = ref.read(userProvider);
    isNewChat = widget.isNewChat;
    id = widget.conversationId ?? '';
  }

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
    _focusNode.dispose();
  }

  Future<void> clickImage() async {
    final im = await pickImage(ImageSource.camera);

    if (im == null) return;

    setState(() {
      _selectedImages.add(im);
    });

    await sendMessage();
  }

  Future<void> sendMessage() async {
    message = _messageController.text;
    //* will be change
    var messageType = MessageType.text;

    final List<String> photoUrlList = [];

    try {
      if (message.trim().isNotEmpty) {
        //* Sending TextMessage

        // FocusScope.of(context).unfocus();

        _messageController.clear();
        setState(() {
          isMessaging = false;
        });
      } else if (_selectedImages.isNotEmpty) {
        //* sending Image

        messageType = MessageType.image;

        for (final image in _selectedImages) {
          message = await StorageMethods.uploadImageToStorage(
              'sharedImages', image, true);

          photoUrlList.add(message);
        }

        _selectedImages.clear();
      } else {
        //* do nothing on Empty textMessage

        return;
      }

      if (isNewChat) {
        id = await FirestoreMethod.establishConversation(
          user.uid,
          user.username,
          user.photoUrl,
          widget.uid,
          widget.username,
          widget.photoUrl,
        );
        setState(() {
          isNewChat = false;
        });
      }

      if (id == 'errror occurred') {
        if (!mounted) return;

        showSnackBar('Some error occurred! please try again.', context);
      } else {
        String res = '';
        if (photoUrlList.isEmpty) {
          res = await FirestoreMethod.pushMessage(
            id,
            user.uid,
            message,
            messageType,
          );
        } else {
          for (final photoUrl in photoUrlList) {
            res = await FirestoreMethod.pushMessage(
              id,
              user.uid,
              photoUrl,
              messageType,
            );
          }
        }

        if (res != 'success') {
          if (!mounted) return;

          showSnackBar(res, context);
        }
      }
    } catch (e) {
      return;
    }
  }

  Future<void> selectMultipleImagesFromgallary() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.media,
        allowMultiple: true,
        withData: true,
      );

      if (result != null) {
        final images = result.files.map((file) => file.bytes!).toList();
        _selectedImages.addAll(images);

        sendMessage();
      }
    } catch (e) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 65,
          margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 5),
          decoration: const BoxDecoration(
            color: Color.fromARGB(76, 21, 142, 242),
            borderRadius: BorderRadius.all(Radius.circular(33)),
          ),
        ),

        //* TextField
        Center(
          child: TextField(
            controller: _messageController,
            focusNode: _focusNode,
            style: const TextStyle(color: primaryColor, fontSize: 19),
            decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Message...',
                contentPadding: EdgeInsets.only(
                  left: 63,
                  right: 90,
                )),
            onChanged: (value) {
              if ((value.isNotEmpty && !isMessaging) ||
                  (value.isEmpty && isMessaging)) {
                setState(() {
                  isMessaging = value.isNotEmpty;
                });
              }
            },
          ),
        ),

        //* Emoji Button
        Positioned(
          left: isMessaging ? 5 : null,
          right: isMessaging ? null : 5,
          top: 5,
          bottom: 5,
          child: IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.emoji_emotions,
              color: Colors.amber,
              size: 35,
            ),
          ),
        ),

        //* Send Button
        if (isMessaging)
          Positioned(
            top: 11,
            bottom: 11,
            right: 11,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: blueColor, fixedSize: const Size(60, 40)),
              onPressed: sendMessage,
              child: const Icon(
                Icons.send,
                color: primaryColor,
              ),
            ),
          ),

        //* Camera Button
        if (!isMessaging)
          Positioned(
            top: 5,
            bottom: 5,
            left: 10,
            child: CircleAvatar(
              radius: 23,
              backgroundColor: const Color(0xFF088DE5),
              child: IconButton(
                onPressed: clickImage,
                icon: const Icon(
                  Icons.camera_alt,
                  color: primaryColor,
                  size: 31,
                ),
              ),
            ),
          ),

        //* gellery image button
        if (!isMessaging)
          Positioned(
            right: 55,
            top: 5,
            bottom: 5,
            child: IconButton(
              onPressed: selectMultipleImagesFromgallary,
              icon: const Icon(
                Icons.insert_photo,
                color: primaryColor,
                size: 35,
              ),
            ),
          ),
      ],
    );
  }
}
