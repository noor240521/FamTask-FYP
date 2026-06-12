import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../core/app_state.dart';

class JoinFamilyScreen extends StatefulWidget {
  const JoinFamilyScreen({super.key});

  @override
  State<JoinFamilyScreen> createState() => _JoinFamilyScreenState();
}

class _JoinFamilyScreenState extends State<JoinFamilyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  String _selectedRole = 'Member';
  final List<String> _roles = ['Father', 'Mother', 'Son', 'Daughter', 'Member'];

  @override
  void initState() {
    super.initState();
    // Pre-fill user name if logged in
    final user = Provider.of<AppState>(context, listen: false).currentUser;
    if (user != null) {
      _nameController.text = user.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleJoinFamily() async {
    if (_formKey.currentState!.validate()) {
      final appState = Provider.of<AppState>(context, listen: false);
      final success = await appState.joinFamily(
        _codeController.text.trim(),
        _nameController.text.trim(),
        _selectedRole,
      );

      if (success) {
        if (mounted) {
          // Success, this wrapper automatically redirects to NavigationContainer
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to join family. Verify the invite code.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: FamTheme.darkPurple),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Join Family with code',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: FamTheme.darkPurple,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Enter the invitation code shared by your family admin to join the family.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: FamTheme.darkPurple.withOpacity(0.6),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 35),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Name:',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: FamTheme.darkPurple.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'Enter your name',
                            prefixIcon: Icon(Icons.person_outline_rounded, color: FamTheme.primary.withOpacity(0.5)),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Family Code:',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: FamTheme.darkPurple.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _codeController,
                          textCapitalization: TextCapitalization.characters,
                          maxLength: 6,
                          decoration: InputDecoration(
                            hintText: 'Enter 6-digit code',
                            prefixIcon: Icon(Icons.vpn_key_outlined, color: FamTheme.primary.withOpacity(0.5)),
                            counterText: '',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter the invite code';
                            }
                            if (value.trim().length != 6) {
                              return 'Invite code must be exactly 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Your Role:',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: FamTheme.darkPurple.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedRole,
                          items: _roles.map((String role) {
                            return DropdownMenuItem<String>(
                              value: role,
                              child: Text(role),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedRole = val;
                              });
                            }
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.people_outline_rounded, color: FamTheme.primary.withOpacity(0.5)),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Consumer<AppState>(
                          builder: (context, state, child) {
                            return SizedBox(
                              width: double.infinity,
                              height: 58,
                              child: ElevatedButton(
                                onPressed: state.isLoading ? null : _handleJoinFamily,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: state.isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text('Join Family'),
                              ),
                            );
                          },
                        ),
                      ],
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
