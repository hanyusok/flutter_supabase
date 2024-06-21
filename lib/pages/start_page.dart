import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  bool _signInLoading = false;
  bool _signUpLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _googleSignInLoading = false;

  @override
  void dispose() {
    supabase.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.network(
                      "https://seeklogo.com/images/S/supabase-logo-DCC676FFE2-seeklogo.com.png",
                      height: 150,
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Field is required!";
                        }
                        return null;
                      },
                      controller: _emailController,
                      decoration: const InputDecoration(label: Text("Email")),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "password is required!";
                        }
                        return null;
                      },
                      controller: _passwordController,
                      decoration:
                          const InputDecoration(label: Text("Password")),
                      obscureText: true,
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    /* sign in button */
                    _signInLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : ElevatedButton(
                            onPressed: () async {
                              final isValid = _formKey.currentState?.validate();
                              if (isValid != true) {
                                return;
                              }
                              setState(() {
                                _signInLoading = true;
                              });
                              try {
                                await supabase.auth.signInWithPassword(
                                    email: _emailController.text,
                                    password: _passwordController.text);
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text("Sign In failed! "),
                                  backgroundColor: Colors.red,
                                ));
                                setState(() {
                                  _signInLoading = false;
                                });
                              }
                            },
                            child: const Text("Sign In")),

                    /* sign up button */
                    _signUpLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : OutlinedButton(
                            onPressed: () async {
                              final isValid = _formKey.currentState?.validate();
                              if (isValid != true) {
                                return;
                              }
                              setState(() {
                                _signUpLoading = true;
                              });
                              try {
                                await supabase.auth.signUp(
                                    email: _emailController.text,
                                    password: _passwordController.text);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content:
                                      Text("Success! confirmation email sent!"),
                                  backgroundColor: Colors.green,
                                ));
                                setState(() {
                                  _signUpLoading = false;
                                });
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text(
                                      "Sign up failed! confirmation email sent!"),
                                  backgroundColor: Colors.red,
                                ));
                                setState(() {
                                  _signUpLoading = false;
                                });
                              }
                            },
                            child: const Text("Sign Up")),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.all(15),
                          child: Text("Or"),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    _googleSignInLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : OutlinedButton.icon(
                            onPressed: () async {
                              setState(() {
                                _googleSignInLoading = true;
                              });
                              try {
                                await supabase.auth.signInWithOAuth(
                                    OAuthProvider.google,
                                    redirectTo: kIsWeb
                                        ? null
                                        : 'io.supabase.myflutterapp://login-callback');
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text("google signup failed!"),
                                  backgroundColor: Colors.red,
                                ));
                                setState(() {
                                  _googleSignInLoading = false;
                                });
                              }
                            },
                            icon: Image.network(
                              "https://clipartcraft.com/images/google-logo-png.png",
                              height: 20,
                            ),
                            label: const Text("continue with Google"))
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
