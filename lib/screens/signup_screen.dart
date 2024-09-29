import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/resources/auth_method.dart';
import 'package:instagram_clone/responsive/mobile_screen_layout.dart';
import 'package:instagram_clone/responsive/responsive_layout_screen.dart';
import 'package:instagram_clone/responsive/web_screen_layout.dart';
import 'package:instagram_clone/screens/login_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/blue_button.dart';
import 'package:instagram_clone/widgets/text_field_input.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  late Uint8List _image;
  bool isLoading = false;
  bool isAssigningImage = false;

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
    final res = await AuthMethod.signupUser(
      email: _emailController.text,
      password: _passwordController.text,
      username: _usernameController.text,
      bio: _bioController.text,
      file: _image,
    );

    setState(() {
      isLoading = false;
    });

    if (!mounted) {
      return;
    }

    if (res != 'success') {
      showSnackBar(res, context);
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const ResponsiveLayout(
          webScreenLayout: WebScreenLayout(),
          mobileScreenLayout: MobileScreenLayout(),
        ),
      ));
    }
  }

  void navigateToLogin() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const LoginScreen(),
    ));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context)
                .size
                .height, // Ensures Column takes up full height
          ),
          child: IntrinsicHeight(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 2,
                    child: Container(),
                  ),
                  SvgPicture.asset(
                    'assets/images/ic_instagram.svg',
                    // ignore: deprecated_member_use
                    color: primaryColor,
                    height: 64,
                  ),
                  const SizedBox(height: 64),
                  //* Profile image
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
                  TextFieldInput(
                    textEditingController: _usernameController,
                    hintText: 'Enter your Username',
                    textInputType: TextInputType.text,
                  ),
                  const SizedBox(height: 24),
                  TextFieldInput(
                    textEditingController: _emailController,
                    hintText: 'Enter your email',
                    textInputType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24),
                  TextFieldInput(
                    textEditingController: _passwordController,
                    hintText: 'Enter your password',
                    textInputType: TextInputType.text,
                    isPass: true,
                  ),
                  const SizedBox(height: 24),
                  TextFieldInput(
                    textEditingController: _bioController,
                    hintText: 'Enter your bio',
                    textInputType: TextInputType.text,
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
                        child: const Text("Having an account?"),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context)
                            .pushReplacement(MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        )),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: const Text(
                            " Login.",
                            style: TextStyle(fontWeight: FontWeight.bold),
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
