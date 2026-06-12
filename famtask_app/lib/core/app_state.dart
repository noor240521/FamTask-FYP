import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

// Simulated location data structure
class SimLocation {
  final String name;
  final double latitude;
  final double longitude;

  SimLocation({required this.name, required this.latitude, required this.longitude});
}

class UserSession {
  final String id;
  final String name;
  final String email;
  final String? familyId;
  final String? familyName;
  final String? familyCode;
  final String role;
  final String avatar;
  final String availability;

  UserSession({
    required this.id,
    required this.name,
    required this.email,
    this.familyId,
    this.familyName,
    this.familyCode,
    required this.role,
    required this.avatar,
    this.availability = 'free',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'familyId': familyId,
    'familyName': familyName,
    'familyCode': familyCode,
    'role': role,
    'avatar': avatar,
    'availability': availability,
  };

  factory UserSession.fromJson(Map<String, dynamic> json) => UserSession(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    familyId: json['familyId'],
    familyName: json['familyName'],
    familyCode: json['familyCode'],
    role: json['role'] ?? 'Member',
    avatar: json['avatar'] ?? 'A',
    availability: json['availability'] ?? 'free',
  );

  UserSession copyWith({
    String? familyId,
    String? familyName,
    String? familyCode,
    String? role,
    String? availability,
  }) => UserSession(
    id: id,
    name: name,
    email: email,
    familyId: familyId ?? this.familyId,
    familyName: familyName ?? this.familyName,
    familyCode: familyCode ?? this.familyCode,
    role: role ?? this.role,
    avatar: avatar,
    availability: availability ?? this.availability,
  );
}

class TaskItem {
  final String id;
  final String title;
  final String description;
  final String dueDate;
  final String locationName;
  final double latitude;
  final double longitude;
  final String? assigneeId;
  final String? assigneeName;
  final String familyId;
  final String status; // 'pending' or 'completed'
  final bool isUrgent;
  final String createdAt;
  final String? lockedById;
  final String? lockedByName;
  final String? lockedAt;
  final int geofenceRadius;
  final int messageCount;

  TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    this.assigneeId,
    this.assigneeName,
    required this.familyId,
    required this.status,
    required this.isUrgent,
    required this.createdAt,
    this.lockedById,
    this.lockedByName,
    this.lockedAt,
    this.geofenceRadius = 500,
    this.messageCount = 0,
  });

  TaskItem copyWith({
    String? status,
    String? lockedById,
    String? lockedByName,
    String? lockedAt,
    String? assigneeId,
    String? assigneeName,
    int? messageCount,
  }) => TaskItem(
    id: id,
    title: title,
    description: description,
    dueDate: dueDate,
    locationName: locationName,
    latitude: latitude,
    longitude: longitude,
    assigneeId: assigneeId ?? this.assigneeId,
    assigneeName: assigneeName ?? this.assigneeName,
    familyId: familyId,
    status: status ?? this.status,
    isUrgent: isUrgent,
    createdAt: createdAt,
    lockedById: lockedById ?? this.lockedById,
    lockedByName: lockedByName ?? this.lockedByName,
    lockedAt: lockedAt ?? this.lockedAt,
    geofenceRadius: geofenceRadius,
    messageCount: messageCount ?? this.messageCount,
  );

  factory TaskItem.fromJson(Map<String, dynamic> json) => TaskItem(
    id: json['id'],
    title: json['title'],
    description: json['description'] ?? '',
    dueDate: json['due_date'] ?? '',
    locationName: json['location_name'] ?? '',
    latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
    longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    assigneeId: json['assignee_id'],
    assigneeName: json['assignee_name'],
    familyId: json['family_id'],
    status: json['status'] ?? 'pending',
    isUrgent: json['is_urgent'] == true || json['is_urgent'] == 1,
    createdAt: json['created_at'] ?? '',
    lockedById: json['locked_by_id'],
    lockedByName: json['locked_by_name'],
    lockedAt: json['locked_at'],
    geofenceRadius: json['geofence_radius'] ?? 500,
    messageCount: json['message_count'] ?? 0,
  );
}

