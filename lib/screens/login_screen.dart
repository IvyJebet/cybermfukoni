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

  // NEW: Load saved email if "Remember Me" was used before
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
    final Box userBox = Hive.box('users'); // Access the User DB
    final Box settingsBox = Hive.box('settings'); // Access Settings DB

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
    
    // A. Save Session for Auto-Login (Handled in main.dart)
    settingsBox.put('lastLoggedInUser', email);
    settingsBox.put('lastActiveTime', DateTime.now().toString());

    // B. Handle "Remember Me" Persistence
    if (_rememberMe) {
      settingsBox.put('rememberedEmail', email);
    } else {
      settingsBox.delete('rememberedEmail');
    }

    // C. Navigate and Clear History (Back button will now exit app)
    Navigator.pushAndRemoveUntil(
      context, 
      MaterialPageRoute(builder: (_) => const HomeScreen()), 
      (route) => false // Removes all previous routes
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
      // Navigate to Reset Page
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

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Stack(
            children: [
              // 1. Matrix Background
              Container(
                height: size.height * 0.45,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/matrix_bg.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken),
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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  ),
                ),
              ),

              // 3. White Container
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: size.height * 0.75,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Welcome Back",
                        style: TextStyle(color: Color(0xFF1B5E20), fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      const Text("Login to your account", style: TextStyle(color: Colors.grey, fontSize: 16)),
                      const SizedBox(height: 40),

                      // Email Input (With Auto-Caps)
                      CyberTextField(
                        hint: "Email Address",
                        icon: Icons.email_outlined,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress, // Optimized for email
                        textCapitalization: TextCapitalization.none, // Emails usually lowercase
                      ),

                      // Password Input (With Toggle)
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
                                    color: const Color(0xFF1B5E20), 
                                    size: 20
                                  ),
                                  const SizedBox(width: 5),
                                  const Text("Remember Me", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: _handleForgotPassword,
                              child: const Text("Forgot Password?", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Login Button
                      CyberButton(
                        text: "Login",
                        onPressed: _handleLogin,
                      ),

                      const Spacer(),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have account? ", style: TextStyle(color: Colors.grey)),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
                            child: const Text(
                              "Sign up",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20), decoration: TextDecoration.underline),
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
      ...oldData, // keep name, etc
      'password': _newPassController.text.trim()
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password Updated! Please Login.")));
    Navigator.pop(context); // Go back to login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Renew Password"), backgroundColor: Colors.deepPurple.shade100),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Resetting password for:\n${widget.email}", textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            CyberTextField(
              hint: "Enter New Password", 
              icon: Icons.lock_reset, 
              isPassword: true, 
              controller: _newPassController
            ),
            const SizedBox(height: 20),
            CyberButton(text: "Update Password", onPressed: _updatePassword)
          ],
        ),
      ),
    );
  }
}