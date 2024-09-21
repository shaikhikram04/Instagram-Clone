import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final usernameController = TextEditingController();
  final bioController = TextEditingController();
  final genderController = TextEditingController();
  late ImageProvider image;
  int selectedRadioValue = 4;

  Map<int, String> genderFromValue = {
    1: 'Male',
    2: 'Female',
    3: 'Other',
    4: 'Prefer not to say',
  };

  int getKeyOfGender(String gender) {
    for (final i in genderFromValue.entries) {
      if (gender == i.value) return i.key;
    }

    return 4;
  }

  void editImage() {
    final Uint8List im = pickImage(ImageSource.gallery);
    setState(() {
      image = MemoryImage(im);
    });
  }

  void saveEdits() {}

  @override
  void dispose() {
    super.dispose();
    usernameController.dispose();
    bioController.dispose();
    genderController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    image = NetworkImage(user.photoUrl);
    usernameController.text = user.username;
    bioController.text = user.bio;
    genderController.text = user.gender;
    selectedRadioValue = getKeyOfGender(user.gender);

    Widget radioTile(
      int value,
      String title,
    ) {
      return RadioListTile(
        title: Text(title),
        activeColor: blueColor,
        value: value,
        groupValue: selectedRadioValue,
        onChanged: (value) {
          Navigator.of(context).pop(value);
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit profile'),
        backgroundColor: mobileBackgroundColor,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              CircleAvatar(
                radius: 55,
                backgroundImage: image,
                backgroundColor: Colors.grey,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: editImage,
                child: const Text(
                  'Edit picture',
                  style: TextStyle(fontSize: 17, color: blueColor),
                ),
              ),
              myTextField('Username', usernameController),
              myTextField('Bio', bioController),
              GestureDetector(
                onTap: () async {
                  final selectedGender = await showDialog(
                    context: context,
                    builder: (ctx) => Dialog(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 1; i <= 4; i++)
                            radioTile(i, genderFromValue[i]!),
                        ],
                      ),
                    ),
                  );

                  if (selectedGender != null) {
                    setState(() {
                      selectedRadioValue = selectedGender;
                      ref
                          .read(userProvider.notifier)
                          .updateGender(genderFromValue[selectedRadioValue]!);
                    });
                  }
                },
                child: myTextField('Gender', genderController, isGender: true),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blueColor,
                      foregroundColor: mobileBackgroundColor,
                    ),
                    onPressed: saveEdits,
                    child: const Text(
                      'Save',
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget myTextField(
    String label,
    TextEditingController controller, {
    bool isGender = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          suffixIcon:
              isGender ? const Icon(Icons.arrow_forward_ios_rounded) : null,
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey.shade300,
            fontSize: 18,
          ),
          enabled: !isGender,
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: primaryColor, width: 1),
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: primaryColor, width: 0.7),
          ),
          disabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: primaryColor, width: 0.7),
          ),
        ),
        style: const TextStyle(color: primaryColor),
      ),
    );
  }
}
