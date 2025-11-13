import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createAccount(String emailAddress, String password) async {
    print('creating account');
    try {
      await _auth.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      await login(emailAddress, password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> login(String emailAddress, String password) async {
    print('logging in');
    try {
      await _auth.signInWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      print('logged in');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> logout() async {
    print('signing out');
    try {
      await _auth.signOut();
      print('signed out');
    } on FirebaseAuthException catch (e) {
      print(e);
    }
  }

  bool isLoggedIn() {
    if (_auth.currentUser != null) {
      print('current user:');
      print(_auth.currentUser?.uid);
      return true;
    } else {
      print('not signed in');
      return false;
    }
  }

  Stream<User?>? getStream() {
    return _auth.authStateChanges();
  }

  String getEmail() {
    if (_auth.currentUser != null) {
      for (final providerProfile in _auth.currentUser!.providerData) {
        final emailAddress = providerProfile.email!;
        return emailAddress;
      }
    }
    return '';
  }
}
