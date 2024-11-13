import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> _messageHandler(RemoteMessage message) async {
  print('Background message: ${message.notification!.body}');
  // Handle background message here (if needed).
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  runApp(MessagingTutorial());
}

class MessagingTutorial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Messaging',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Firebase Messaging'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FirebaseMessaging messaging;
  String? notificationText;
  String? fcmToken; // Variable to hold the FCM token

  @override
  void initState() {
    super.initState();
    messaging = FirebaseMessaging.instance;

    // Subscribe to the topic "messaging"
    messaging.subscribeToTopic("messaging");

    // Get and print the FCM token, and also update the state
    messaging.getToken().then((value) {
      setState(() {
        fcmToken = value; // Store the token in the state variable
      });
      print("FCM Token: $fcmToken"); // Print token in the console
    });

    // Listen for messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("Message received");
      print(event.notification!.body);
      print(event.data.values);

      // Extract the custom 'is_important' field from the notification payload
      bool isImportant = event.data['is_important'] == 'true';

      // Show the notification with different appearance based on importance
      _showNotificationDialog(event, isImportant);
    });

    // Handle when the app is opened via a notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Message clicked!');
    });
  }

  // Show the notification dialog with customized appearance
  void _showNotificationDialog(RemoteMessage message, bool isImportant) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isImportant ? Colors.redAccent : Colors.white, // Change color for important messages
          title: 
            Text(
              "Notification",
              style: TextStyle(color: isImportant ? Colors.white : Colors.black), // White text for important
            ),
          content: Text(
            message.notification?.body ?? 'No message content',
            style: TextStyle(color: isImportant ? Colors.white : Colors.black), // White text for important
          ),
          actions: [
            TextButton(
              child: 
                Text(
                  "Ok",
                  style: TextStyle(color: isImportant ? Colors.white : Colors.black), // Adjust button color
                ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Firebase Messaging Tutorial",
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              "FCM Token:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              fcmToken ?? "Retrieving token...", // Display the token or a placeholder text
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
