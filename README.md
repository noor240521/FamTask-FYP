# Smart Family Task Manager with Location-Based Assistance

A Flutter + Firebase mobile application designed to help families coordinate, assign, and complete household tasks efficiently using location-based assistance, AI-driven suggestions, and real-time collaboration features.

## 📱 Overview

Smart Family Task Manager allows family members to create, assign, and track tasks within a shared family group. The app suggests the most suitable family member for each task based on their location, availability, and task history, while also supporting offline use, gamification, and parental controls for child accounts.

## 🛠️ Tech Stack

- **Frontend:** Flutter (Dart)
- **Backend / Database:** Firebase (Firestore, Cloud Functions, Authentication)
- **State Management:** Provider
- **Offline Storage:** Hive
- **Location Services:** Geofencing & Connectivity plugins

## ✨ Key Features

- Family creation and member management with role-based access (Admin / Member / Child)
- Location-based task assignment with geofence notifications
- AI-based suggestion system for assigning the most suitable member to a task
- Task locking to prevent conflicting acceptance by multiple members
- Offline support with automatic sync when connection is restored
- Recurring tasks (daily / weekly / monthly)
- Member availability status (Free / Busy / Driving / Do Not Disturb)
- In-app real-time chat for each task
- Gamification with points, streaks, badges, and a family leaderboard
- Parental controls and child safety restrictions

## 📂 Project Structure

```
FamTask-FYP/
├── famtask_app/        # Flutter frontend application
├── famtask_backend/     # Node.js backend (database, routes, server)
└── .gitignore
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.22 or later)
- Node.js & npm
- Firebase project setup

### Frontend Setup
```bash
cd famtask_app
flutter pub get
flutter run
```

### Backend Setup
```bash
cd famtask_backend
npm install
node server.js
```

## 👤 Author

Noor 
Air University, Islamabad — Associate Degree in Computer Science (ADSCS)

## 📄 License

This project is developed for academic purposes as part of the Final Year Project (FYP).
