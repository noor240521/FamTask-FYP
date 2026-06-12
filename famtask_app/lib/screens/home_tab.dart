import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../core/app_state.dart';
import 'family_map_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final state = Provider.of<AppState>(context);
    final user = state.currentUser!;

    // Statistics calculated from state
    final totalTasks = state.tasks.length;
    final urgentTasks = state.tasks.where((t) => t.isUrgent && t.status == 'pending').length;
    final shoppingCount = state.shoppingList.where((item) => !item.isCompleted).length;
    final urgentShopping = state.shoppingList.where((item) => item.isUrgent && !item.isCompleted).length;

    // Filter today's pending tasks (or up to 3) for preview
    final previewTasks = state.tasks.where((t) => t.status == 'pending').take(3).toList();

    return Scaffold(
      backgroundColor: FamTheme.softBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOP BAR
              _buildTopBar(context, user, state),
              const SizedBox(height: 20),

              // 2. MEMBER COUNT & INVITE CARD
              _buildInviteCard(context, state),
              const SizedBox(height: 20),

              // 3. GREETING
              Text(
                'As-salamu alaykum, ${user.name}!',
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: FamTheme.darkPurple,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Here's a quick overview of your family activities.",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: FamTheme.darkPurple.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 20),

              // 4. STATS GRID
              _buildStatsGrid(totalTasks, urgentTasks, shoppingCount, urgentShopping),
              const SizedBox(height: 25),

              // 5. PROXIMITY SIMULATOR CONTROLLER (For FYP Presentation WOW Factor!)
              _buildProximitySimulator(context, state),
              const SizedBox(height: 25),

              // 6. TODAY'S TASKS PREVIEW
              _buildTodayTasksHeader(context, state),
              const SizedBox(height: 12),
              _buildTodayTasksList(context, previewTasks, state),
              const SizedBox(height: 25),

              // 7. FAMILY MEMBERS ROW
              _buildFamilyMembersRow(context, state),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // COMPONENT BUILDERS
  // ==========================================

  Widget _buildTopBar(BuildContext context, UserSession user, AppState state) {
    return Row(
      children: [
        // Profile Avatar (Tap to log out)
        GestureDetector(
          onTap: () => _showProfileDialog(context, state),
          child: Tooltip(
            message: 'Tap to Logout',
            child: CircleAvatar(
              radius: 24,
              backgroundColor: FamTheme.primary,
              child: Text(
                user.avatar,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Family Name Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    user.familyName ?? 'No Family Group',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: FamTheme.darkPurple,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: FamTheme.darkPurple.withOpacity(0.4),
                  ),
                ],
              ),
              // API Mode Indicator
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: state.isApiMode ? const Color(0xFFE8F5E9) : const Color(0xFFECEFF1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  state.isApiMode ? 'API Server Connected' : 'Offline Demo Mode',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: state.isApiMode ? Colors.green[700] : Colors.blueGrey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Interactive Map Button
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FamilyMapScreen()),
            );
          },
          icon: const Icon(
            Icons.map_rounded,
            size: 28,
            color: FamTheme.primary,
          ),
          tooltip: 'Family Location Map',
        ),
        // Notifications and Mode Toggle
        IconButton(
          onPressed: () {
            // Quick toggle between API / MOCK mode
            state.toggleMode(!state.isApiMode);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.isApiMode 
                      ? 'Switched to SQLite API Mode!' 
                      : 'Switched to standalone offline Demo Mode!',
                ),
                backgroundColor: FamTheme.primary,
              ),
            );
          },
          icon: Icon(
            state.isApiMode ? Icons.dns_rounded : Icons.offline_bolt_rounded,
            color: state.isApiMode ? Colors.green : Colors.grey,
          ),
          tooltip: 'Toggle Mock/API server connection',
        ),
        // Notifications icon matching mockup
        Stack(
          children: [
            IconButton(
              onPressed: () {
                _showNotificationsDialog(context, state);
              },
              icon: const Icon(
                Icons.notifications_none_rounded,
                size: 28,
                color: FamTheme.darkPurple,
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '2',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out from FAMTASK?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              state.logout();
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showProfileDialog(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final currentUser = state.currentUser!;
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: Colors.white,
            titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Profile',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: FamTheme.darkPurple,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: FamTheme.darkPurple),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: FamTheme.primary,
                  child: Text(
                    currentUser.avatar,
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  currentUser.name,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: FamTheme.darkPurple,
                  ),
                ),
                Text(
                  currentUser.email,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: FamTheme.darkPurple.withOpacity(0.55),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBE9F7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    currentUser.role,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: FamTheme.secondary,
                    ),
                  ),
                ),
                const Divider(),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Availability Status',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: FamTheme.darkPurple,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildStatusChip(context, state, 'free', '🟢 Free', setState),
                    _buildStatusChip(context, state, 'busy', '🔴 Busy', setState),
                    _buildStatusChip(context, state, 'driving', '🚗 Driving', setState),
                    _buildStatusChip(context, state, 'dnd', '🔕 DND', setState),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showLogoutDialog(context, state);
                    },
                    icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
                    label: Text(
                      'Log Out',
                      style: GoogleFonts.inter(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(
    BuildContext context,
    AppState state,
    String statusValue,
    String label,
    void Function(void Function()) setState,
  ) {
    final isSelected = state.currentUser!.availability == statusValue;
    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.white : FamTheme.darkPurple,
        ),
      ),
      selected: isSelected,
      selectedColor: FamTheme.primary,
      backgroundColor: FamTheme.softBackground,
      checkmarkColor: Colors.white,
      onSelected: (selected) async {
        if (selected) {
          setState(() {
            // instant visual trigger
          });
          await state.updateAvailability(statusValue);
        }
      },
    );
  }

  void _showNotificationsDialog(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Notifications',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: FamTheme.darkPurple,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),
            if (state.activities.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Center(
                  child: Text('No new notifications.'),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: state.activities.take(10).length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final activity = state.activities[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: FamTheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications_active_rounded, color: FamTheme.primary, size: 20),
                      ),
                      title: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${activity.userName} ',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: FamTheme.darkPurple,
                              ),
                            ),
                            TextSpan(
                              text: activity.description,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: FamTheme.darkPurple.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: Text(
                        'Just now',
                        style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteCard(BuildContext context, AppState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE3D3FF), Color(0xFFF1E6FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.35),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.people_outline_rounded, color: FamTheme.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${state.familyMembers.length} Members',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: FamTheme.darkPurple,
                    ),
                  ),
                  Text(
                    'Invite Code: ${state.currentUser?.familyCode ?? "FAM000"}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: FamTheme.darkPurple.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Invite button matching mockup
          ElevatedButton(
            onPressed: () {
              _showInviteCodeDialog(context, state);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: FamTheme.primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text('+ Invite'),
          ),
        ],
      ),
    );
  }

  void _showInviteCodeDialog(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Family Invite Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Share this code with your family members so they can join your family space:'),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: FamTheme.softBackground,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: FamTheme.primary.withOpacity(0.2)),
              ),
              child: Text(
                state.currentUser?.familyCode ?? 'FAM777',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: FamTheme.primary,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(int totalTasks, int urgentTasks, int totalShop, int urgentShop) {
    return Row(
      children: [
        // Pink card - Family Tasks
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF0F5), Color(0xFFFFE3EE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_box_rounded, color: Colors.pink, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'Family Tasks',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C1F41),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '$totalTasks Total',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6C1F41).withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$urgentTasks Urgent',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Blue card - Shopping List
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEBF5FF), Color(0xFFD4ECFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shopping_cart_rounded, color: Colors.blue, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'Shopping List',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F4A6C),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '$totalShop Items',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F4A6C).withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$urgentShop Urgent',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // PROXIMITY CONTROLLER & NEARBY LOCATION REMINDER
  // ==========================================

  Widget _buildProximitySimulator(BuildContext context, AppState state) {
    final proximityTask = state.activeProximityTask;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Simulated Location Controller Row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: FamTheme.darkPurple.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.gps_fixed_rounded, color: FamTheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Simulated GPS location:',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: FamTheme.darkPurple.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              DropdownButton<SimLocation>(
                value: state.simLocations.firstWhere(
                  (loc) => loc.name == state.currentSimLocation.name,
                  orElse: () => state.simLocations[0],
                ),
                underline: const SizedBox(),
                icon: const Icon(Icons.arrow_drop_down, color: FamTheme.primary),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: FamTheme.primary,
                ),
                onChanged: (SimLocation? newVal) {
                  if (newVal != null) {
                    state.updateSimLocation(newVal);
                  }
                },
                items: state.simLocations.map((SimLocation loc) {
                  return DropdownMenuItem<SimLocation>(
                    value: loc,
                    child: Text(loc.name),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        // 2. NEARBY LOCATION REMINDER CARD (Only shows if user is near a task location!)
        if (proximityTask != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF9F7FF), Color(0xFFEDE8FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: FamTheme.primary.withOpacity(0.2), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: FamTheme.primary.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.location_on_rounded, color: Colors.green, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nearby Location Reminder',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: FamTheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'You are near ${proximityTask.locationName}.',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: FamTheme.darkPurple,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '"${proximityTask.title}" can be done now!',
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
                const SizedBox(height: 20),
                // "Start Shopping" / "Complete Task" button matching mockup
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      state.toggleTask(proximityTask.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Completed task "${proximityTask.title}" nearby at ${proximityTask.locationName}!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FamTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text('Start Shopping / Complete Task'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTodayTasksHeader(BuildContext context, AppState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Today's Tasks",
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: FamTheme.darkPurple,
          ),
        ),
        GestureDetector(
          onTap: () {
            // Trigger a quick add task bottom sheet
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Click on the "Tasks" tab at the bottom to add or manage your full task list!'),
                backgroundColor: FamTheme.primary,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: FamTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+ Add Task',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: FamTheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTodayTasksList(BuildContext context, List<TaskItem> tasksList, AppState state) {
    if (tasksList.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.done_all_rounded, color: Colors.green[300], size: 40),
              const SizedBox(height: 10),
              Text(
                'No pending tasks!',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: FamTheme.darkPurple.withOpacity(0.015),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tasksList.length,
            separatorBuilder: (context, index) => Divider(
              color: FamTheme.lightGray,
              height: 1,
              indent: 20,
              endIndent: 20,
            ),
            itemBuilder: (context, index) {
              final task = tasksList[index];

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: GestureDetector(
                  onTap: () => state.toggleTask(task.id),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: task.status == 'completed' ? Colors.green : FamTheme.primary.withOpacity(0.5),
                        width: 2.0,
                      ),
                      color: task.status == 'completed' ? Colors.green : Colors.transparent,
                    ),
                    child: task.status == 'completed'
                        ? const Icon(Icons.done, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
                title: Text(
                  task.title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: FamTheme.darkPurple,
                    decoration: task.status == 'completed' ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: FamTheme.darkPurple.withOpacity(0.6),
                      ),
                    ),
                    if (task.locationName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded, size: 12, color: FamTheme.primary.withOpacity(0.5)),
                          const SizedBox(width: 4),
                          Text(
                            task.locationName,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: FamTheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: task.isUrgent ? const Color(0xFFFFF0F5) : const Color(0xFFF1E6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    task.isUrgent ? 'Urgent' : task.dueDate,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: task.isUrgent ? Colors.pink : FamTheme.primary,
                    ),
                  ),
                ),
              );
            },
          ),
          // View All text matching mockup
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Swipe to/Click "Tasks" tab below to view all!'),
                  backgroundColor: FamTheme.primary,
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View All',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: FamTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded, size: 16, color: FamTheme.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyMembersRow(BuildContext context, AppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Family Members",
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: FamTheme.darkPurple,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: FamTheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '7 Pending Invites',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: FamTheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Horizontal list of avatars matching mockup
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: state.familyMembers.length + 1,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              if (index == state.familyMembers.length) {
                // The '+' Add Member Button at the end matching mockup
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () => _showInviteCodeDialog(context, state),
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: FamTheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, color: FamTheme.primary, size: 28),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Invite',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: FamTheme.darkPurple.withOpacity(0.7),
                      ),
                    ),
                  ],
                );
              }

              final member = state.familyMembers[index];

              return Column(
                children: [
                  CircleAvatar(
                    radius: 27,
                    backgroundColor: FamTheme.primary.withOpacity(0.15),
                    child: Text(
                      member.avatar,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: FamTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    member.name,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: FamTheme.darkPurple,
                    ),
                  ),
                  Text(
                    member.role,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: FamTheme.darkPurple.withOpacity(0.5),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
