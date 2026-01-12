import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../widgets/custom_inputs.dart';
import 'login_screen.dart';
import 'landing_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // 1. Controllers to capture text
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // 2. State for Password Visibility
  bool _isPasswordHidden = true;

  // 3. Registration Logic
  void _handleRegister() {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    
    // Validation
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields"), backgroundColor: Colors.orange),
      );
      return;
    }

    if (password.length < 6) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 6 characters"), backgroundColor: Colors.orange),
      );
      return;
    }

    // Save to Hive Database
    final Box userBox = Hive.box('users');
    
    if (userBox.containsKey(email)) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account already exists! Please Login."), backgroundColor: Colors.red),
      );
      return;
    }

    // Create User Object
    userBox.put(email, {
      'name': name,
      'password': password,
      'joinedAt': DateTime.now().toString(),
    });

    // Success & Redirect
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Account Created! Redirecting to Login..."), backgroundColor: Colors.green),
    );

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    });
  }

  // 4. Social Media Button Handler
  void _handleSocialClick(String platform) {
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (_) => SocialAuthPage(platform: platform))
    );
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
              // 1. Matrix Background Image
              Container(
                height: size.height * 0.35,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/matrix_bg.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken),
                  ),
                ),
              ),

              // 2. Top Navigation (Back Button)
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
                height: size.height * 0.80,
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
                        "Register",
                        style: TextStyle(
                          color: Color(0xFF1B5E20),
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "Create your new account",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      const SizedBox(height: 30),

                      // Inputs with Controllers
                      CyberTextField(
                        hint: "Full Name", 
                        icon: Icons.person_outline,
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words, // Auto-Capitalize Names
                      ),
                      CyberTextField(
                        hint: "Email Address", 
                        icon: Icons.email_outlined,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      // Password with Toggle Logic
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

                      const SizedBox(height: 20),

                      // Register Button
                      CyberButton(
                        text: "Register",
                        onPressed: _handleRegister,
                      ),

                      const SizedBox(height: 25),

                      const Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text("Or continue with", style: TextStyle(color: Colors.grey)),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Social Icons (Now Clickable)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _socialButton(Icons.g_mobiledata, Colors.red, "Google"),
                          const SizedBox(width: 20),
                          _socialButton(Icons.apple, Colors.black, "Apple"),
                          const SizedBox(width: 20),
                          _socialButton(Icons.facebook, Colors.blue, "Facebook"),
                        ],
                      ),

                      const Spacer(),

                      // Sign In Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account? ", style: TextStyle(color: Colors.grey)),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                            child: const Text(
                              "Sign in",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B5E20),
                                decoration: TextDecoration.underline,
                              ),
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

  Widget _socialButton(IconData icon, Color color, String platform) {
    return InkWell( // Makes it clickable with ripple effect
      onTap: () => _handleSocialClick(platform),
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, color: color, size: 30),
      ),
    );
  }
}

// -----------------------------------------------------------
// NEW: Social Auth Simulator Page (Real-time trigger page)
// -----------------------------------------------------------
class SocialAuthPage extends StatelessWidget {
  final String platform;
  const SocialAuthPage({super.key, required this.platform});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFF1B5E20)),
            const SizedBox(height: 20),
            Text("Connecting to $platform...", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("This simulates the external OAuth login.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}