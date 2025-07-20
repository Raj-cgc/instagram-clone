import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_flutter/resources/auth_methods.dart';
import 'package:instagram_flutter/responsive/mobile_screen_layout.dart';
import 'package:instagram_flutter/responsive/responsive_layout_screen.dart';
import 'package:instagram_flutter/responsive/web_screen_layout.dart';
import 'package:instagram_flutter/screens/login_screen.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/utils/utils.dart';
import 'package:instagram_flutter/widgets/text_field_input.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  Uint8List? _image;

  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _usernameController.dispose();
  }

  void selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  void goToLoginScreen() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //Flexible(flex: 1, child: Container()),
                //insta logo svg image
                SvgPicture.asset(
                  'assets/images/ic_instagram.svg',
                  color: primaryColor,
                  height: 64,
                ),
                const SizedBox(height: 24),
                //circular widget to accept and show our selected file
                Stack(
                  children: [
                    _image == null
                        ? CircleAvatar(
                          radius: 64,
                          backgroundImage: AssetImage(
                            'assets/images/profile_default_icon.png',
                          ),
                        )
                        : CircleAvatar(
                          radius: 64,
                          backgroundImage: MemoryImage(_image!),
                        ),

                    Positioned(
                      bottom: -10,
                      right: -2,
                      child: IconButton(
                        onPressed: selectImage,
                        icon: Icon(Icons.add_a_photo),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 64),
                TextFieldInput(
                  textEditingController: _usernameController,
                  hintText: 'Enter your username',
                  textInputType: TextInputType.text,
                ),
                const SizedBox(height: 24),
                TextFieldInput(
                  textEditingController: _bioController,
                  hintText: 'Enter your bio',
                  textInputType: TextInputType.text,
                ),
                const SizedBox(height: 24),
                //texfield input for email
                TextFieldInput(
                  textEditingController: _emailController,
                  hintText: 'Enter your email',
                  textInputType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                //textfield input for password
                TextFieldInput(
                  textEditingController: _passwordController,
                  hintText: 'Enter your password',
                  textInputType: TextInputType.text,
                  isPassword: true,
                ),
                const SizedBox(height: 24),
                //signup button
                InkWell(
                  onTap: () async {
                    Uint8List? imageToUpload = _image;

                    setState(() {
                      _isLoading = true;
                    });
                    String res = await AuthMethods().signUpUser(
                      email: _emailController.text,
                      password: _passwordController.text,
                      username: _usernameController.text,
                      bio: _bioController.text,
                      file: imageToUpload,
                    );

                    if (res == "Success") {
                      setState(() {
                        _isLoading = false;
                      });
                      // Navigate to next screen
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder:
                              (context) => ResponsiveLayoutScreen(
                                webScreenLayout: WebScreenLayout(),
                                mobileScreenLayout: MobileScreenLayout(),
                              ),
                        ),
                      );
                      print("Signup successful");
                    } else {
                      setState(() {
                        _isLoading = false;
                      });
                      // Show error message
                      // ignore: use_build_context_synchronously
                      showSnackBar(res, context);
                      print("Signup error: $res");
                    }
                  },
                  child:
                      _isLoading == true
                          ? Center(child: CircularProgressIndicator())
                          : Container(
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              color: blueColor,
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12),
                            alignment: Alignment.center,
                            width: double.infinity,

                            child: Text('Sign Up'),
                          ),
                ),
                const SizedBox(height: 12),
                //Flexible(flex: 1, child: Container()),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      child: Text("Already have an account?"),
                    ),
                    GestureDetector(
                      onTap: goToLoginScreen,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Log In',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                //transitioning to signing up
              ],
            ),
          ),
        ),
      ),
    );
  }
}
