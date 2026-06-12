import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/app_state.dart';
import 'home_tab.dart';
import 'tasks_tab.dart';
import 'shopping_tab.dart';
import 'members_tab.dart';

class NavigationContainer extends StatefulWidget {
  const NavigationContainer({super.key});

  @override
  State<NavigationContainer> createState() => _NavigationContainerState();
}

class _NavigationContainerState extends State<NavigationContainer> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const HomeTab(),
    const TasksTab(),
    const ShoppingTab(),
    const MembersTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final user = state.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: FamTheme.darkPurple.withOpacity(0.08),
              blurRadius: 25,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: FamTheme.primary,
            unselectedItemColor: FamTheme.darkPurple.withOpacity(0.4),
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.home_rounded),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.home_rounded),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.task_outlined),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.task_rounded),
                ),
                label: 'Tasks',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.shopping_bag_outlined),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.shopping_bag_rounded),
                ),
                label: 'Shopping',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.people_alt_outlined),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.people_alt_rounded),
                ),
                label: 'Members',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