class ShoppingItem {
  final String id;
  final String name;
  final String quantity;
  final bool isUrgent;
  final bool isCompleted;
  final String familyId;
  final String createdAt;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.isUrgent,
    required this.isCompleted,
    required this.familyId,
    required this.createdAt,
  });

  ShoppingItem copyWith({bool? isCompleted}) => ShoppingItem(
    id: id,
    name: name,
    quantity: quantity,
    isUrgent: isUrgent,
    isCompleted: isCompleted ?? this.isCompleted,
    familyId: familyId,
    createdAt: createdAt,
  );

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
    id: json['id'],
    name: json['name'],
    quantity: json['quantity'] ?? '1',
    isUrgent: json['is_urgent'] == true || json['is_urgent'] == 1,
    isCompleted: json['is_completed'] == true || json['is_completed'] == 1,
    familyId: json['family_id'],
    createdAt: json['created_at'] ?? '',
  );
}

class ActivityLog {
  final String id;
  final String userName;
  final String description;
  final String createdAt;

  ActivityLog({
    required this.id,
    required this.userName,
    required this.description,
    required this.createdAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) => ActivityLog(
    id: json['id'],
    userName: json['user_name'] ?? 'Someone',
    description: json['description'] ?? '',
    createdAt: json['created_at'] ?? '',
  );
}

class TaskMessage {
  final String id;
  final String taskId;
  final String senderId;
  final String senderName;
  final String text;
  final String timestamp;

  TaskMessage({
    required this.id,
    required this.taskId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
  });

  factory TaskMessage.fromJson(Map<String, dynamic> json) => TaskMessage(
    id: json['id'],
    taskId: json['task_id'],
    senderId: json['sender_id'],
    senderName: json['sender_name'],
    text: json['text'],
    timestamp: json['timestamp'],
  );
}

class AppState extends ChangeNotifier {
  // Backend URL (runs on localhost:3000)
  static const String _apiBaseUrl = 'http://localhost:3000/api';

  UserSession? _currentUser;
  bool _isApiMode = false;
  bool _isLoading = false;

  List<TaskItem> _tasks = [];
  List<ShoppingItem> _shoppingList = [];
  List<ActivityLog> _activities = [];
  List<UserSession> _familyMembers = [];

  // Simulated Locations (from proposal and mockups)
  final List<SimLocation> simLocations = [
    SimLocation(name: 'Home', latitude: 33.7294, longitude: 73.0931),
    SimLocation(name: 'Utility Store', latitude: 33.7299, longitude: 73.0940), // Close to home!
    SimLocation(name: 'School', latitude: 33.6844, longitude: 73.0479),
    SimLocation(name: 'Main Bank', latitude: 33.7081, longitude: 73.0498),
  ];

  late SimLocation _currentSimLocation;
  TaskItem? _activeProximityTask;

  // Getters
  UserSession? get currentUser => _currentUser;
  bool get isApiMode => _isApiMode;
  bool get isLoading => _isLoading;
  List<TaskItem> get tasks => _tasks;
  List<ShoppingItem> get shoppingList => _shoppingList;
  List<ActivityLog> get activities => _activities;
  List<UserSession> get familyMembers => _familyMembers;
  SimLocation get currentSimLocation => _currentSimLocation;
  TaskItem? get activeProximityTask => _activeProximityTask;

  AppState() {
    _currentSimLocation = simLocations[0]; // Start at Home
    _loadSessionAndDetectBackend();
  }

  // Initial Load and Auto-detect Server
  Future<void> _loadSessionAndDetectBackend() async {
    _isLoading = true;
    notifyListeners();

    // 1. Detect if Local API is active
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/')).timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        _isApiMode = true;
        print('Backend detected! Running in API Mode.');
      } else {
        _isApiMode = false;
        print('Backend not reachable (status code ${response.statusCode}). Running in Mock Mode.');
      }
    } catch (_) {
      _isApiMode = false;
      print('Backend not reachable (exception). Running in Mock Mode.');
    }

    // 2. Load cached user session
    final prefs = await SharedPreferences.getInstance();
    final cachedSession = prefs.getString('user_session');
    if (cachedSession != null) {
      try {
        _currentUser = UserSession.fromJson(jsonDecode(cachedSession));
        await refreshAllData();
      } catch (e) {
        print('Error parsing cached session: $e');
      }
    } else {
      // Load mock family members if starting without an active user
      _loadMockInitialData();
    }

