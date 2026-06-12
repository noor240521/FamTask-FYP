# Antigravity Prompt — Fill Gaps in Smart Family Task Manager (Flutter)

> **Project:** Smart Family Task Manager with Location-Based Assistance  
> **Framework:** Flutter + Firebase  
> **Status:** Core features done — filling missing gaps only

---

## IMPORTANT INSTRUCTIONS

- Do **NOT** rewrite existing working code
- Only **ADD** new features or **EXTEND** existing files
- Show me exactly which file to modify and what to add
- After each gap is done, **pause and wait for my confirmation**
- Handle all loading, error, and empty states in UI

---

## GAP 1 — AI Smart Logic (Firebase Cloud Functions)

Create a Firebase Cloud Function that runs when a new task is created.

**Logic:**
- Fetch all family members from Firestore
- For each member, calculate a score based on:
  - Distance from task location (closer = higher score)
  - Current availability status (free=+50, busy=-50, driving=-30, dnd=-100)
  - Past task completion count of same priority (higher history = higher score)
- Return the member with highest score as `suggestedMember`
- Save `suggestedMember: uid` field back to the task document

**In Flutter:**
- On Task Detail Screen, show a banner: `"AI Suggestion: [Member Name] is best suited for this task"`
- Show a button `"Assign to Suggested Member"`
- Only visible to Admin

**Files:**
- Create: `functions/index.js`
- Modify: `lib/screens/tasks/task_detail_screen.dart`

---

## GAP 2 — Conflict Handling (Task Locking)

Add to Firestore task document (if not already present):
```
lockedBy: string (uid or null)
lockedAt: timestamp (or null)
```

**Logic:**
- When a member taps "Accept Task", write their uid to `lockedBy` and current time to `lockedAt`
- If `lockedBy` is already set by someone else, show: `"This task is already accepted by [Member Name]"`
- Disable the Accept button for everyone else while task is locked
- Firebase Cloud Function: run every 30 minutes, check all tasks where `lockedBy != null` and `status == pending`, if `lockedAt` is older than 30 minutes reset both fields to null (auto-unlock)
- Show a lock icon on task cards that are currently locked

**Files:**
- Modify: `lib/screens/tasks/task_detail_screen.dart`
- Modify: `lib/services/firestore_service.dart`
- Modify: `lib/screens/tasks/task_list_screen.dart`
- Modify: `functions/index.js`

---

## GAP 3 — Offline Support (Hive Caching)

**Setup:**
- Add `hive` and `hive_flutter` to `pubspec.yaml`
- Create Hive box: `tasksBox`
- Create Hive box: `pendingActionsBox`

**Logic:**
- Whenever tasks are fetched from Firestore, also save them to `tasksBox`
- When device is offline (use `connectivity_plus`), load tasks from `tasksBox` instead
- When user updates task status while offline, save the action to `pendingActionsBox` as:
  ```
  { taskId, newStatus, timestamp }
  ```
- When connection restores, auto-process all items in `pendingActionsBox`, sync to Firestore, then clear the box
- Show a red banner at top of screen when offline:  
  `"You are offline. Changes will sync when connected."`

**Files:**
- Create: `lib/services/offline_service.dart`
- Modify: `lib/services/firestore_service.dart`
- Modify: `lib/providers/task_provider.dart`
- Modify: `lib/screens/dashboard/dashboard_screen.dart`
- Modify: `pubspec.yaml`

---

## GAP 4 — Recurring Tasks

Add to task model (if not already present):
```
isRecurring: boolean
recurringPattern: string (daily/weekly/monthly)
```

**Logic:**
- On Add Task Screen, add a toggle `"Recurring Task"`
- When toggled on, show dropdown: Daily / Weekly / Monthly
- When a recurring task is marked as completed, Firebase Cloud Function auto-creates a new identical task with:
  - New `createdAt` = now
  - New `dueDate` = old dueDate + 1 day (daily) / 7 days (weekly) / 30 days (monthly)
  - `status` reset to `pending`
  - `lockedBy` reset to null

**Files:**
- Modify: `lib/models/task_model.dart`
- Modify: `lib/screens/tasks/add_task_screen.dart`
- Modify: `lib/services/firestore_service.dart`
- Modify: `functions/index.js`

---

## GAP 5 — Member Availability Status

Add to user model (if not already present):
```
availability: string (free/busy/driving/dnd)
```

**Logic:**
- On Profile Screen, add availability selector with 4 chip options:
  - 🟢 Free
  - 🔴 Busy
  - 🚗 Driving
  - 🔕 Do Not Disturb
- Tapping a chip updates Firestore user document immediately
- On Family Members Screen, show availability badge next to each member name
- In geofence suggestion logic: only send suggestion notification if member availability is `free`
- If member is `dnd`, do not send any notifications at all

**Files:**
- Modify: `lib/models/user_model.dart`
- Modify: `lib/screens/profile/profile_screen.dart`
- Modify: `lib/screens/members/family_members_screen.dart`
- Modify: `lib/services/notification_service.dart`
- Modify: `lib/services/geofence_service.dart`

