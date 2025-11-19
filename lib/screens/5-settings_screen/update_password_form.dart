import 'package:flutter/material.dart';
import 'package:chatapp/authservice.dart';
import 'package:chatapp/models/firestore_helper.dart';
import 'package:chatapp/models/user_entry.dart';

// Update Password form
class UpdatePasswordForm extends StatefulWidget {
  const UpdatePasswordForm(this.authService, this.dbHelper, {super.key});

  final AuthService authService;
  final FirestoreHelper dbHelper;

  @override
  State<UpdatePasswordForm> createState() => _UpdatePasswordFormState();
}

class _UpdatePasswordFormState extends State<UpdatePasswordForm> {
  // Form state key
  final _formKey = GlobalKey<FormState>();

  // Text field controllers
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  // Track password visibility for the "show password" toggle
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;

  // A copy of the current user's info, populated upon initialization
  // This should only be null while the widget is loading
  UserEntry? _userInfo;

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

  // Get the current user's info from the database
  // Once it's available, copy the existing values into the form, then copy
  // the complete UserEntry into _userInfo
  void _loadUserInfo() {
    widget.dbHelper.getUserEntryFromEmail(widget.authService.getEmail()).then((
      result,
    ) {
      setState(() {
        if (result != null) {
          _usernameController.text = result.username!;
          _firstNameController.text = result.firstName!;
          _lastNameController.text = result.lastName!;
          _userInfo = result;
        }
      });
    });
  }

  void _submitForm() {
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
        // Reload entire interface upon completion to avoid desyncs
        setState(() {
          _userInfo = null;
          _updateStatusCode = 'ready';
          _loadUserInfo();
        });
      } else if (_updateStatusCode == 'error') {
        // TODO: send error up the chain
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userInfo != null) {
      // Show form interface once the info is ready
      return Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          spacing: 24.0,
          children: [
            // Old Password field
            TextFormField(
              controller: _oldPasswordController,
              obscureText: !_isOldPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Old Password',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isOldPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isOldPasswordVisible = !_isOldPasswordVisible;
                    });
                  },
                ),
              ),
            ),

            // New Password field
            TextFormField(
              controller: _newPasswordController,
              obscureText: !_isNewPasswordVisible,
              decoration: InputDecoration(
                labelText: 'New Password',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isNewPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isNewPasswordVisible = !_isNewPasswordVisible;
                    });
                  },
                ),
              ),
            ),

            // Submit button
            ElevatedButton(
              onPressed: _submitForm,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text('Update Password')],
              ),
            ),
          ],
        ),
      );
    } else if (_updateStatusCode != 'ready') {
      // Show loading screen while the database commits
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

    // Show loading screen until the info is ready
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
