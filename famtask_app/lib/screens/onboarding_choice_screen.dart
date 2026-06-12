import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import 'join_family_screen.dart';
import 'create_family_screen.dart';

class OnboardingChoiceScreen extends StatelessWidget {
  const OnboardingChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            right: -size.width * 0.15,
            top: -size.width * 0.15,
            child: Container(
              width: size.width * 0.7,
              height: size.width * 0.7,
              decoration: BoxDecoration(
                color: const Color(0xFF8C52FF).withOpacity(0.18),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  // Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: FamTheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.diversity_3_rounded,
                      size: 55,
                      color: FamTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 35),
                  Text(
                    'Welcome to',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: FamTheme.darkPurple,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'FAMTASK',
                    style: GoogleFonts.outfit(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: FamTheme.primary,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Connect with your family to start managing tasks together in real-time, share shopping lists, and receive location-based assistance.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: FamTheme.darkPurple.withOpacity(0.65),
                        height: 1.6,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Join Family Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const JoinFamilyScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Join Family with code'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Enter an invitation code from your family admin',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: FamTheme.darkPurple.withOpacity(0.4),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Divider OR
                  Row(
                    children: [
                      Expanded(child: Divider(color: FamTheme.darkPurple.withOpacity(0.1))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'OR',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: FamTheme.darkPurple.withOpacity(0.35),
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: FamTheme.darkPurple.withOpacity(0.1))),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Create Family Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CreateFamilyScreen()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: FamTheme.primary,
                        side: const BorderSide(color: FamTheme.primary, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        textStyle: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text('Create New Family'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Only create if your family is not already using FamTask',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: FamTheme.darkPurple.withOpacity(0.4),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
