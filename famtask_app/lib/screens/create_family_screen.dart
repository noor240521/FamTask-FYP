import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../core/app_state.dart';
import 'family_created_screen.dart';

class CreateFamilyScreen extends StatefulWidget {
  const CreateFamilyScreen({super.key});

  @override
  State<CreateFamilyScreen> createState() => _CreateFamilyScreenState();
}

class _CreateFamilyScreenState extends State<CreateFamilyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _familyNameController = TextEditingController();
  final _adminNameController = TextEditingController();
  String _selectedRole = 'Admin';
  final List<String> _roles = ['Father', 'Mother', 'Son', 'Daughter', 'Admin', 'Member'];

  @override
  void initState() {
    super.initState();
    // Pre-fill user name if logged in
    final user = Provider.of<AppState>(context, listen: false).currentUser;
    if (user != null) {
      _adminNameController.text = user.name;
    }
  }

  @override
  void dispose() {
    _familyNameController.dispose();
    _adminNameController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateFamily() async {
    if (_formKey.currentState!.validate()) {
      final appState = Provider.of<AppState>(context, listen: false);
      final success = await appState.createFamily(
        _familyNameController.text.trim(),
        _adminNameController.text.trim(),
        _selectedRole,
      );

      if (success) {
        if (mounted) {
          // Navigate to "Family Group Created" screen and pass code
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => FamilyCreatedScreen(
                familyName: _familyNameController.text.trim(),
                inviteCode: appState.currentUser?.familyCode ?? 'FAM777',
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create family group. Try again.'),
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
                    'Create Family Group',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: FamTheme.darkPurple,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Start a shared space with your family to manage tasks together.',
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
                          'Family Name:',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: FamTheme.darkPurple.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _familyNameController,
                          decoration: InputDecoration(
                            hintText: 'e.g. ABC Family, Johnson Home',
                            prefixIcon: Icon(Icons.family_restroom_rounded, color: FamTheme.primary.withOpacity(0.5)),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a family name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
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
                          controller: _adminNameController,
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
                        const SizedBox(height: 24),
                        // Information Banner
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBE9F7),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: const Color(0xFFF6C8EE)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.stars_rounded, color: FamTheme.secondary, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "You'll become the family admin and receive an invitation code to share.",
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: FamTheme.darkPurple,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 35),
                        Consumer<AppState>(
                          builder: (context, state, child) {
                            return SizedBox(
                              width: double.infinity,
                              height: 58,
                              child: ElevatedButton(
                                onPressed: state.isLoading ? null : _handleCreateFamily,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: state.isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text('Create Family'),
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