    _isLoading = false;
    notifyListeners();
  }

  void toggleMode(bool val) {
    _isApiMode = val;
    refreshAllData();
  }

  // Refresh data based on the mode
  Future<void> refreshAllData() async {
    if (_currentUser == null) return;
    if (_currentUser!.familyId == null) return;

    if (_isApiMode) {
      await _fetchDataFromApi();
    } else {
      _checkMockProximity();
    }
    notifyListeners();
  }

  // Load initial mock datasets for instant demoing
  void _loadMockInitialData() {
    // Generate static mock members
    _familyMembers = [
      UserSession(id: 'ali', name: 'Ali', email: 'ali@fam.com', role: 'Father', avatar: 'A', familyId: 'fam123', availability: 'free'),
      UserSession(id: 'mother', name: 'Mother', email: 'mother@fam.com', role: 'Mother', avatar: 'M', familyId: 'fam123', availability: 'busy'),
      UserSession(id: 'son', name: 'Son', email: 'son@fam.com', role: 'Son', avatar: 'S', familyId: 'fam123', availability: 'driving'),
      UserSession(id: 'daughter', name: 'Daughter', email: 'daughter@fam.com', role: 'Daughter', avatar: 'D', familyId: 'fam123', availability: 'dnd'),
    ];

    // Seed mock tasks
    _tasks = [
      TaskItem(
        id: 'task-1',
        title: 'Pick up groceries',
        description: 'Pick up milk, eggs, and bread',
        dueDate: 'Due Today',
        locationName: 'Utility Store',
        latitude: 33.7299,
        longitude: 73.0940,
        assigneeId: 'ali',
        assigneeName: 'Ali',
        familyId: 'fam123',
        status: 'pending',
        isUrgent: true,
        createdAt: DateTime.now().toIso8601String(),
      ),
      TaskItem(
        id: 'task-2',
        title: "Help with Irfan's homework",
        description: 'Help Irfan with his math homework',
        dueDate: 'Tomorrow',
        locationName: 'Home',
        latitude: 33.7294,
        longitude: 73.0931,
        assigneeId: 'mother',
        assigneeName: 'Mother',
        familyId: 'fam123',
        status: 'pending',
        isUrgent: false,
        createdAt: DateTime.now().toIso8601String(),
      ),
      TaskItem(
        id: 'task-3',
        title: 'Take Zainab to the dentist',
        description: '3:00 PM - 4:00 PM',
        dueDate: '3:00 - 4:00 PM',
        locationName: 'Main Bank',
        latitude: 33.7081,
        longitude: 73.0498,
        assigneeId: 'ali',
        assigneeName: 'Ali',
        familyId: 'fam123',
        status: 'pending',
        isUrgent: true,
        createdAt: DateTime.now().toIso8601String(),
      ),
    ];

    // Seed shopping list
    _shoppingList = [
      ShoppingItem(id: 'shop-1', name: 'Milk Carton', quantity: '2 liters', isUrgent: true, isCompleted: false, familyId: 'fam123', createdAt: DateTime.now().toIso8601String()),
      ShoppingItem(id: 'shop-2', name: 'Brown Eggs', quantity: '12 pack', isUrgent: false, isCompleted: false, familyId: 'fam123', createdAt: DateTime.now().toIso8601String()),
      ShoppingItem(id: 'shop-3', name: 'Whole Wheat Bread', quantity: '1 loaf', isUrgent: false, isCompleted: true, familyId: 'fam123', createdAt: DateTime.now().toIso8601String()),
    ];

    // Seed mock activities log
    _activities = [
      ActivityLog(id: 'act-1', userName: 'Ali', description: 'completed task: "Wash the family car"', createdAt: DateTime.now().toIso8601String()),
      ActivityLog(id: 'act-2', userName: 'Mother', description: 'added "Brown Eggs" to shopping list', createdAt: DateTime.now().toIso8601String()),
      ActivityLog(id: 'act-3', userName: 'Ali', description: 'joined the family group', createdAt: DateTime.now().toIso8601String()),
    ];

    // Seed mock messages
    _mockMessages = [
      TaskMessage(
        id: 'msg-1',
        taskId: 'task-1',
        senderId: 'ali',
        senderName: 'Ali',
        text: 'Where should I get the bread from?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)).toIso8601String(),
      ),
      TaskMessage(
        id: 'msg-2',
        taskId: 'task-1',
        senderId: 'mother',
        senderName: 'Mother',
        text: 'From the Utility Store next to the bank.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 8)).toIso8601String(),
      ),
    ];

    _checkMockProximity();
  }

  // ==========================================
  // LOCATION SIMULATION & PROXIMITY DETECTION
  // ==========================================

  void updateSimLocation(SimLocation newLoc) {
    _currentSimLocation = newLoc;
    print('Simulated Location changed to: ${newLoc.name}');
    
    // Check if close to any pending task location
    _checkMockProximity();
    notifyListeners();
  }

  double _calculateDistanceInMeters(double lat1, double lon1, double lat2, double lon2) {
    const double r = 6371000; // Earth radius in meters
    final double dLat = (lat2 - lat1) * math.pi / 180;
    final double dLon = (lon2 - lon1) * math.pi / 180;
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) * math.cos(lat2 * math.pi / 180) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  void _checkMockProximity() {
    _activeProximityTask = null;
    if (_currentUser == null) return;

    // Suppress proximity notifications if availability is NOT 'free' (e.g. busy, driving, dnd)
    if (_currentUser!.availability != 'free') {
      return;
    }

    for (var task in _tasks) {
      if (task.status == 'pending' && task.locationName.isNotEmpty && task.locationName != 'Home') {
        // Calculate distance in meters using haversine formula
        final double distance = _calculateDistanceInMeters(
          _currentSimLocation.latitude,
          _currentSimLocation.longitude,
          task.latitude,
          task.longitude,
        );
        
        // Trigger alert only if user is within the task's configurable geofence radius
        if (distance <= task.geofenceRadius) {
          _activeProximityTask = task;
          break;
        }
      }
    }
  }

  // ==========================================
  // API INTEGRATION HELPERS
  // ==========================================

  Future<void> _fetchDataFromApi() async {
    if (_currentUser == null || _currentUser!.familyId == null) return;
    final fId = _currentUser!.familyId;

    try {
      // 1. Fetch Members
      final membersRes = await http.get(Uri.parse('$_apiBaseUrl/family/members/$fId'));
      if (membersRes.statusCode == 200) {
        final List data = jsonDecode(membersRes.body);
        _familyMembers = data.map((json) => UserSession(
          id: json['id'],
          name: json['name'],
          email: json['email'],
          role: json['role'] ?? 'Member',
          avatar: json['avatar'] ?? 'U',
          familyId: fId,
          availability: json['availability'] ?? 'free',
        )).toList();
      }

      // 2. Fetch Tasks
      final tasksRes = await http.get(Uri.parse('$_apiBaseUrl/tasks/$fId'));
      if (tasksRes.statusCode == 200) {
        final List data = jsonDecode(tasksRes.body);
        _tasks = data.map((json) => TaskItem.fromJson(json)).toList();
      }

      // 3. Fetch Shopping List
      final shoppingRes = await http.get(Uri.parse('$_apiBaseUrl/shopping/$fId'));
      if (shoppingRes.statusCode == 200) {
        final List data = jsonDecode(shoppingRes.body);
        _shoppingList = data.map((json) => ShoppingItem.fromJson(json)).toList();
      }

      // 4. Fetch Activities
      final actRes = await http.get(Uri.parse('$_apiBaseUrl/activities/$fId'));
      if (actRes.statusCode == 200) {
        final List data = jsonDecode(actRes.body);
        _activities = data.map((json) => ActivityLog.fromJson(json)).toList();
      }

      _checkMockProximity();
    } catch (e) {
      print('API Refresh failed: $e. Reverting to local cache.');
    }
  }

  // ==========================================
  // AUTHENTICATION LOGIC (API & MOCK)
  // ==========================================

  Future<bool> register(String name, String email, String password, String role) async {
    _isLoading = true;
    notifyListeners();

    if (_isApiMode) {
      try {
        final response = await http.post(
          Uri.parse('$_apiBaseUrl/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': name,
            'email': email,
            'password': password,
            'role': role,
          }),
        );

        if (response.statusCode == 201) {
          final resData = jsonDecode(response.body);
          _currentUser = UserSession(
            id: resData['user']['id'],
            name: resData['user']['name'],
            email: resData['user']['email'],
            role: resData['user']['role'] ?? role,
            avatar: resData['user']['avatar'] ?? name.substring(0, 1).toUpperCase(),
          );
          await _saveSession();
          _isLoading = false;
          notifyListeners();
          return true;
        }
      } catch (e) {
        print('API Register Error: $e');
      }
    }

    // Fallback/Mock Register
    _currentUser = UserSession(
      id: const Uuid().v4(),
      name: name,
      email: email,
      role: role,
      avatar: name.substring(0, 1).toUpperCase(),
    );
    await _saveSession();
    _loadMockInitialData(); // Load mock family profiles for context
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    if (_isApiMode) {
      try {
        final response = await http.post(
          Uri.parse('$_apiBaseUrl/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        );

        if (response.statusCode == 200) {
          final resData = jsonDecode(response.body);
          final userMap = resData['user'];
          _currentUser = UserSession(
            id: userMap['id'],
            name: userMap['name'],
            email: userMap['email'],
            familyId: userMap['family_id'],
            familyName: userMap['familyName'],
            familyCode: userMap['familyCode'],
            role: userMap['role'] ?? 'Member',
            avatar: userMap['avatar'] ?? 'U',
          );
          await _saveSession();
          await refreshAllData();
          _isLoading = false;
          notifyListeners();
          return true;
        }
      } catch (e) {
        print('API Login Error: $e');
      }
    }

    // Mock Login: Always accept password "123456" or any
    _currentUser = UserSession(
      id: 'ali',
      name: 'Ali',
      email: email,
      role: 'Father',
      avatar: 'A',
      familyId: 'fam123',
      familyName: 'ABC Family',
      familyCode: 'FAM999',
    );
    await _saveSession();
    _loadMockInitialData();
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
    _tasks = [];
    _shoppingList = [];
    _activities = [];
    _familyMembers = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_session');
    notifyListeners();
  }

  Future<void> _saveSession() async {
    if (_currentUser == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_session', jsonEncode(_currentUser!.toJson()));
  }

  // ==========================================
  // FAMILY CREATION & JOINING (API & MOCK)
  // ==========================================

  Future<bool> createFamily(String familyName, String adminName, String role) async {
    if (_currentUser == null) return false;
    _isLoading = true;
    notifyListeners();

    if (_isApiMode) {
      try {
        final response = await http.post(
          Uri.parse('$_apiBaseUrl/family/create'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'familyName': familyName,
            'userId': _currentUser!.id,
            'role': role,
          }),
        );

        if (response.statusCode == 201) {
          final resData = jsonDecode(response.body);
          _currentUser = _currentUser!.copyWith(
            familyId: resData['family']['id'],
            familyName: resData['family']['name'],
            familyCode: resData['family']['invite_code'],
            role: resData['role'],
          );
          await _saveSession();
          await refreshAllData();
          _isLoading = false;
          notifyListeners();
          return true;
        }
      } catch (e) {
        print('API CreateFamily Error: $e');
      }
    }

    // Mock CreateFamily
    final mockFamCode = 'FAM${Math_random_code()}';
    _currentUser = _currentUser!.copyWith(
      familyId: 'fam123',
      familyName: familyName,
      familyCode: mockFamCode,
      role: role,
    );
    await _saveSession();
    _loadMockInitialData();
    _isLoading = false;
    notifyListeners();
    return true;
  }

  String Math_random_code() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    var out = '';
    for (var i = 0; i < 3; i++) {
      out += chars[(DateTime.now().microsecondsSinceEpoch + i) % chars.length];
    }
    return out;
  }

  Future<bool> joinFamily(String inviteCode, String memberName, String role) async {
    if (_currentUser == null) return false;
    _isLoading = true;
    notifyListeners();

    if (_isApiMode) {
      try {
        final response = await http.post(
          Uri.parse('$_apiBaseUrl/family/join'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'inviteCode': inviteCode,
            'userId': _currentUser!.id,
            'role': role,
          }),
        );

        if (response.statusCode == 200) {
          final resData = jsonDecode(response.body);
          _currentUser = _currentUser!.copyWith(
            familyId: resData['family']['id'],
            familyName: resData['family']['name'],
            familyCode: resData['family']['invite_code'],
            role: resData['role'],
          );
          await _saveSession();
          await refreshAllData();
          _isLoading = false;
          notifyListeners();
          return true;
        }
      } catch (e) {
        print('API JoinFamily Error: $e');
      }
    }

    // Mock JoinFamily
    _currentUser = _currentUser!.copyWith(
      familyId: 'fam123',
      familyName: 'ABC Family',
      familyCode: inviteCode.toUpperCase(),
      role: role,
    );
    await _saveSession();
    _loadMockInitialData();
    _isLoading = false;
    notifyListeners();
    return true;
  }

  // ==========================================
  // TASK CRUD (API & MOCK)
  // ==========================================

  Future<void> addTask({
    required String title,
    required String description,
    required String dueDate,
    required String locationName,
    required double latitude,
    required double longitude,
    String? assigneeId,
    required bool isUrgent,
    int geofenceRadius = 500,
  }) async {
    if (_currentUser == null || _currentUser!.familyId == null) return;
    _isLoading = true;
    notifyListeners();

    final assigneeUser = _familyMembers.firstWhere((m) => m.id == assigneeId, orElse: () => _currentUser!);

    if (_isApiMode) {
      try {
        final response = await http.post(
          Uri.parse('$_apiBaseUrl/tasks'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'title': title,
            'description': description,
            'due_date': dueDate,
            'location_name': locationName,
            'latitude': latitude,
            'longitude': longitude,
            'assignee_id': assigneeId ?? _currentUser!.id,
            'family_id': _currentUser!.familyId,
            'is_urgent': isUrgent,
            'userName': _currentUser!.name,
            'geofence_radius': geofenceRadius,
          }),
        );

        if (response.statusCode == 201) {
          await _fetchDataFromApi();
          _isLoading = false;
          notifyListeners();
          return;
        }
      } catch (e) {
        print('API AddTask Error: $e');
      }
    }

    // Mock AddTask
    final newTask = TaskItem(
      id: 'task-${const Uuid().v4()}',
      title: title,
      description: description,
      dueDate: dueDate,
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
      assigneeId: assigneeId ?? _currentUser!.id,
      assigneeName: assigneeUser.name,
      familyId: _currentUser!.familyId!,
      status: 'pending',
      isUrgent: isUrgent,
      createdAt: DateTime.now().toIso8601String(),
      geofenceRadius: geofenceRadius,
    );

    _tasks.insert(0, newTask);
    _activities.insert(
      0,
      ActivityLog(
        id: const Uuid().v4(),
        userName: _currentUser!.name,
        description: 'created task: "$title"',
        createdAt: DateTime.now().toIso8601String(),
      ),
    );

    _checkMockProximity();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleTask(String taskId) async {
    if (_currentUser == null) return;

    if (_isApiMode) {
      try {
        final response = await http.patch(
          Uri.parse('$_apiBaseUrl/tasks/$taskId/toggle'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'userName': _currentUser!.name}),
        );
        if (response.statusCode == 200) {
          await _fetchDataFromApi();
          return;
        }
      } catch (e) {
        print('API ToggleTask Error: $e');
      }
    }

    // Mock ToggleTask
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      final newStatus = task.status == 'pending' ? 'completed' : 'pending';
      _tasks[index] = task.copyWith(status: newStatus);

      final logDesc = newStatus == 'completed' ? 'completed task: "${task.title}"' : 're-opened task: "${task.title}"';
      _activities.insert(
        0,
        ActivityLog(
          id: const Uuid().v4(),
          userName: _currentUser!.name,
          description: logDesc,
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      _checkMockProximity();
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    if (_currentUser == null) return;

    if (_isApiMode) {
      try {
        final response = await http.delete(
          Uri.parse('$_apiBaseUrl/tasks/$taskId?userName=${_currentUser!.name}&familyId=${_currentUser!.familyId}'),
        );
        if (response.statusCode == 200) {
          await _fetchDataFromApi();
          return;
        }
      } catch (e) {
        print('API DeleteTask Error: $e');
      }
    }

    // Mock DeleteTask
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      _tasks.removeAt(index);
      _activities.insert(
        0,
        ActivityLog(
          id: const Uuid().v4(),
          userName: _currentUser!.name,
          description: 'deleted task: "${task.title}"',
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      _checkMockProximity();
      notifyListeners();
    }
  }

  Future<bool> lockTask(String taskId) async {
    if (_currentUser == null) return false;
    _isLoading = true;
    notifyListeners();

    if (_isApiMode) {
      try {
        final response = await http.patch(
          Uri.parse('$_apiBaseUrl/tasks/$taskId/lock'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userId': _currentUser!.id,
            'userName': _currentUser!.name,
          }),
        );
        if (response.statusCode == 200) {
          await _fetchDataFromApi();
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          final errBody = jsonDecode(response.body);
          print('API LockTask Failed: ${errBody['error']}');
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } catch (e) {
        print('API LockTask Error: $e');
      }
    }

    // Mock LockTask
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      if (task.lockedById != null && task.lockedById != _currentUser!.id) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _tasks[index] = task.copyWith(
        lockedById: _currentUser!.id,
        lockedByName: _currentUser!.name,
        lockedAt: DateTime.now().toIso8601String(),
        assigneeId: _currentUser!.id,
        assigneeName: _currentUser!.name,
      );

      _activities.insert(
        0,
        ActivityLog(
          id: const Uuid().v4(),
          userName: _currentUser!.name,
          description: 'accepted and locked task: "${task.title}"',
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      _checkMockProximity();
      _isLoading = false;
      notifyListeners();
      return true;
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> unlockTask(String taskId) async {
    if (_currentUser == null) return;
    _isLoading = true;
    notifyListeners();

    if (_isApiMode) {
      try {
        final response = await http.patch(
          Uri.parse('$_apiBaseUrl/tasks/$taskId/unlock'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'userName': _currentUser!.name}),
        );
        if (response.statusCode == 200) {
          await _fetchDataFromApi();
          _isLoading = false;
          notifyListeners();
          return;
        }
      } catch (e) {
        print('API UnlockTask Error: $e');
      }
    }

    // Mock UnlockTask
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      _tasks[index] = task.copyWith(
        lockedById: null,
        lockedByName: null,
        lockedAt: null,
        assigneeId: null,
        assigneeName: null,
      );

      _activities.insert(
        0,
        ActivityLog(
          id: const Uuid().v4(),
          userName: _currentUser!.name,
          description: 'unlocked task: "${task.title}"',
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      _checkMockProximity();
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================
  // SHOPPING LIST METHODS (API & MOCK)
  // ==========================================

  Future<void> addShoppingItem(String name, String quantity, bool isUrgent) async {
    if (_currentUser == null || _currentUser!.familyId == null) return;
    _isLoading = true;
    notifyListeners();

    if (_isApiMode) {
      try {
        final response = await http.post(
          Uri.parse('$_apiBaseUrl/shopping'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': name,
            'quantity': quantity,
            'is_urgent': isUrgent,
            'family_id': _currentUser!.familyId,
            'userName': _currentUser!.name,
          }),
        );
        if (response.statusCode == 201) {
          await _fetchDataFromApi();
          _isLoading = false;
          notifyListeners();
          return;
        }
      } catch (e) {
        print('API AddShopping Error: $e');
      }
    }

    // Mock AddShopping
    final newItem = ShoppingItem(
      id: 'shop-${const Uuid().v4()}',
      name: name,
      quantity: quantity.isEmpty ? '1' : quantity,
      isUrgent: isUrgent,
      isCompleted: false,
      familyId: _currentUser!.familyId!,
      createdAt: DateTime.now().toIso8601String(),
    );

    _shoppingList.insert(0, newItem);
    _activities.insert(
      0,
      ActivityLog(
        id: const Uuid().v4(),
        userName: _currentUser!.name,
        description: 'added "$name" to shopping list',
        createdAt: DateTime.now().toIso8601String(),
      ),
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleShoppingItem(String itemId) async {
    if (_currentUser == null) return;

    if (_isApiMode) {
      try {
        final response = await http.patch(
          Uri.parse('$_apiBaseUrl/shopping/$itemId/toggle'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'userName': _currentUser!.name}),
        );
        if (response.statusCode == 200) {
          await _fetchDataFromApi();
          return;
        }
      } catch (e) {
        print('API ToggleShopping Error: $e');
      }
    }

    // Mock ToggleShopping
    final index = _shoppingList.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      final item = _shoppingList[index];
      final newCompleted = !item.isCompleted;
      _shoppingList[index] = item.copyWith(isCompleted: newCompleted);

      final logDesc = newCompleted ? 'purchased "${item.name}"' : 'marked "${item.name}" as pending';
      _activities.insert(
        0,
        ActivityLog(
          id: const Uuid().v4(),
          userName: _currentUser!.name,
          description: logDesc,
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      notifyListeners();
    }
  }

  Future<void> deleteShoppingItem(String itemId) async {
    if (_currentUser == null) return;

    if (_isApiMode) {
      try {
        final response = await http.delete(
          Uri.parse('$_apiBaseUrl/shopping/$itemId?userName=${_currentUser!.name}&familyId=${_currentUser!.familyId}'),
        );
        if (response.statusCode == 200) {
          await _fetchDataFromApi();
          return;
        }
      } catch (e) {
        print('API DeleteShopping Error: $e');
      }
    }

    // Mock DeleteShopping
    final index = _shoppingList.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      final item = _shoppingList[index];
      _shoppingList.removeAt(index);

      _activities.insert(
        0,
        ActivityLog(
          id: const Uuid().v4(),
          userName: _currentUser!.name,
          description: 'removed "${item.name}" from shopping list',
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      notifyListeners();
    }
  }

  Future<void> updateAvailability(String status) async {
    if (_currentUser == null) return;
    
    // Optimistic update of local user session
    _currentUser = _currentUser!.copyWith(availability: status);
    await _saveSession();

    if (_isApiMode) {
      try {
        final response = await http.patch(
          Uri.parse('$_apiBaseUrl/users/${_currentUser!.id}/availability'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'availability': status,
            'userName': _currentUser!.name,
          }),
        );
        if (response.statusCode == 200) {
          await refreshAllData();
          return;
        }
      } catch (e) {
        print('API UpdateAvailability Error: $e');
      }
    }

    // Offline / Mock fallback: Update family members list
    final idx = _familyMembers.indexWhere((m) => m.id == _currentUser!.id);
    if (idx != -1) {
      _familyMembers[idx] = _familyMembers[idx].copyWith(availability: status);
    }

    final statusMap = {
      'free': '🟢 Free',
      'busy': '🔴 Busy',
      'driving': '🚗 Driving',
      'dnd': '🔕 Do Not Disturb'
    };
    final statusLabel = statusMap[status] ?? status;

    _activities.insert(
      0,
      ActivityLog(
        id: const Uuid().v4(),
        userName: _currentUser!.name,
        description: 'updated status to $statusLabel',
        createdAt: DateTime.now().toIso8601String(),
      ),
    );

    _checkMockProximity();
    notifyListeners();
  }

  // ==========================================
  // IN-APP TASK CHAT (GAP 7)
  // ==========================================

  List<TaskMessage> _mockMessages = [];
  Map<String, List<TaskMessage>> _taskMessages = {};

  List<TaskMessage> getMessagesForTask(String taskId) {
    if (_isApiMode) {
      return _taskMessages[taskId] ?? [];
    } else {
      return _mockMessages.where((m) => m.taskId == taskId).toList();
    }
  }

  int getMessageCount(TaskItem task) {
    if (_isApiMode) {
      return task.messageCount;
    } else {
      return _mockMessages.where((m) => m.taskId == task.id).length;
    }
  }

  Future<void> fetchMessages(String taskId) async {
    if (!_isApiMode) return;
    try {
      final response = await http.get(Uri.parse('$_apiBaseUrl/tasks/$taskId/messages'));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        _taskMessages[taskId] = data.map((json) => TaskMessage.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('API FetchMessages Error: $e');
    }
  }

  Future<void> sendMessage(String taskId, String text) async {
    if (_currentUser == null || text.trim().isEmpty) return;

    if (_isApiMode) {
      try {
        final response = await http.post(
          Uri.parse('$_apiBaseUrl/tasks/$taskId/messages'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'senderId': _currentUser!.id,
            'senderName': _currentUser!.name,
            'text': text.trim(),
          }),
        );
        if (response.statusCode == 201) {
          await fetchMessages(taskId);
          return;
        }
      } catch (e) {
        print('API SendMessage Error: $e');
      }
    }

    // Mock Mode
    final newMsg = TaskMessage(
      id: 'msg-${const Uuid().v4()}',
      taskId: taskId,
      senderId: _currentUser!.id,
      senderName: _currentUser!.name,
      text: text.trim(),
      timestamp: DateTime.now().toIso8601String(),
    );
    _mockMessages.add(newMsg);
    notifyListeners();
  }
}
