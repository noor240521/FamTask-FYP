import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import 'navigation_container.dart';

class FamilyCreatedScreen extends StatelessWidget {
  final String familyName;
  final String inviteCode;

  const FamilyCreatedScreen({
    super.key,
    required this.familyName,
    required this.inviteCode,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final codeCharacters = inviteCode.toUpperCase().split('');

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
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  IconButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const NavigationContainer()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: FamTheme.darkPurple),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Family Group Created',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: FamTheme.darkPurple,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your family group is created. Share this code below to invite members.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: FamTheme.darkPurple.withOpacity(0.6),
                      height: 1.5,
                    ),
                  ),
                  const Spacer(),
                  // Invitation Details Card
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: FamTheme.darkPurple.withOpacity(0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Family Name:',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: FamTheme.darkPurple.withOpacity(0.4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            familyName,
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: FamTheme.darkPurple,
                            ),
                          ),
                          const SizedBox(height: 25),
                          Text(
                            'Invite Code:',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: FamTheme.darkPurple.withOpacity(0.4),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // 6 characters in rounded blocks
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: codeCharacters.map((char) {
                              return Container(
                                width: size.width > 400 ? 50 : 42,
                                height: size.width > 400 ? 55 : 46,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: FamTheme.softBackground,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: FamTheme.primary.withOpacity(0.15)),
                                ),
                                child: Text(
                                  char,
                                  style: GoogleFonts.outfit(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: FamTheme.primary,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'Tap to copy or share this code with your family',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: FamTheme.darkPurple.withOpacity(0.4),
                            ),
                          ),
                          const SizedBox(height: 25),
                          // Buttons Row
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: inviteCode));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Invite code copied to clipboard!'),
                                        backgroundColor: FamTheme.primary,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.copy_rounded, size: 18),
                                  label: const Text('Copy Code'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF0E7FF),
                                    foregroundColor: FamTheme.primary,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Sharing interface triggered!'),
                                        backgroundColor: FamTheme.secondary,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.share_rounded, size: 18),
                                  label: const Text('Share Invite'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: FamTheme.secondary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: Text(
                      'Members can join using this code\nfrom the Join Family screen',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: FamTheme.darkPurple.withOpacity(0.4),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Continue to Home button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const NavigationContainer()),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FamTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue to Home',
                            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
