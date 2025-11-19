import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatapp/models/firestore_helper.dart';
import 'package:chatapp/models/user_entry.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreHelper userDatabase;

  AuthService(this.userDatabase);

  void createAccount(
    String emailAddress,
    String password,
    String username,
    String firstName,
    String lastName,
  ) {
    try {
      UserEntry newUser = UserEntry(
        email: emailAddress,
        username: username,
        firstName: firstName,
        lastName: lastName,
        role: 'user',
        registeredOn: DateTime.now(),
      );
      _auth.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      userDatabase.addUserEntry(newUser);
    } on FirebaseAuthException catch (e) {
      // TODO: pass exceptions up to a snackbar
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
    try {
      _auth.signInWithEmailAndPassword(email: emailAddress, password: password);
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

  void updatePassword(String oldPassword, String newPassword) async {
    try {
      // Get the info for the current user
      User currentUser = FirebaseAuth.instance.currentUser!;

      // Get a new AuthCredential with the old password
      AuthCredential cred = EmailAuthProvider.credential(
        email: currentUser.email!,
        password: oldPassword,
      );

      // Reauthenticate the user
      await currentUser.reauthenticateWithCredential(cred);

      // Update the password
      await currentUser.updatePassword(newPassword);
    } catch (e) {
      print(e);
    }
  }

  // Firebase does not allow updating emails without handling
  // email verification, which is beyond the scope of this homework
  /*
  void updateEmail(String newEmail, String password) async {
    try {
      // Get the info for the current user
      User currentUser = FirebaseAuth.instance.currentUser!;
      String oldEmail = currentUser.email!;

      // Get a new AuthCredential
      AuthCredential cred = EmailAuthProvider.credential(
        email: oldEmail,
        password: password,
      );

      // Reauthenticate the user
      await currentUser.reauthenticateWithCredential(cred);

      // Update the email address
      await currentUser.verifyBeforeUpdateEmail(newEmail);
    } catch (e) {
      print(e);
    }
  }
  */

  void logout() {
    print('signing out');
    try {
      _auth.signOut();
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
