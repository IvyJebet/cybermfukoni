import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../widgets/custom_inputs.dart'; 
import 'signup_screen.dart';
import 'home_screen.dart';
import 'landing_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // State Variables
  bool _isPasswordHidden = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedUser();
  }

  // Load saved email if "Remember Me" was used before
  void _loadRememberedUser() {
    final settings = Hive.box('settings');
    if (settings.containsKey('rememberedEmail')) {
      setState(() {
        _emailController.text = settings.get('rememberedEmail');
        _rememberMe = true;
      });
    }
  }

  // Login Logic
  void _handleLogin() {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final Box userBox = Hive.box('users'); 
    final Box settingsBox = Hive.box('settings'); 

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields"), backgroundColor: Colors.orange),
      );
      return;
    }

    // 1. Check if user exists
    if (!userBox.containsKey(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User account not found!"), backgroundColor: Colors.red),
      );
      return;
    }

    // 2. Validate Password
    final userData = userBox.get(email);
    if (userData['password'] != password) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Wrong Username or Password!"), backgroundColor: Colors.red),
      );
      return;
    }

    // 3. Success & Session Saving
    settingsBox.put('lastLoggedInUser', email);
    settingsBox.put('lastActiveTime', DateTime.now().toString());

    // Handle "Remember Me" Persistence
    if (_rememberMe) {
      settingsBox.put('rememberedEmail', email);
    } else {
      settingsBox.delete('rememberedEmail');
    }

    // Navigate and Clear History
    Navigator.pushAndRemoveUntil(
      context, 
      MaterialPageRoute(builder: (_) => const HomeScreen()), 
      (route) => false 
    );
  }

  // Forgot Password Logic
  void _handleForgotPassword() {
    final String email = _emailController.text.trim();
    final Box userBox = Hive.box('users');

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your Email first to reset password.")),
      );
      return;
    }

    if (userBox.containsKey(email)) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ResetPasswordScreen(email: email)));
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User account not found! Cannot reset password."), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      // Background matches theme scaffold color
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Stack(
            children: [
              // 1. Matrix Background with Gradient Fade
              Positioned.fill(
                bottom: size.height * 0.5,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/matrix_bg.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          theme.scaffoldBackgroundColor, // Fade into dark bg
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Back Button
              Positioned(
                top: 50,
                left: 20,
                child: GestureDetector(
                  onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LandingScreen())),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24)
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  ),
                ),
              ),

              // 3. Main Login Card (Dark & Modern)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: size.height * 0.7,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  decoration: BoxDecoration(
                    color: theme.cardColor, // Uses the cyberSurface color
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.05), width: 1)
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 30,
                        offset: const Offset(0, -10),
                      )
                    ]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Welcome Back",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.primaryColor, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text("Secure login to your digital boma", style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 40),

                      // Email Input
                      CyberTextField(
                        hint: "Email Address",
                        icon: Icons.email_outlined,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textCapitalization: TextCapitalization.none,
                      ),

                      const SizedBox(height: 15),

                      // Password Input
                      CyberTextField(
                        hint: "Password",
                        icon: Icons.lock_outline,
                        isPassword: true,
                        isObscured: _isPasswordHidden,
                        controller: _passwordController,
                        onEyePressed: () {
                          setState(() {
                            _isPasswordHidden = !_isPasswordHidden;
                          });
                        },
                      ),

                      // Remember Me & Forgot Password
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => _rememberMe = !_rememberMe),
                              child: Row(
                                children: [
                                  Icon(
                                    _rememberMe ? Icons.check_circle : Icons.circle_outlined, 
                                    color: theme.primaryColor, 
                                    size: 20
                                  ),
                                  const SizedBox(width: 8),
                                  const Text("Remember Me", style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: _handleForgotPassword,
                              child: const Text("Forgot Password?", style: TextStyle(color: Colors.grey)),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Login Button (Uses Theme.elevatedButtonTheme)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleLogin,
                          child: const Text("LOGIN"),
                        ),
                      ),

                      const Spacer(),

                      // Sign Up Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have account? ", style: TextStyle(color: Colors.grey)),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
                            child: Text(
                              "Sign up",
                              style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor, decoration: TextDecoration.underline),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
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

// ---------------------------------------------------------
// Reset Password Screen (For Real-time Renewal)
// ---------------------------------------------------------
class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newPassController = TextEditingController();
  
  void _updatePassword() {
    if (_newPassController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password too short!")));
      return;
    }
    
    // Update Hive DB
    final box = Hive.box('users');
    final oldData = box.get(widget.email);
    box.put(widget.email, {
      ...oldData, 
      'password': _newPassController.text.trim()
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password Updated! Please Login.")));
    Navigator.pop(context); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Renew Password")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Resetting password for:\n${widget.email}", textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            
            CyberTextField(
              hint: "Enter New Password", 
              icon: Icons.lock_reset, 
              isPassword: true, 
              controller: _newPassController
            ),
            
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _updatePassword, child: const Text("Update Password")),
            )
          ],
        ),
      ),
    );
  }
}