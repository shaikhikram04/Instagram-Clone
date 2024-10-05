import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageMethods {
  static final _storage = FirebaseStorage.instance;
  static final _auth = FirebaseAuth.instance;

  static Future<String> uploadImageToStorage(
    String childName,
    Uint8List file,
    bool hasMultipleImage,
  ) async {
    Reference ref =
        _storage.ref().child(childName).child(_auth.currentUser!.uid);

    if (hasMultipleImage) {
      final id = const Uuid().v1();
      ref = ref.child(id);
    }

    UploadTask uploadTask = ref.putData(file);

    TaskSnapshot snap = await uploadTask;
    String downloadURL = await snap.ref.getDownloadURL();

    return downloadURL;
  }

  static Future<void> deleteImage(String child) async {
    _storage.ref().child(child).child(_auth.currentUser!.uid).delete();
  }
}
