import 'package:flutter/material.dart';
import 'package:chatapp/authservice.dart';
import 'package:chatapp/models/user_entry.dart';
import 'package:chatapp/models/firestore_helper.dart';

// Create Account screen
// Imported and shown on the welcome screen when the create account button is pressed
class UpdateProfileForm extends StatefulWidget {
  const UpdateProfileForm(this.authService, this.dbHelper, {super.key});

  final AuthService authService;
  final FirestoreHelper dbHelper;

  @override
  State<UpdateProfileForm> createState() => _UpdateProfileFormState();
}

class _UpdateProfileFormState extends State<UpdateProfileForm> {
  // Form state key
  final _formKey = GlobalKey<FormState>();

  // Text field controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  UserEntry? userInfo;

  // Tracks status of submitted async update request
  // Either 'ready', 'pending', 'complete', or 'error'
  String _updateStatusCode = 'ready';

  @override
  void initState() {
    super.initState();

    setState(() {
      _loadUserInfo();
    });
  }

  void _loadUserInfo() {
    widget.dbHelper.getUserEntryFromEmail(widget.authService.getEmail()).then((
      result,
    ) {
      setState(() {
        if (result != null) {
          _fillFormFields(result); // fill form fields before loading the widget
          userInfo = result;
        }
      });
    });
  }

  void _fillFormFields(UserEntry initialInfo) {
    setState(() {
      _usernameController.text = initialInfo.username!;
      _firstNameController.text = initialInfo.firstName!;
      _lastNameController.text = initialInfo.lastName!;
    });
  }

  /*
  void _sendUpdate() async {
    bool exitcode = await widget.dbHelper.updateUserProfile(emailID, newUsername, newFirstName, newLastName);
  }
  */

  void _submitForm() {
    //String username = _usernameController.text;
    //String firstName = _firstNameController.text;
    //String lastName = _lastNameController.text;

    //widget.dbHelper.updateUserProfile(emailID, newUsername, newFirstName, newLastName)

    // Hide interface, prepare to send update
    setState(() {
      _updateStatusCode = 'pending';
    });

    // Send update and register function to update status on completion
    widget.dbHelper
        .updateUserProfile(
          widget.authService.getEmail(),
          _usernameController.text,
          _firstNameController.text,
          _lastNameController.text,
        )
        .then((result) {
          setState(() {
            if (result) {
              _updateStatusCode = 'complete';
            } else {
              _updateStatusCode = 'error';
            }
          });
        });

    // Wait for update to commit and then update status
    while (_updateStatusCode != 'ready') {
      if (_updateStatusCode == 'complete') {
        // Reload interface on completion
        setState(() {
          userInfo = null;
          _updateStatusCode = 'ready';
          _loadUserInfo();
        });
      } else if (_updateStatusCode == 'error') {
        // TODO: send error
      }
    }

    /*
    widget.authService.createAccount(
      emailAddress,
      password,
      username,
      firstName,
      lastName,
    );

    widget.authService.login(emailAddress, password);
    */
  }

  @override
  Widget build(BuildContext context) {
    if (userInfo != null) {
      return Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          spacing: 24.0,
          children: [
            // Username field
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // First name field
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: 'First Name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // Last name field
            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // Submit button
            ElevatedButton(
              onPressed: _submitForm,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text('Update Profile')],
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(64.0),
        child: Column(
          children: [
            Text(
              'Loading...',
              style: const TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
