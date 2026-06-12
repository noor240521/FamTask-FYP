import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../core/app_state.dart';
import 'task_detail_screen.dart';

class TasksTab extends StatefulWidget {
  const TasksTab({super.key});

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  String _activeFilter = 'pending'; // 'pending' or 'completed'

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final tasksList = state.tasks.where((t) => t.status == _activeFilter).toList();

    return Scaffold(
      backgroundColor: FamTheme.softBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Family Tasks',
          style: GoogleFonts.outfit(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: FamTheme.darkPurple,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Filter Selector Segment Buttons
            Row(
              children: [
                _buildFilterButton('Pending Tasks', 'pending'),
                const SizedBox(width: 12),
                _buildFilterButton('Completed', 'completed'),
              ],
            ),
            const SizedBox(height: 20),
            // Tasks List
            Expanded(
              child: tasksList.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      itemCount: tasksList.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final task = tasksList[index];
                        return _buildTaskCard(context, task, state);
                      },
                    ),
            ),
          ],
        ),
      ),
      // Floating Action Button to add task via bottom sheet
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskBottomSheet(context),
        backgroundColor: FamTheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildFilterButton(String label, String filter) {
    final isActive = _activeFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? FamTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: FamTheme.primary.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : FamTheme.darkPurple.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _activeFilter == 'pending' ? Icons.playlist_add_check_rounded : Icons.history_rounded,
            size: 65,
            color: FamTheme.darkPurple.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            _activeFilter == 'pending' ? 'All tasks completed!' : 'No completed tasks yet.',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: FamTheme.darkPurple.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, TaskItem task, AppState state) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaskDetailScreen(taskId: task.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: FamTheme.darkPurple.withOpacity(0.015),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checked state box
            GestureDetector(
              onTap: () => state.toggleTask(task.id),
              child: Container(
                margin: const EdgeInsets.only(top: 2),
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
            const SizedBox(width: 14),
            // Task Title / Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: FamTheme.darkPurple,
                      decoration: task.status == 'completed' ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task.description,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: FamTheme.darkPurple.withOpacity(0.65),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Location Badge
                      if (task.locationName.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1E6FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 12, color: FamTheme.primary),
                              const SizedBox(width: 4),
                              Text(
                                task.locationName,
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: FamTheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      // Chat Message Count Badge (GAP 7)
                      if (state.getMessageCount(task) > 0) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8EAF6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.chat_bubble_outline_rounded, size: 12, color: Colors.indigo),
                              const SizedBox(width: 4),
                              Text(
                                '${state.getMessageCount(task)}',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      // Assignee details
                      if (task.assigneeName != null) ...[
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: FamTheme.primary,
                          child: Text(
                            task.assigneeName!.substring(0, 1).toUpperCase(),
                            style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          task.assigneeName!,
                          style: GoogleFonts.inter(fontSize: 11, color: FamTheme.darkPurple.withOpacity(0.5)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Urgency / Due Date Badge & Lock Icon
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: task.isUrgent ? const Color(0xFFFFF0F5) : const Color(0xFFF0EFF5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    task.isUrgent ? 'Urgent' : task.dueDate,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: task.isUrgent ? Colors.pink : FamTheme.darkPurple.withOpacity(0.5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (task.lockedById != null) ...[
                      const Icon(
                        Icons.lock_rounded,
                        color: Colors.orange,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                    ],
                    // Delete Button
                    GestureDetector(
                      onTap: () {
                        state.deleteTask(task.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Task deleted!'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      },
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent.withOpacity(0.7),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // SLIDE-UP NEW TASK BOTTOM SHEET
  // ==========================================

  void _showAddTaskBottomSheet(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String dueDate = 'Today';
    String selectedLocation = 'Home';
    bool isUrgent = false;
    int geofenceRadius = 500;
    String? selectedAssignee;

    final appState = Provider.of<AppState>(context, listen: false);
    selectedAssignee = appState.currentUser?.id;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Create New Task',
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
                const SizedBox(height: 16),
                // Task Title
                Text(
                  'Task Title',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Grocery Shopping, Pay Electricity Bill',
                  ),
                ),
                const SizedBox(height: 16),
                // Task Description
                Text(
                  'Description',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Milk, eggs, and bread from store',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    // Location picker
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Task Location',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: selectedLocation,
                            items: appState.simLocations.map((loc) {
                              return DropdownMenuItem<String>(
                                value: loc.name,
                                child: Text(loc.name),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() {
                                  selectedLocation = val;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Due Date Picker Mock
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Due Date',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: dueDate,
                            items: const [
                              DropdownMenuItem(value: 'Today', child: Text('Today')),
                              DropdownMenuItem(value: 'Tomorrow', child: Text('Tomorrow')),
                              DropdownMenuItem(value: 'This Week', child: Text('This Week')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() {
                                  dueDate = val;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Assignee picker
                Text(
                  'Assignee',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedAssignee,
                  items: appState.familyMembers.map((member) {
                    return DropdownMenuItem<String>(
                      value: member.id,
                      child: Text('${member.name} (${member.role})'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setModalState(() {
                        selectedAssignee = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Urgent toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.pink, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Mark as Urgent',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ],
                    ),
                    Switch(
                      value: isUrgent,
                      activeColor: FamTheme.primary,
                      onChanged: (val) {
                        setModalState(() {
                          isUrgent = val;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Geofence Radius Slider (GAP 6)
                Text(
                  'Geofence Proximity Radius',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.radar_rounded, color: FamTheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Slider(
                        value: geofenceRadius.toDouble(),
                        min: 100.0,
                        max: 1000.0,
                        divisions: 9, // Allows 100m, 200m, ..., 1000m steps
                        activeColor: FamTheme.primary,
                        inactiveColor: FamTheme.primary.withOpacity(0.2),
                        label: '${geofenceRadius}m',
                        onChanged: (double val) {
                          setModalState(() {
                            geofenceRadius = val.round();
                          });
                        },
                      ),
                    ),
                    Text(
                      '${geofenceRadius}m',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: FamTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // Create Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (titleController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a task title.'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }

                      // Retrieve coordinates of selected simulated location
                      final locData = appState.simLocations.firstWhere(
                        (l) => l.name == selectedLocation,
                        orElse: () => appState.simLocations[0],
                      );

                      appState.addTask(
                        title: titleController.text.trim(),
                        description: descController.text.trim(),
                        dueDate: dueDate,
                        locationName: selectedLocation,
                        latitude: locData.latitude,
                        longitude: locData.longitude,
                        assigneeId: selectedAssignee,
                        isUrgent: isUrgent,
                        geofenceRadius: geofenceRadius,
                      );

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Task added successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Add Task'),
                  ),
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
