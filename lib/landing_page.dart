import 'package:flutter/material.dart';
import 'main_page.dart';
import 'login_page.dart';
import 'pages/intro_tutorial_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {

  static const Duration _splashDelay = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _goToMainAfterDelay();
  }

  Future<void> _goToMainAfterDelay() async {
    await Future.delayed(_splashDelay);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      );
  }

  void goToMainPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MainPage()),
    );
  }

  void goToLoginPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 71, 94, 189),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Backdrop1.png'),
            fit: BoxFit.cover,
            opacity: 0.18,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(),

                // CENTER LOGO
                Image.asset('assets/images/healthphpluslogo.png', height: 650),

                const Spacer(),

                // VERSION AND DEPARTMENT
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "v1.0",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Text(
                      "Department of Health",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // ROTATING SPINNER
                const SizedBox(
                  width: 34,
                  height: 34,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    backgroundColor: Color(0x33FFFFFF),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),

                const SizedBox(height: 40),

                // CONTINUE BUTTON
                /* 
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: goToMainPage,
                    icon: const Icon(Icons.login),
                    label: const Text(
                      "Continue to Login",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.indigo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),*/
                const SizedBox(height: 29),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
