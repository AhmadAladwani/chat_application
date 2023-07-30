import 'package:chat_app_tutorial/widget/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  final Function toggle;
  SignUp(this.toggle);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool isLoading = false;

  final formKey = GlobalKey<FormState>();
  late final TextEditingController userNameTextEditingController;
  late final TextEditingController emailTextEditingController;
  late final TextEditingController passwordTextEditingController;

  Future<void> signMeUP() async {
    if (formKey.currentState!.validate()) {
      Map<String, String> userInfoMap = {
        'name': userNameTextEditingController.text,
        'email': emailTextEditingController.text
      };
      setState(() {
        isLoading = true;
      });
      try {
        final userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: emailTextEditingController.text,
          password: passwordTextEditingController.text,
        )
            .catchError((error) {
          print(error.toString());
        });
        final user = userCredential.user;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set(userInfoMap);
        } else {
          return showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('User is null'),
              content: const Text('This is an error'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Okay.'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(e.toString()),
            content: const Text('This is an error'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Okay.'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    userNameTextEditingController = TextEditingController();
    emailTextEditingController = TextEditingController();
    passwordTextEditingController = TextEditingController();
  }

  @override
  void dispose() {
    userNameTextEditingController.dispose();
    emailTextEditingController.dispose();
    passwordTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: isLoading
          ? Container(
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height - 50,
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          validator: (val) {
                            return val!.isEmpty || val.length < 2
                                ? 'Please provide a valid username'
                                : null;
                          },
                          controller: userNameTextEditingController,
                          style: simpleTextStyle(),
                          decoration: textFieldInputDecoration('username'),
                        ),
                        TextFormField(
                          validator: (val) {
                            return RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(val!)
                                ? null
                                : "Please provide a valid emailid";
                          },
                          controller: emailTextEditingController,
                          style: simpleTextStyle(),
                          decoration: textFieldInputDecoration('email'),
                        ),
                        TextFormField(
                          obscureText: true,
                          validator: (val) {
                            return val!.length > 6
                                ? null
                                : 'Please provide password 6+ character';
                          },
                          controller: passwordTextEditingController,
                          style: simpleTextStyle(),
                          decoration: textFieldInputDecoration('password'),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Text(
                              'Forgot Password?',
                              style: simpleTextStyle(),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        GestureDetector(
                          onTap: () async {
                            await signMeUP();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xff007EF4),
                                  Color(0xff2A75BC),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              'Sign Up',
                              style: mediumTextStyle(),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text(
                            'Sign Up with Google',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have account? ',
                              style: mediumTextStyle(),
                            ),
                            GestureDetector(
                              onTap: () {
                                widget.toggle();
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: const Text(
                                  'SignIn now',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
