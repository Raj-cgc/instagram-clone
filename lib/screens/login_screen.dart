import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_flutter/resources/auth_methods.dart';
import 'package:instagram_flutter/responsive/mobile_screen_layout.dart';
import 'package:instagram_flutter/responsive/responsive_layout_screen.dart';
import 'package:instagram_flutter/responsive/web_screen_layout.dart';
import 'package:instagram_flutter/screens/signup_screen.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/utils/utils.dart';
import 'package:instagram_flutter/widgets/text_field_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  bool _isLoading = false;

  void goToSinupScreen() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => SignupScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(flex: 1, child: Container()),
              //insta logo svg image
              SvgPicture.asset(
                'assets/images/ic_instagram.svg',
                color: primaryColor,
                height: 64,
              ),
              const SizedBox(height: 64),

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
              //login button
              InkWell(
                onTap: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  String res = await AuthMethods().loginUser(
                    email: _emailController.text,
                    password: _passwordController.text,
                  );
                  if (res == 'success') {
                    setState(() {
                      _isLoading = false;
                    });
                    //Navigate to next screen
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder:
                            (context) => ResponsiveLayoutScreen(
                              webScreenLayout: WebScreenLayout(),
                              mobileScreenLayout: MobileScreenLayout(),
                            ),
                      ),
                    );
                    // ignore: use_build_context_synchronously
                    showSnackBar(res, context);
                    print('Login Successful');
                  } else {
                    setState(() {
                      _isLoading = false;
                    });
                    // ignore: use_build_context_synchronously
                    showSnackBar(res, context);
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

                          child: Text('Log In'),
                        ),
              ),
              const SizedBox(height: 12),
              Flexible(flex: 1, child: Container()),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    child: Text("Don't have an account?"),
                  ),
                  GestureDetector(
                    onTap: goToSinupScreen,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Sign Up',
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
    );
  }
}
