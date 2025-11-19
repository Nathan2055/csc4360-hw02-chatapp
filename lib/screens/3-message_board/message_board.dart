import 'package:flutter/material.dart';
import 'package:chatapp/authservice.dart';
import 'package:chatapp/models/user_entry.dart';
import 'package:chatapp/models/firestore_helper.dart';
import 'package:chatapp/screens/4-profile_screen/profile_screen.dart';
import 'package:chatapp/screens/5-settings_screen/settings_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatapp/models/user_entry.dart';
import 'package:chatapp/models/chat_entry.dart';

class MessageBoard extends StatefulWidget {
  const MessageBoard(
    this.authService,
    this.dbHelper,
    this.messageBoard, {
    super.key,
  });

  final AuthService authService;
  final FirestoreHelper dbHelper;
  final String messageBoard;

  @override
  State<MessageBoard> createState() => _MessageBoardState();
}

class _MessageBoardState extends State<MessageBoard> {
  late AppBar homeScreenAppBar;

  late Column _homePlaceholder;
  late Column _homeColumn;

  String _visibleScreen = 'home';

  UserEntry? _userInfo;
  late String _email;
  String? _userInfoString;

  late Stream<QuerySnapshot> _chatStream;
  late StreamBuilder<QuerySnapshot> _chatStreamWidget;

  late Form _chatForm;
  final TextEditingController _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Tracks status of submitted async update request
  // Either 'ready', 'pending', 'complete', or 'error'
  String _sendingMessage = 'ready';

  @override
  void initState() {
    super.initState();

    _chatStream = widget.dbHelper.getChatStream(widget.messageBoard);

    _email = widget.authService.getEmail();

    widget.dbHelper.getUserEntryFromEmail(_email).then((result) {
      if (result != null) {
        setState(() {
          _userInfo = result;
          _userInfoString = _userInfo!.toFirestore().toString();
          _buildHomeScreenAppBar();
          _buildHomePlaceholder();
          _buildHomeColumn();
        });
      }
    });

    _buildHomeScreenAppBar();
    _buildHomePlaceholder();
    _buildHomeColumn();
  }

  void _buildChatStreamWidget() {
    _chatStreamWidget = StreamBuilder<QuerySnapshot>(
      stream: _chatStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(64.0),
              child: Column(
                children: [
                  const Text(
                    'Something went wrong',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(64.0),
              child: Column(
                children: [
                  const Text(
                    'Loading',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView(
          children: snapshot.data!.docs
              .map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                ChatEntry message = ChatEntry.fromMap(data);

                // Null/emptiness check
                if (message.message == null ||
                    message.userEmail == null ||
                    message.createdAt == null ||
                    message.message == '' ||
                    message.userEmail == '') {
                  return Container();
                }

                String username = _getUsernameFromEmail(message.userEmail!);

                return ListTile(
                  title: Text(message.message!),
                  subtitle: Text(
                    'Sent by $username at ${message.createdAt!.toString()}',
                  ),
                );
              })
              .toList()
              .cast(),
        );
      },
    );
  }

  String _getUsernameFromEmail(String email) {
    bool complete = false;
    String username = '';

    widget.dbHelper.getUserEntryFromEmail(email).then((result) {
      if (result != null) {
        if (result.username != null) {
          username = result.username!;
          complete = true;
        } else {
          complete = true;
        }
      } else {
        complete = true;
      }
    });

    while (!complete) {}

    return username;
  }

  void _buildChatForm() {
    _chatForm = Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        spacing: 24.0,
        children: [
          // Username field
          TextFormField(
            enabled: (_sendingMessage == 'ready'),
            controller: _messageController,
            decoration: InputDecoration(
              labelText: 'Chat Message',
              prefixIcon: const Icon(Icons.message),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Submit button
          ElevatedButton(
            onPressed: (_sendingMessage != 'ready') ? null : _submitChatForm,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text('Send Message')],
            ),
          ),
        ],
      ),
    );
  }

  void _submitChatForm() {
    // Lock interface, prepare to send update
    setState(() {
      _sendingMessage = 'pending';
    });

    ChatEntry message = ChatEntry(
      message: _messageController.text,
      userEmail: widget.authService.getEmail(),
      createdAt: DateTime.now(),
    );

    // Send message and register function to update status on completion
    widget.dbHelper.addChatEntry(widget.messageBoard, message).then((result) {
      setState(() {
        if (result) {
          _sendingMessage = 'complete';
        } else {
          _sendingMessage = 'error';
        }
      });
    });

    // Wait for update to commit and then update status
    while (_sendingMessage != 'ready') {
      if (_sendingMessage == 'complete') {
        // Reload entire interface upon completion to avoid desyncs
        setState(() {
          _messageController.text = '';
          _sendingMessage = 'ready';
        });
      } else if (_sendingMessage == 'error') {
        // TODO: send error up the chain
      }
    }
  }

  void _buildHomeScreenAppBar() {
    setState(() {
      homeScreenAppBar = AppBar(
        title: const Text('Firebase Chat App'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Home',
            onPressed: () {
              setState(() {
                _visibleScreen = 'home';
                _buildHomeColumn();
              });
            },
          ),

          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () {
              setState(() {
                _visibleScreen = 'profile';
                _buildHomeColumn();
              });
            },
          ),

          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              setState(() {
                _visibleScreen = 'settings';
                _buildHomeColumn();
              });
            },
          ),
        ],
      );
    });
  }

  void _buildHomePlaceholder() {
    setState(() {
      _homePlaceholder = Column(
        children: [
          Text('Welcome! Your email is $_email'),
          SizedBox(height: 20),
          Text('Other profile information:'),
          SizedBox(height: 20),
          (_userInfoString != null) ? Text(_userInfoString!) : Container(),
          (_userInfoString != null) ? SizedBox(height: 20) : Container(),
          ElevatedButton(
            onPressed: _logout,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text('Log out')],
            ),
          ),
        ],
      );
    });
  }

  void _buildHomeColumn() {
    setState(() {
      _homeColumn = Column(
        children: [
          (_visibleScreen == 'home') ? _homePlaceholder : Container(),
          (_visibleScreen == 'profile')
              ? ProfileScreen(widget.authService, widget.dbHelper)
              : Container(),
          (_visibleScreen == 'settings')
              ? SettingsScreen(widget.authService, widget.dbHelper)
              : Container(),
        ],
      );
    });
  }

  void _logout() {
    widget.authService.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homeScreenAppBar,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(64.0),
          child: _homeColumn,
        ),
      ),
    );
  }
}
