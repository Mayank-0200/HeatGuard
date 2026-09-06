import 'package:flutter/material.dart';

import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController nameController =
      TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void login() {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your name."),
        ),
      );

      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          name: name,
          email: "",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFFFF8F0),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(25),

            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [
                // LOGO
                Container(
                  height: 100,
                  width: 100,

                  decoration:
                      BoxDecoration(
                    color: Colors.orange,
                    borderRadius:
                        BorderRadius.circular(
                      25,
                    ),
                  ),

                  child: const Icon(
                    Icons.wb_sunny,
                    color: Colors.white,
                    size: 60,
                  ),
                ),

                const SizedBox(height: 25),

                // TITLE
                const Text(
                  "HEATGUARD",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight:
                        FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Extreme Heat Early Warning System",
                  textAlign:
                      TextAlign.center,

                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 40),

                // NAME FIELD
                TextField(
                  controller:
                      nameController,

                  decoration:
                      InputDecoration(
                    labelText:
                        "Your Name",

                    hintText:
                        "Enter your name",

                    prefixIcon:
                        const Icon(
                      Icons.person,
                    ),

                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        15,
                      ),
                    ),

                    filled: true,

                    fillColor:
                        Colors.white,
                  ),

                  textInputAction:
                      TextInputAction.done,

                  onSubmitted: (_) =>
                      login(),
                ),

                const SizedBox(height: 20),

                // CONTINUE BUTTON
                SizedBox(
                  width:
                      double.infinity,
                  height: 55,

                  child:
                      ElevatedButton(
                    onPressed: login,

                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          Colors.orange,

                      foregroundColor:
                          Colors.white,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          15,
                        ),
                      ),
                    ),

                    child: const Text(
                      "CONTINUE",

                      style:
                          TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  "Stay informed. Stay safe.",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}