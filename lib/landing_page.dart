import 'package:flutter/material.dart';
import 'widgets/feature_tile.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HealthPH+"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            child: const Text("Login"),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "HealthPH+",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              const Text(
                "AI-Powered Healthcare Platform.",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {},
                child: const Text("Get Started"),
              ),

              const SizedBox(height: 30),

              const FeatureTile(
                icon: Icons.flash_on,
                title: "Fast",
                description: "Our app is optimized for speed.",
              ),

              const FeatureTile(
                icon: Icons.security,
                title: "Secure",
                description: "Your data is protected.",
              ),

              const FeatureTile(
                icon: Icons.support_agent,
                title: "Support",
                description: "We offer great support.",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
