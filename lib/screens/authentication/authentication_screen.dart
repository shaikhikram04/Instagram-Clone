import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/screens/authentication/login_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/blue_button.dart';
import 'package:instagram_clone/widgets/text_field_input.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  String username = '';
  String email = '';
  String password = '';
  String bio = '';
  late Uint8List _image;
  bool isLoading = false;
  bool isAssigningImage = false;
  bool _isPasswordVisible = false;
  bool _isLogin = true;

  @override
  void initState() {
    super.initState();
    loadAssetImage();
  }

  Future<void> loadAssetImage() async {
    setState(() {
      isAssigningImage = true;
    });
    final byte =
        await rootBundle.load('assets/images/instagram_default_pfp.png');
    setState(() {
      _image = byte.buffer.asUint8List();
      isAssigningImage = false;
    });
  }

  void selectImage() async {
    final im = await pickImage(ImageSource.gallery);
    if (im == null) return;

    setState(() {
      _image = im;
    });
  }

  Future<void> signupUser() async {
    setState(() {
      isLoading = true;
    });
    // final res = await AuthMethod.signupUser(
    //   email: _emailController.text,
    //   password: _passwordController.text,
    //   username: _usernameController.text,
    //   bio: _bioController.text,
    //   file: _image,
    // );

    setState(() {
      isLoading = false;
    });

    if (!mounted) {
      return;
    }

    // if (res != 'success') {
    //   showSnackBar(res, context);
    // } else {
    //   Navigator.of(context).pushReplacement(MaterialPageRoute(
    //     builder: (context) => const ResponsiveLayout(
    //       webScreenLayout: WebScreenLayout(),
    //       mobileScreenLayout: MobileScreenLayout(),
    //     ),
    //   ));
    // }
  }

  void navigateToLogin() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const LoginScreen(),
    ));
  }

  @override
  void dispose() {
    super.dispose();
  }

  void changePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
              minHeight: height // Ensures Column takes up full height
              ),
          child: IntrinsicHeight(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 40,
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/images/ic_instagram.svg',
                    // ignore: deprecated_member_use
                    color: primaryColor,
                    height: 64,
                  ),
                  SizedBox(
                    height: height * 0.07,
                  ),
                  //* Profile image
                  if (!_isLogin)
                    isAssigningImage
                        ? const CircularProgressIndicator(color: blueColor)
                        : Stack(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.transparent,
                                radius: 64,
                                backgroundImage: MemoryImage(_image),
                              ),
                              Positioned(
                                bottom: -10,
                                left: 80,
                                child: IconButton(
                                  onPressed: selectImage,
                                  icon: const Icon(Icons.add_a_photo),
                                  iconSize: 30,
                                  color: primaryColor,
                                ),
                              )
                            ],
                          ),
                  const SizedBox(height: 24),
                  if (!_isLogin)
                    TextFieldInput(
                      keyValue: 'username',
                      hintText: 'Enter your Username',
                      textInputType: TextInputType.text,
                      onSaved: (value) {
                        username = value;
                      },
                      validator: (String value) {
                        return null;
                      },
                    ),
                  const SizedBox(height: 24),
                  TextFieldInput(
                    keyValue: 'email',
                    hintText: 'Enter your email',
                    textInputType: TextInputType.emailAddress,
                    onSaved: (value) {
                      email = value;
                    },
                    validator: (String value) {
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  TextFieldInput(
                    keyValue: 'password',
                    hintText: 'Enter your password',
                    textInputType: TextInputType.text,
                    isPass: true,
                    isPassVisible: _isPasswordVisible,
                    changePasswordVisibility: changePasswordVisibility,
                    onSaved: (value) {
                      password = value;
                    },
                    validator: (String value) {
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  if (!_isLogin)
                    TextFieldInput(
                      keyValue: 'bio',
                      hintText: 'Enter your bio',
                      textInputType: TextInputType.text,
                      onSaved: (value) {
                        bio = value;
                      },
                      validator: (String value) {
                        return null;
                      },
                    ),
                  const SizedBox(height: 24),
                  BlueButton(
                    onTap: signupUser,
                    label: 'Send',
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    flex: 2,
                    child: Container(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          _isLogin
                              ? "Don't have an account?"
                              : "Having an account?",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isLogin = !_isLogin;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            _isLogin ? " Sign Up." : " Login.",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
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
