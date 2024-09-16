import 'package:flutter/material.dart';
import 'package:instagram_clone/utils/colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final usernameController = TextEditingController();
  final nameController = TextEditingController();
  final bioController = TextEditingController();
  final genderController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    usernameController.dispose();
    nameController.dispose();
    bioController.dispose();
    genderController.dispose();
  }

  int? selectedRadioValue = 4;

  @override
  Widget build(BuildContext context) {
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
              const CircleAvatar(
                radius: 55,
                backgroundImage: NetworkImage(
                  'https://images.unsplash.com/photo-1725656470843-02e3611ff3f2?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxmZWF0dXJlZC1waG90b3MtZmVlZHwxMnx8fGVufDB8fHx8fA%3D%3D',
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Edit picture',
                  style: TextStyle(fontSize: 17, color: blueColor),
                ),
              ),
              myTextField('Name', nameController),
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
                          radioTile(1, 'Male'),
                          radioTile(2, 'Female'),
                          radioTile(3, 'Other'),
                          radioTile(4, 'Prefer not to say'),
                        ],
                      ),
                    ),
                  );

                  if (selectedGender != null) {
                    setState(() {
                      selectedRadioValue = selectedGender;

                      genderController.text = selectedGender == 1
                          ? 'Male'
                          : selectedGender == 2
                              ? 'Female'
                              : selectedGender == 3
                                  ? 'Other'
                                  : 'Prefer not to say';
                    });
                  }
                },
                child: myTextField('Gender', genderController, isGender: true),
              ),
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
