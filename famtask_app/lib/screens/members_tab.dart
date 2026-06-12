import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../core/app_state.dart';

class MembersTab extends StatelessWidget {
  const MembersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final user = state.currentUser!;
    final codeCharacters = (user.familyCode ?? 'FAM777').toUpperCase().split('');

    return Scaffold(
      backgroundColor: FamTheme.softBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Family & Activity',
          style: GoogleFonts.outfit(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: FamTheme.darkPurple,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => state.refreshAllData(),
        color: FamTheme.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // 1. SHARE CODE CONTAINER
              _buildShareCodeCard(context, user.familyName ?? 'Your Family', codeCharacters, state),
              const SizedBox(height: 24),
              // 2. ACTIVE MEMBERS LIST
              _buildMembersList(context, state),
              const SizedBox(height: 24),
              // 3. RECENT ACTIVITY LOGS
              _buildActivityLogs(context, state),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareCodeCard(BuildContext context, String familyName, List<String> characters, AppState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: FamTheme.darkPurple.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            familyName,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: FamTheme.darkPurple,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Invite family members using the code below',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: FamTheme.darkPurple.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: characters.map((char) {
              return Container(
                width: 38,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: FamTheme.softBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: FamTheme.primary.withOpacity(0.1)),
                ),
                child: Text(
                  char,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: FamTheme.primary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersList(BuildContext context, AppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Members',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: FamTheme.darkPurple,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: FamTheme.darkPurple.withOpacity(0.01),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.familyMembers.length,
            separatorBuilder: (context, index) => Divider(
              color: FamTheme.lightGray,
              height: 1,
              indent: 20,
              endIndent: 20,
            ),
            itemBuilder: (context, index) {
              final member = state.familyMembers[index];
              final isAdmin = member.role.toLowerCase() == 'admin' || member.role.toLowerCase() == 'father';

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: FamTheme.primary.withOpacity(0.12),
                  child: Text(
                    member.avatar,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: FamTheme.primary,
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Text(
                      member.name,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: FamTheme.darkPurple,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildAvailabilityBadge(member.availability),
                  ],
                ),
                subtitle: Text(
                  member.email,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: FamTheme.darkPurple.withOpacity(0.5),
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAdmin ? const Color(0xFFFBE9F7) : const Color(0xFFECEFF1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    member.role,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isAdmin ? FamTheme.secondary : Colors.blueGrey,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActivityLogs(BuildContext context, AppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activities',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: FamTheme.darkPurple,
          ),
        ),
        const SizedBox(height: 12),
        if (state.activities.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                'No activity logs recorded yet.',
                style: GoogleFonts.inter(color: Colors.grey),
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: FamTheme.darkPurple.withOpacity(0.01),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.activities.length,
              separatorBuilder: (context, index) => Divider(
                color: FamTheme.lightGray,
                height: 1,
                indent: 20,
                endIndent: 20,
              ),
              itemBuilder: (context, index) {
                final activity = state.activities[index];
                
                // Format relative time or simple timestamp
                String timeStr = 'Recently';
                try {
                  final dt = DateTime.parse(activity.createdAt);
                  timeStr = DateFormat('h:mm a').format(dt);
                } catch (_) {}

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Activity timeline point dot
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: FamTheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${activity.userName} ',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: FamTheme.darkPurple,
                                    ),
                                  ),
                                  TextSpan(
                                    text: activity.description,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: FamTheme.darkPurple.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        timeStr,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: FamTheme.darkPurple.withOpacity(0.35),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildAvailabilityBadge(String availability) {
    String label = 'Free';
    Color color = Colors.green;
    Color bg = const Color(0xFFE8F5E9);

    switch (availability) {
      case 'busy':
        label = 'Busy';
        color = Colors.red;
        bg = const Color(0xFFFFEBEE);
        break;
      case 'driving':
        label = 'Driving';
        color = Colors.orange;
        bg = const Color(0xFFFFF3E0);
        break;
      case 'dnd':
        label = 'DND';
        color = Colors.purple;
        bg = const Color(0xFFF3E5F5);
        break;
      case 'free':
      default:
        label = 'Free';
        color = Colors.green;
        bg = const Color(0xFFE8F5E9);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
