import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatapp/models/user_database.dart';
import 'package:chatapp/models/user_entry.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserDatabase userDatabase = UserDatabase();

  void createAccount(
    String emailAddress,
    String password,
    String username,
    String firstName,
    String lastName,
  ) {
    print('creating account');
    try {
      _auth.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      userDatabase.addUserEntryUnstruct(
        username,
        emailAddress,
        firstName,
        lastName,
      );
      login(emailAddress, password);
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

  void login(String emailAddress, String password) {
    print('logging in');
    try {
      _auth.signInWithEmailAndPassword(email: emailAddress, password: password);
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

  void logout() {
    print('signing out');
    try {
      _auth.signOut();
      print('signed out');
    } on FirebaseAuthException catch (e) {
      print(e);
    }
  }

  UserEntry? getCurrentUserInfo() {
    User? user_test = _auth.currentUser;
    if (user_test == null) return null;
    User user = user_test;
    String? email_test = user.email;
    if (email_test == null) return null;
    String email = email_test;
    UserEntry? userdata_test = userDatabase.getUserEntryFromEmail(email);
    if (userdata_test == null) return null;
    UserEntry userdata = userdata_test;
    return userdata;
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
