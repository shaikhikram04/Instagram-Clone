import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/models/chat.dart';
import 'package:instagram_clone/models/local_chat.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/providers/message_provider.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/firestore_method.dart';
import 'package:instagram_clone/resources/storage_methods.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:uuid/uuid.dart';

class TypeNewMessage extends ConsumerStatefulWidget {
  const TypeNewMessage({
    super.key,
    this.isNewChat = false,
    required this.username,
    required this.uid,
    required this.photoUrl,
    this.conversationId,
    required this.makeChatActive,
  });

  final bool isNewChat;
  final String? conversationId;
  final String username;
  final String uid;
  final String photoUrl;
  final void Function(String cId) makeChatActive;

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
  var isShowingEmojiPicker = false;

  @override
  void initState() {
    super.initState();

    _messageController = TextEditingController();
    _focusNode = FocusNode();
    message = '';
    user = ref.read(userProvider);
    isNewChat = widget.isNewChat;
    id = widget.conversationId ?? '';

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        ref.read(localChatProvider.notifier).clearLocalChat();
      },
    );
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

        widget.makeChatActive(id);

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
          final chatId = const Uuid().v1();
          LocalChat localChat = LocalChat.text(
            chatId: chatId,
            from: user.uid,
            message: message,
            timeStamp: Timestamp.now(),
          );

          ref.read(localChatProvider.notifier).addLocalChat(localChat);

          res = await FirestoreMethod.pushMessage(
            conversationId: id,
            uid: user.uid,
            username: user.username,
            messageType: messageType,
            message: message,
          );

          final messageStatus =
              res == 'success' ? MessageStatus.sent : MessageStatus.failed;

          ref
              .read(localChatProvider.notifier)
              .updateStatus(chatId, messageStatus);
        } else {
          final chatIds = [];
          for (final photoUrl in photoUrlList) {
            final chatId = const Uuid().v1();
            chatIds.add(chatId);
            final localChat = LocalChat.image(
              chatId: chatId,
              from: user.uid,
              timeStamp: Timestamp.now(),
              imageUrl: photoUrl,
            );
            ref.read(localChatProvider.notifier).addLocalChat(localChat);
          }

          int chatIndex = 0;
          for (final photoUrl in photoUrlList) {
            res = await FirestoreMethod.pushMessage(
              conversationId: id,
              uid: user.uid,
              username: user.username,
              messageType: messageType,
              imageUrl: photoUrl,
            );
            final messageStatus =
                res == 'success' ? MessageStatus.sent : MessageStatus.failed;

            ref
                .read(localChatProvider.notifier)
                .updateStatus(chatIds[chatIndex], messageStatus);
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
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Container(
          height: height * 0.075,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: const BoxDecoration(
            color: Color.fromARGB(76, 21, 142, 242),
            borderRadius: BorderRadius.all(Radius.circular(33)),
          ),
          child: Stack(
            children: [
              //* TextField
              Center(
                child: TextField(
                  controller: _messageController,
                  focusNode: _focusNode,
                  readOnly: isShowingEmojiPicker,
                  style:
                      TextStyle(color: primaryColor, fontSize: height * 0.024),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Message...',
                    hintStyle: const TextStyle(fontWeight: FontWeight.normal),
                    contentPadding: EdgeInsets.only(
                      left: width * 0.17,
                      right: width * 0.2,
                    ),
                  ),
                  onTapAlwaysCalled: false,
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

              //* Emoji / Keyboard Button
              Positioned(
                left: isMessaging ? width * 0.01 : null,
                right: isMessaging ? null : width * 0.01,
                top: height * 0.001,
                bottom: height * 0.001,
                child: IconButton(
                  onPressed: () async {
                    if (isShowingEmojiPicker) {
                      FocusScope.of(context).requestFocus(_focusNode);
                    } else {
                      if (_focusNode.hasFocus) {
                        FocusScope.of(context).unfocus();
                        await Future.delayed(const Duration(milliseconds: 350));
                      }
                    }
                    setState(() {
                      isShowingEmojiPicker = !isShowingEmojiPicker;
                    });
                  },
                  icon: Icon(
                    isShowingEmojiPicker
                        ? Icons.keyboard
                        : Icons.emoji_emotions,
                    color: primaryColor,
                    size: height * 0.05,
                  ),
                ),
              ),

              //* Send Button
              if (isMessaging)
                Positioned(
                  top: height * 0.01,
                  bottom: height * 0.01,
                  right: width * 0.02,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blueColor,
                      fixedSize: const Size(60, 40),
                    ),
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
                  top: 0.001,
                  bottom: 0.001,
                  left: width * 0.02,
                  child: CircleAvatar(
                    radius: height * 0.03,
                    backgroundColor: const Color(0xFF088DE5),
                    child: IconButton(
                      onPressed: clickImage,
                      icon: Icon(
                        Icons.camera_alt,
                        color: primaryColor,
                        size: height * 0.038,
                      ),
                    ),
                  ),
                ),

              //* gellery image button
              if (!isMessaging)
                Positioned(
                  right: width * 0.14,
                  top: 0.00001,
                  bottom: 0.00001,
                  child: IconButton(
                    onPressed: selectMultipleImagesFromgallary,
                    icon: Icon(
                      Icons.insert_photo,
                      color: primaryColor,
                      size: height * 0.05,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (isShowingEmojiPicker)
          SizedBox(
            height: height * 0.4,
            width: double.infinity,
            child: EmojiPicker(
              textEditingController: _messageController,
              onEmojiSelected: (category, emoji) {
                if (!isMessaging) {
                  setState(() {
                    isMessaging = true;
                  });
                }
              },
              onBackspacePressed: () {
                if (_messageController.text.isEmpty) {
                  setState(() {
                    isMessaging = false;
                  });
                }
              },
              config: const Config(
                checkPlatformCompatibility: true,
                viewOrderConfig: ViewOrderConfig(),
                emojiViewConfig: EmojiViewConfig(emojiSizeMax: 28),
                skinToneConfig: SkinToneConfig(),
                categoryViewConfig: CategoryViewConfig(),
                bottomActionBarConfig: BottomActionBarConfig(),
                searchViewConfig: SearchViewConfig(),
              ),
            ),
          ),
      ],
    );
  }
}
