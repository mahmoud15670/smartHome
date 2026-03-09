import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:smarthome/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthWrapper(),
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return HomePage();
        }
        return LoginPage();
      },
    );
  }
}

class LoginPage extends StatelessWidget {
  final email = TextEditingController();
  final password = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: email,
              decoration: InputDecoration(hintText: "Email"),
            ),
            TextField(
              controller: password,
              decoration: InputDecoration(hintText: "Password"),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: email.text,
                  password: password.text,
                );
              },
              child: Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool relayState = false;
  late DatabaseReference ref;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    ref = FirebaseDatabase.instance.ref("devices/$uid/relay");

    ref.onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          relayState = event.snapshot.value as bool;
        });
      }
    });
  }

  void toggle() {
    ref.set(!relayState);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Smart Home"),
        actions: [
          IconButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Switch(value: relayState, onChanged: (val) => toggle()),
      ),
    );
  }
}
