import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../core/app_state.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    final state = Provider.of<AppState>(context, listen: false);
    state.fetchMessages(widget.taskId);
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (state.isApiMode) {
        state.fetchMessages(widget.taskId);
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    // Find task in state
    final taskIndex = state.tasks.indexWhere((t) => t.id == widget.taskId);
    if (taskIndex == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Task Not Found')),
        body: const Center(child: Text('This task has been deleted or does not exist.')),
      );
    }
    final task = state.tasks[taskIndex];
    final currentUser = state.currentUser!;

    final bool isLockedByMe = task.lockedById == currentUser.id;
    final bool isLockedByOthers = task.lockedById != null && !isLockedByMe;

    return Scaffold(
      backgroundColor: FamTheme.softBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: FamTheme.darkPurple),
        ),
        title: Text(
          'Task Details',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: FamTheme.darkPurple,
          ),
        ),
        actions: [
          // Delete button (visible to assignee or creator or admin)
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Task'),
                  content: const Text('Are you sure you want to delete this task?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        state.deleteTask(task.id);
                        Navigator.pop(context); // close dialog
                        Navigator.pop(context); // pop detail screen
                      },
                      child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. LOCK STATUS WARNING BANNER (GAP 2)
            if (isLockedByOthers)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                color: Colors.amber[100],
                child: Row(
                  children: [
                    Icon(Icons.lock_rounded, color: Colors.amber[900], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This task is already accepted by ${task.lockedByName}.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber[900],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (isLockedByMe)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                color: Colors.green[100],
                child: Row(
                  children: [
                    Icon(Icons.lock_open_rounded, color: Colors.green[800], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You have accepted and locked this task. Others cannot modify it.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. MAIN TASK CARD INFO
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: task.isUrgent ? const Color(0xFFFFF0F5) : const Color(0xFFF1E6FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                task.isUrgent ? 'Urgent' : 'Normal',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: task.isUrgent ? Colors.pink : FamTheme.primary,
                                ),
                              ),
                            ),
                            Text(
                              task.dueDate,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: FamTheme.darkPurple.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          task.title,
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: FamTheme.darkPurple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          task.description.isEmpty ? 'No description provided.' : task.description,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: FamTheme.darkPurple.withOpacity(0.7),
                            height: 1.6,
                          ),
                        ),
                        const Divider(height: 35),
                        // Proximity Geofence Radius display (pre-setup for GAP 6)
                        Row(
                          children: [
                            const Icon(Icons.radar_rounded, size: 20, color: FamTheme.primary),
                            const SizedBox(width: 10),
                            Text(
                              'Geofence Radius: ${task.geofenceRadius} meters',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: FamTheme.darkPurple,
                              ),
                            ),
                          ],
                        ),
                        if (task.locationName.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 20, color: FamTheme.primary),
                              const SizedBox(width: 10),
                              Text(
                                task.locationName,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: FamTheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.person_pin_rounded, size: 20, color: FamTheme.primary),
                            const SizedBox(width: 10),
                            Text(
                              task.assigneeName != null
                                  ? 'Assigned to: ${task.assigneeName}'
                                  : 'Assigned to: Unassigned',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: FamTheme.darkPurple,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // 3. ACTION CONTROLS
                  if (task.status == 'completed') ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
                          const SizedBox(width: 12),
                          Text(
                            'Task completed!',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[900],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Taps "Accept" button -> Locks/unlocks
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 58,
                            child: ElevatedButton(
                              onPressed: isLockedByOthers
                                  ? null
                                  : () async {
                                      if (isLockedByMe) {
                                        await state.unlockTask(task.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Task unlocked successfully!'),
                                            backgroundColor: FamTheme.primary,
                                          ),
                                        );
                                      } else {
                                        final success = await state.lockTask(task.id);
                                        if (success) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Task accepted and locked!'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Could not accept task. Already locked by someone else.'),
                                              backgroundColor: Colors.redAccent,
                                            ),
                                          );
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isLockedByMe ? Colors.orange[400] : FamTheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                isLockedByMe ? 'Release Task Lock' : 'Accept & Lock Task',
                                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                          ),
                        ),
                        if (isLockedByMe) ...[
                          const SizedBox(width: 12),
                          // Complete Button when you hold the lock
                          SizedBox(
                            width: 58,
                            height: 58,
                            child: ElevatedButton(
                              onPressed: () {
                                state.toggleTask(task.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Task marked as completed!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Icon(Icons.done_all_rounded, color: Colors.white),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const Divider(height: 40),
                    _buildChatSection(context, state, task),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatSection(BuildContext context, AppState state, TaskItem task) {
    final messages = state.getMessagesForTask(task.id);
    final currentUser = state.currentUser!;

    // Auto-scroll to bottom after build
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.chat_bubble_outline_rounded, color: FamTheme.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              'Task Comments & Updates (${messages.length})',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: FamTheme.darkPurple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 250,
          decoration: BoxDecoration(
            color: FamTheme.softBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: FamTheme.primary.withOpacity(0.08)),
          ),
          child: messages.isEmpty
              ? Center(
                  child: Text(
                    'No messages yet. Start the conversation!',
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == currentUser.id;

                    String timeStr = '';
                    try {
                      final dt = DateTime.parse(msg.timestamp);
                      timeStr = DateFormat('h:mm a').format(dt);
                    } catch (_) {}

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe ? const Color(0xFFE9E5FF) : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isMe)
                              Text(
                                msg.senderName,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: FamTheme.primary,
                                ),
                              ),
                            if (!isMe) const SizedBox(height: 2),
                            Text(
                              msg.text,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: FamTheme.darkPurple,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                timeStr,
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  color: FamTheme.darkPurple.withOpacity(0.4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 12),
        // Text Input Row
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                style: GoogleFonts.inter(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: FamTheme.primary.withOpacity(0.1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: FamTheme.primary.withOpacity(0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: FamTheme.primary),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: FamTheme.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () async {
                  if (_messageController.text.trim().isNotEmpty) {
                    await state.sendMessage(task.id, _messageController.text.trim());
                    _messageController.clear();
                    _scrollToBottom();
                  }
                },
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