---

## GAP 6 — Configurable Geofence Radius

**Logic:**
- On Add Task Screen, add a Slider widget:
  - Min: 100 meters
  - Max: 1000 meters
  - Divisions: 3 (100m, 500m, 1000m)
  - Label: `"Notify within: 500m"`
- Save `geofenceRadius` to Firestore task document
- In geofence service, read `geofenceRadius` from task and use it as the trigger distance instead of any hardcoded value

**Files:**
- Modify: `lib/screens/tasks/add_task_screen.dart`
- Modify: `lib/models/task_model.dart`
- Modify: `lib/services/geofence_service.dart`

---

## GAP 7 — In-App Task Chat

**Firestore structure:**
```
chats/{taskId}/messages/{messageId}
{
  senderId: string,
  senderName: string,
  text: string,
  timestamp: timestamp
}
```

**Logic:**
- On Task Detail Screen, add a chat section below task info
- Show messages in a scrollable list (sender name + message + time)
- Current user's messages on right, others on left (WhatsApp style)
- Text input at bottom with send button
- Messages load in real-time using Firestore stream
- Show unread message count badge on task cards in task list

**Files:**
- Create: `lib/widgets/task_chat_widget.dart`
- Modify: `lib/screens/tasks/task_detail_screen.dart`
- Modify: `lib/services/firestore_service.dart`
- Modify: `lib/screens/tasks/task_list_screen.dart`

---

## GAP 8 — Gamification (Points, Badges, Leaderboard)

Add to user model (if not already present):
```
points: number
streaks: number
lastCompletedDate: timestamp
badges: list of strings
```

**Points logic:**
- When task status is set to `completed`, add points to the completing member:
  - Critical = 50 points
  - High = 30 points
  - Normal = 20 points
  - Low = 10 points

**Streak logic:**
- When task completed, check if `lastCompletedDate` was yesterday
- If yes → increment `streaks` by 1
- If no (missed a day) → reset `streaks` to 1
- Update `lastCompletedDate` to today

**Badges (auto-awarded):**

| Badge ID | Condition |
|----------|-----------|
| `first_task` | Complete first task ever |
| `team_player` | Complete 10 tasks total |
| `speed_runner` | Complete task within 1 hour of creation |
| `perfect_week` | Complete all assigned tasks in a week |
| `location_hero` | Complete 5 location-based tasks |

**Leaderboard Screen:**
- Show all family members sorted by points (highest first)
- Show rank number, name, points, streak count, and badges
- Reset points every Monday at midnight (Firebase Cloud Function)

**Files:**
- Create: `lib/screens/leaderboard/leaderboard_screen.dart`
- Modify: `lib/models/user_model.dart`
- Modify: `lib/services/firestore_service.dart`
- Modify: `functions/index.js`

---

## GAP 9 — Child Safety & Parental Controls

Add to user model: `role: string (admin/member/child)`  
Add to task model: `isChildRestricted: boolean`

**Logic:**
- Admin can change any member's role to `child` from Family Members Screen
- Child accounts cannot see tasks where `isChildRestricted == true`
- When a child marks a task complete, set status to `pendingApproval` instead of `completed`
- On Parental Controls Screen (admin only):
  - Show list of tasks with status `pendingApproval`
  - Admin can **Approve** (sets status to `completed`, awards points) or **Reject** (resets status to `pending`)
- Child's location always visible to admin regardless of privacy settings
- Children cannot change their own availability status

**Files:**
- Create: `lib/screens/parental_controls/parental_controls_screen.dart`
- Modify: `lib/models/user_model.dart`
- Modify: `lib/models/task_model.dart`
- Modify: `lib/screens/tasks/task_list_screen.dart`
- Modify: `lib/screens/tasks/task_detail_screen.dart`
- Modify: `lib/screens/members/family_members_screen.dart`
- Modify: `lib/services/firestore_service.dart`

---

## Gaps Summary

| # | Gap | Status |
|---|-----|--------|
| 1 | AI Smart Logic | ⬜ To Do |
| 2 | Conflict Handling (Task Locking) | ⬜ To Do |
| 3 | Offline Support (Hive Caching) | ⬜ To Do |
| 4 | Recurring Tasks | ⬜ To Do |
| 5 | Member Availability Status | ⬜ To Do |
| 6 | Configurable Geofence Radius | ⬜ To Do |
| 7 | In-App Task Chat | ⬜ To Do |
| 8 | Gamification (Points, Badges, Leaderboard) | ⬜ To Do |
| 9 | Child Safety & Parental Controls | ⬜ To Do |

---

## Final Instructions for Antigravity

- Implement all 9 gaps **in order**
- After each gap, tell me exactly which files were modified and what was changed
- **Do not delete any existing working code**
- All new UI must follow the same theme and color palette already used in the project
- All new Firestore writes must include proper error handling with `try/catch`
- **Pause after each gap and wait for me to say "next" before continuing**
