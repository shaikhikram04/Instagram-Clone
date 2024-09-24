import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/firestore_method.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';

class AddPostSereen extends ConsumerStatefulWidget {
  const AddPostSereen({super.key});

  @override
  ConsumerState<AddPostSereen> createState() => _AddPostSereenState();
}

class _AddPostSereenState extends ConsumerState<AddPostSereen> {
  Uint8List? _file;
  final _descriptionController = TextEditingController();
  var _isloading = false;

  _selectImage() async {
    return showDialog(
        context: context,
        builder: (ctx) {
          return SimpleDialog(
            title: const Text('Create a Post'),
            children: [
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Take a Photo'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  final file = await pickImage(ImageSource.camera);
                  setState(() {
                    _file = file;
                  });
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose from gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  final file = await pickImage(ImageSource.gallery);
                  setState(() {
                    _file = file;
                  });
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Cancal'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void _postImage(
    String uid,
    String username,
    String profImage,
  ) async {
    try {
      setState(() {
        _isloading = true;
      });
      String res = await FirestoreMethod().uploadPost(
        _descriptionController.text,
        _file!,
        uid,
        username,
        profImage,
      );
      setState(() {
        _isloading = false;
      });

      if (!mounted) return;

      if (res == 'success') {
        showSnackBar('Posted', context);
        _clearImage();
      } else {
        showSnackBar('res', context);
      }
    } catch (err) {
      showSnackBar(err.toString(), context);
    }
  }

  void _clearImage() {
    setState(() {
      _file = null;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return _file == null
        ? Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: IconButton(
                  icon: const Icon(
                    Icons.upload,
                    size: 40,
                  ),
                  onPressed: _selectImage,
                ),
              ),
              const Text('Click here to upload post.')
            ],
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              leading: IconButton(
                onPressed: _clearImage,
                icon: const Icon(Icons.arrow_back),
              ),
              title: const Text(
                'Post to',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      _postImage(user.uid, user.username, user.photoUrl),
                  child: const Text(
                    'Post',
                    style: TextStyle(
                      color: blueColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                if (_isloading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: LinearProgressIndicator(),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage(user.photoUrl),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          hintText: 'Write Caption...',
                          border: InputBorder.none,
                        ),
                        maxLines: 8,
                      ),
                    ),
                    SizedBox(
                      height: 45,
                      width: 45,
                      child: AspectRatio(
                        aspectRatio: 487 / 451,
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: MemoryImage(_file!),
                              fit: BoxFit.fill,
                              alignment: FractionalOffset.topCenter,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Divider(),
                  ],
                ),
              ],
            ),
          );
  }
}
