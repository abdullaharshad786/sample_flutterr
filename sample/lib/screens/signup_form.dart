import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '/widgets/start_app.dart';
import '/models/logged_user.dart';
import 'package:provider/provider.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  var name = '';
  var email = '';
  var password = '';
  var isSignIn = false;
  var isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isSignIn ? 'SignIn' : 'SignUp'),
        centerTitle: true,
      ),
      body: Form(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if(!isSignIn) Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      labelText: 'Name',
                    ),
                    autocorrect: false,
                    onChanged: (value) {
                      name = value;
                    },
                    validator: (value) {
                      if (value != null && value.length <= 4) {
                        return "Name is too short.";
                      }
                    },
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      labelText: 'Email',
                    ),
                    autocorrect: false,
                    onChanged: (value) {
                      email = value;
                    },
                    validator: (value) {
                      if (value != null && !value.contains('@')) {
                        return "Email does not have @";
                      }
                    },
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      labelText: 'Password',
                    ),
                    autocorrect: false,
                    obscureText: true,
                    onChanged: (value) {
                      password = value;
                    },
                    validator: (value) {
                      if (value != null && value.length < 6) {
                        return "Password is too short";
                      }
                    },
                  ),
                ),
                _submitButton(context),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                          children: [
                            TextSpan(
                                text: isSignIn
                                    ? "I'm a new user, "
                                    : "I'm already a member, "),
                            TextSpan(
                              text: isSignIn ? 'Sign Up' : 'Sign In',
                              style: TextStyle(
                                  color: Theme.of(context).indicatorColor),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  setState(() {
                                    isSignIn = !isSignIn;
                                  });
                                },
                            ),
                          ]),
                    ),
                  ),
                ),
                const Divider(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _submitButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 35, horizontal: 15),
      child: isLoading ? const CircularProgressIndicator() : TextButton(
        child: Center(
          child: ListTile(
            title: Text(isSignIn ? 'SignIn' : 'SignUp'),
          ),
        ),
        onPressed: () {
          if(!isLoading) {
            FocusScope.of(context).requestFocus(FocusNode());
            var snackBar = const SnackBar(content: Text('Signing Up'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            _saveForm(context);
          }
        },
      ),
    );
  }

  Future<void> _saveForm(BuildContext ctx) async {
    final loggedUser = Provider.of<LoggedUser>(context, listen: false);
    final auth = FirebaseAuth.instance;

    UserCredential authResult;
    try {
      setState(() {
        isLoading = true;
      });
      if(isSignIn) {
        authResult = await auth.signInWithEmailAndPassword(
            email: email, password: password);
      }else{
        authResult = await auth.createUserWithEmailAndPassword(
            email: email, password: password);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(authResult.user!.uid)
            .set(
          {
            'name': name,
            'email': email,
            'membership': 'STANDARD',
          },
          SetOptions(merge: true),
        );
      }
      await loggedUser.setProfileInfo();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const StartApp()),
      );

    } catch (error) {
      var message = 'An Error occurred, please check your credentials!';
      var snackBar = SnackBar(content: Text(message));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
