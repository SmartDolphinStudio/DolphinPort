// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../services/native_store.dart';
import '../../widgets/auth_dialogs.dart';
import '../../widgets/code_request_field.dart';
import '../../widgets/phone_number_field.dart';
import '../../widgets/three_dots_loader.dart';
import 'auth_header_background.dart';
import 'social_login_buttons.dart';

/// The two states shown on the single authentication screen.
enum AuthMode { login, register }

/// Authentication screen.
///
/// Login and sign-up live on the same screen: toggling [AuthMode] changes the
/// title and fields in place rather than opening a new page. In login mode the
/// identifier accepts an email, phone number, display name, UID or ID. In
/// sign-up mode the fields are phone (with a country dial-code selector),
/// password and verification code. Demo behaviour: nothing is verified; any
/// non-empty, well-formed input succeeds. On login the button shrinks into a
/// loading state and the screen slides up into the home screen.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  AuthMode _mode = AuthMode.login;
  bool _isLoading = false;
  bool _obscure = true;

  // Login controllers.
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Sign-up controllers.
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _regPasswordController = TextEditingController();
  final TextEditingController _regCodeController = TextEditingController();

  late final AnimationController _slideController;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slide = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1))
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
        );

    _slideController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.pushReplacementNamed(context, RouteNames.home);
      }
    });
  }

  /// Runs after a successful login or third-party quick action.
  void _proceed() {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) _slideController.forward();
    });
  }

  /// Records a third-party login and continues into the app.
  void _proceedSocial(String provider) {
    NativeStore.instance.recordLogin(provider, method: provider);
    _proceed();
  }

  /// Handles login submission, including empty-value validation.
  void _submitLogin() {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;
    if (identifier.isEmpty || password.isEmpty) {
      showAuthDialog(
        context,
        title: 'Cannot sign in',
        message: 'Please enter both your identifier and password.',
      );
      return;
    }
    NativeStore.instance.recordLogin(identifier, method: 'password');
    _proceed();
  }

  /// Validates the sign-up phone number and simulates sending the SMS code.
  Future<bool> _requestRegisterCode() async {
    if (_phoneController.text.trim().isEmpty) {
      await showAuthDialog(
        context,
        title: 'Cannot send code',
        message: 'Please enter your phone number first.',
      );
      return false;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code sent. In the demo, any six-digit code works.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    return true;
  }

  /// Validates every sign-up field and returns to the login state.
  Future<void> _submitRegister() async {
    final phone = _phoneController.text.trim();
    final password = _regPasswordController.text;
    final code = _regCodeController.text.trim();

    if (phone.isEmpty || password.isEmpty || code.length != 6) {
      await showAuthDialog(
        context,
        title: 'Cannot sign up',
        message:
            'Please enter your phone number, a password and the six-digit code.',
      );
      return;
    }

    final confirmed = await showAuthDialog(
      context,
      title: 'Account created',
      message: 'Your account is ready. Please sign in to continue.',
    );
    if (confirmed == true && mounted) {
      _phoneController.clear();
      _regPasswordController.clear();
      _regCodeController.clear();
      setState(() => _mode = AuthMode.login);
    }
  }

  /// Switches between login and sign-up without navigating.
  void _switchMode(AuthMode mode) {
    if (_isLoading) return;
    setState(() => _mode = mode);
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _regPasswordController.dispose();
    _regCodeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLogin = _mode == AuthMode.login;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: SlideTransition(
          position: _slide,
          child: Stack(
            children: [
              AuthHeaderBackground(
                subtitle: isLogin
                    ? 'Welcome back! Log in to continue.'
                    : 'Create your account to get started.',
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: size.height * 0.27),
                              Text(
                                isLogin ? 'Login' : 'Sign up',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...isLogin ? _loginFields() : _registerFields(),
                              const Spacer(),
                              _bottomLink(isLogin),
                              SizedBox(
                                height:
                                    12 + MediaQuery.of(context).padding.bottom,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Fields shown in login mode.
  List<Widget> _loginFields() {
    return [
      _fieldLabel('Email, phone or username'),
      const SizedBox(height: 6),
      Container(
        height: 50,
        decoration: AppDecorations.fieldBox(),
        child: TextField(
          controller: _identifierController,
          textInputAction: TextInputAction.next,
          decoration: AppDecorations.fieldDecoration(
            'Email, phone, name, UID or ID',
          ),
        ),
      ),
      const SizedBox(height: 12),
      _fieldLabel('Password'),
      const SizedBox(height: 6),
      _passwordBox(_passwordController),
      const SizedBox(height: 6),
      Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: () => Navigator.pushNamed(context, RouteNames.forgotPassword),
          child: const Text(
            'Forgot password?',
            style: TextStyle(fontSize: 12, color: Color(0xFF333333)),
          ),
        ),
      ),
      const SizedBox(height: 14),
      _submitButton('Login', _submitLogin),
      const SizedBox(height: 18),
      const _OrDivider(),
      const SizedBox(height: 16),
      SocialLoginButtons(onSocialLogin: _proceedSocial),
    ];
  }

  /// Fields shown in sign-up mode.
  List<Widget> _registerFields() {
    return [
      _fieldLabel('Phone number'),
      const SizedBox(height: 6),
      PhoneNumberField(controller: _phoneController),
      const SizedBox(height: 12),
      _fieldLabel('Password'),
      const SizedBox(height: 6),
      _passwordBox(_regPasswordController),
      const SizedBox(height: 12),
      _fieldLabel('Verification code'),
      const SizedBox(height: 6),
      CodeRequestField(
        controller: _regCodeController,
        onRequestCode: _requestRegisterCode,
      ),
      const SizedBox(height: 14),
      _submitButton('Sign up', _submitRegister),
      const SizedBox(height: 18),
      const _OrDivider(),
      const SizedBox(height: 16),
      SocialLoginButtons(onSocialLogin: _proceedSocial),
    ];
  }

  /// Label shown above a form field.
  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Color(0xFF333333),
      ),
    );
  }

  /// Password field on the standard grey box with a visibility toggle.
  Widget _passwordBox(TextEditingController controller) {
    return Container(
      height: 50,
      decoration: AppDecorations.fieldBox(),
      child: TextField(
        controller: controller,
        obscureText: _obscure,
        decoration: AppDecorations.fieldDecoration('••••••••').copyWith(
          suffixIcon: IconButton(
            icon: Icon(
              _obscure ? Icons.visibility_off : Icons.visibility,
              color: AppColors.textSecondary,
              size: 18,
            ),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
      ),
    );
  }

  /// Full-width black submit button that shrinks into a loader while signing in.
  Widget _submitButton(String text, VoidCallback onPressed) {
    final contentWidth = MediaQuery.of(context).size.width - 48;
    final showLoader = _isLoading && _mode == AuthMode.login;
    return Center(
      child: GestureDetector(
        onTap: showLoader ? null : onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
          width: showLoader ? 64 : contentWidth,
          height: 48,
          decoration: BoxDecoration(
            color: showLoader ? const Color(0xFF4A4A4A) : Colors.black,
            borderRadius: BorderRadius.circular(showLoader ? 25 : 12),
          ),
          alignment: Alignment.center,
          child: showLoader
              ? const ThreeDotsLoader()
              : Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  /// Bottom link that toggles between the two modes.
  Widget _bottomLink(bool isLogin) {
    return Center(
      child: GestureDetector(
        onTap: () => _switchMode(isLogin ? AuthMode.register : AuthMode.login),
        child: RichText(
          text: TextSpan(
            text: isLogin
                ? "Don't have an account? "
                : 'Already have an account? ',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            children: [
              TextSpan(
                text: isLogin ? 'Sign up' : 'Sign in',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A thin divider with the word "Or" centred between two hairlines.
class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: Color(0xFFDDDDDD))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Or',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
        Expanded(child: Divider(color: Color(0xFFDDDDDD))),
      ],
    );
  }
}
