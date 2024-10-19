import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/screens/home/profile_screen.dart';
import 'package:instagram_clone/utils/colors.dart';

Future<Uint8List?> pickImage(ImageSource source) async {
  final ImagePicker imagePicker = ImagePicker();

  XFile? file = await imagePicker.pickImage(source: source);

  if (file != null) {
    return await file.readAsBytes();
  }
  return null;
}

showSnackBar(String content, BuildContext context) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: imageBgColor,
      content: Text(
        content,
        style: const TextStyle(color: primaryColor),
      ),
    ),
  );
}

List<Widget> buildSearchResult({
  required BuildContext context,
  required String query,
  required List allUser,
  required String goTo,
}) {
  final filteredUser = allUser.where(
    (user) {
      String fullName = user['username'].toLowerCase();
      return fullName.contains(query);
    },
  ).toList();

  return filteredUser.map(
    (user) {
      return ListTile(
        title: Text(user['username']),
        onTap: () =>
            Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
          return ProfileScreen(
            uid: user['uid'],
          );
        })),
        leading: CircleAvatar(
          backgroundColor: imageBgColor,
          backgroundImage: NetworkImage(
            user['photoUrl'],
          ),
        ),
      );
    },
  ).toList();
}
