import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/models/logged_user.dart';
import '/screens/onboarding_screen.dart';
import '/screens/splash_screen.dart';
import '/screens/todo_screen.dart';
import 'package:provider/provider.dart';

class StartApp extends StatelessWidget {
  const StartApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if(snapshot.connectionState==ConnectionState.waiting){
            return const SplashScreen();
          }else if(snapshot.hasData) {
            Provider.of<LoggedUser>(context, listen: false)
                .setProfileInfo();
            return const TodoScreen();
          }
          else{
            return const OnboardingScreen();
          }
        }
    );
  }
}
