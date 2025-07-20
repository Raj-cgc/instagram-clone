import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram_flutter/resources/storage_methods.dart';
import 'package:flutter/services.dart';
import 'package:instagram_flutter/models/user_model.dart' as model;

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot snap =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(snap);
  }

  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    Uint8List? file, // Make file nullable
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty &&
          password.isNotEmpty &&
          username.isNotEmpty &&
          bio.isNotEmpty) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        Uint8List imageToUpload;

        if (file != null) {
          imageToUpload = file;
        } else {
          final byteData = await rootBundle.load(
            'assets/images/profile_default_icon.png',
          );
          imageToUpload = byteData.buffer.asUint8List();
        }

        String photoUrl = await StorageMethods().uploadImageToStorage(
          childname: 'profilePics',
          file: imageToUpload,
          post: false,
        );

        model.User user = model.User(
          email: email,
          uid: cred.user!.uid,
          photoUrl: photoUrl,
          username: username,
          bio: bio,
          followers: [],
          following: [],
        );

        await _firestore
            .collection('users')
            .doc(cred.user!.uid)
            .set(user.toJson());

        res = 'Success';
      } else {
        res = "Please enter all the fields.";
      }
    } on FirebaseAuthException catch (e) {
      res = e.toString();
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  //logging in the user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = 'Some error occured';

    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = 'success';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  //Sign out the user
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
