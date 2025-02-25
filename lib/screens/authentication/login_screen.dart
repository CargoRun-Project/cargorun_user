import 'package:auto_route/auto_route.dart';
import 'package:cargo_run/providers/auth_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/app_router.gr.dart';
import '../../widgets/app_buttons.dart';
import '../../styles/app_colors.dart';
import '../../widgets/app_textfields.dart';
import '../../widgets/page_widgets/appbar_widget.dart';

@RoutePage()
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void navigate() {
    context.router.replaceAll([
      const HomeRoute(),
    ]);
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: appBarWidget(context, title: 'Login'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Please sign in to continue!',
                style: TextStyle(
                  fontSize: 17.0,
                  color: greyText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40.0),
              Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20.0),
                        AppTextField(
                          labelText: 'Email',
                          isPassword: false,
                          isEmail: true,
                          controller: _emailController,
                        ),
                        AppTextField(
                          labelText: 'Password',
                          isPassword: true,
                          controller: _passwordController,
                        ),
                        const SizedBox(height: 60.0),
                        Consumer<AuthProvider>(
                          builder: (context, watch, _) {
                            return (watch.loadingState == LoadingState.loading)
                                ? const LoadingButton(
                                    textColor: Colors.white,
                                    backgroundColor: primaryColor1,
                                  )
                                : AppButton(
                                    text: 'Sign In',
                                    hasIcon: false,
                                    backgroundColor: primaryColor1,
                                    textColor: Colors.white,
                                    onPressed: () async {
                                      await watch.loginUser(
                                        email: _emailController.text,
                                        password: _passwordController.text,
                                      );
                                      if (watch.loadingState ==
                                          LoadingState.success) {
                                        navigate();
                                      } else {
                                        showSnackBar(watch.errorMessage);
                                      }
                                    },
                                  );
                          },
                        ),
                        const SizedBox(height: 20.0),
                        Align(
                          alignment: Alignment.center,
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: const TextStyle(
                                color: greyText,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                              ),
                              children: [
                                TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      context.router
                                          .replace(const RegisterRoute());
                                    },
                                  text: 'Sign Up',
                                  style: const TextStyle(
                                    color: primaryColor2,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0)
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
