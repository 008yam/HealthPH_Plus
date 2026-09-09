import 'package:flutter/material.dart';
import 'main_page.dart';
import 'login_page.dart';
import 'theme/responsive.dart';


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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/HealthPhPlusLandingPageWithIcon.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
              padding: const EdgeInsets.only(bottom: 46),
              child: SizedBox(
                width: 34,
                height: 34,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  backgroundColor: Colors.white.withValues(alpha: 0.35),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF31459B)
                  ),
                )
              ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
