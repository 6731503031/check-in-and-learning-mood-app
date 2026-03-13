# Check-in & Learning Mood App

## Project Description

This is a Flutter app for class attendance and learning reflection.

The app supports two roles:

- Student
	- Check in before class
	- Finish class after session
	- View submission history
- Teacher
	- Generate QR code from class ID
	- View student submissions by class

Core features:

- QR-based class flow
- GPS capture during check-in and finish
- Mood input with emoji + horizontal slider
- Firebase Firestore data storage (with local in-memory fallback when Firebase is not configured)

## Setup Instructions

### Prerequisites

- Flutter SDK (3.x)
- Dart SDK (comes with Flutter)
- Node.js + npm (for Firebase Hosting deploy)
- Firebase project (for real database/hosting)

### Install dependencies

```bash
flutter pub get
```

## How to Run the App

### Run locally (Web)

```bash
flutter run -d chrome
```

### Build Web (Release)

```bash
flutter build web --release
```

### Deploy to Firebase Hosting

```bash
npx firebase-tools deploy --only hosting
```

Current hosting URL (if already deployed):

- https://check-in-and-learning-mood-app.web.app

## Firebase Configuration Notes

### 1) Firebase options in Flutter

Update values in:

- `lib/firebase_options.dart`

Replace placeholder values (`YOUR_...`) with actual values from Firebase Console.

### 2) Platform config files

Use real files from Firebase Console for each platform:

- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`
- macOS: `macos/Runner/GoogleService-Info.plist`

### 3) Firestore

Enable Firestore in your Firebase project.

This app uses collection:

- `class_sessions`

If Firebase is not configured correctly, the app automatically falls back to in-memory storage for demo usage.

### 4) Web scanner note

QR camera scan on web requires browser camera permission and HTTPS/localhost.

The app also supports fallback options:

- Upload QR image
- Manual QR input
