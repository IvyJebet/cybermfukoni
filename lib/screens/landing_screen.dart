import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Image (Local Asset)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/matrix_bg.jpg'), // Uses your local file
                fit: BoxFit.cover,
                // slight darken filter to make text pop
                colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken),
              ),
            ),
          ),
          
          // 2. Top Right Arrow (kept from previous requirement)
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 30),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
              ),
            ),
          ),

          // 3. Main Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 2), // Pushes text down to ~30-40% of screen height
                
                // Big Text (Positioned like "The best app for your plants")
                const Text(
                  "KEEP\nYOURSELF SAFE\nDIGITALLY",
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.2,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Your digital defense starts here",
                  style: TextStyle(
                    color: Colors.white70, 
                    fontSize: 18, 
                    fontWeight: FontWeight.w500
                  ),
                ),
                
                const Spacer(flex: 3), // Pushes buttons to the bottom
                
                // "Sign In" Button (Glass/Translucent Style)
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                    style: ElevatedButton.styleFrom(
                      // Semi-transparent dark green/grey to match the reference look
                      backgroundColor: Colors.white.withOpacity(0.2), 
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
                      ),
                    ),
                    child: const Text(
                      "Sign in",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                
                const SizedBox(height: 15),
                
                // "Create an account" Text Link
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
                    child: const Text(
                      "Create an account",
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 16, 
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}