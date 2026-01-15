# FieldSync

**FieldSync** is a modern, offline-first field data collection application built with Flutter. It allows users to design custom forms, collect data in remote areas without internet access, and sync everything securely to the cloud when online.

<p align="center">
  <img src="assets/icon/app_icon.png" width="120" alt="FieldSync Logo" />
</p>

## 📱 Screenshots

<p align="center">
  <img src="assets/WhatsApp Image 2026-01-15 at 10.47.36.jpeg" width="200" alt="Sign In Screen" />
  <img src="assets/WhatsApp Image 2026-01-15 at 10.47.20.jpeg" width="200" alt="Dashboard Overview" />
  <img src="assets/WhatsApp Image 20236-01-15 at 10.47.21.jpeg" width="200" alt="Submissions" />
  <img src="assets/WhatsApp Image 2026-01-15 at 10.47.21.jpeg" width="200" alt="Profile" />
</p>

## 🚀 Features

*   **Offline-First Architecture**: Built from the ground up to work without an internet connection. Data is stored locally (using Hive) and synced automatically when a connection is restored.
*   **Dynamic Form Builder**: Support for various field types (Text, Number, Date, Photo, GPS Location, Dropdowns).
*   **Account Scoping**: User data is strictly isolated. Users only see and manage their own submissions.
*   **Modern UI/UX**: A minimalist, "Industrial" design aesthetic with high contrast, bold typography, and smooth animations.
*   **Excel Export**: Export collected data to Excel sheets for reporting and analysis.
*   **Photo Evidence**: Capture and attach photos directly to form submissions.

## 🛠 Tech Stack

*   **Framework**: Flutter (Dart)
*   **State Management**: Riverpod
*   **Local Database**: Hive (NoSQL, fast, lightweight)
*   **Backend**: Firebase (Auth, Firestore, Storage)
*   **Connectivity**: `connectivity_plus` for network state monitoring.
*   **Architecture**: Feature-first, Repository Pattern.

## 📂 Project Structure

```
lib/
├── core/            # Shared utilities (Database, Network, Theme, Routing)
├── features/        # Feature modules
│   ├── auth/        # Login, Sign Up, User Management
│   ├── forms/       # Form Builder, Detail, and Fill Screens
│   ├── profile/     # User Profile & Stats
│   └── submissions/ # Submission Management, History, Sync Logic
└── main.dart        # App Entry Point & Global Config
```

## 🏁 Getting Started

1.  **Prerequisites**:
    *   Flutter SDK (3.9.2 or higher)
    *   Dart SDK
    *   Firebase Project configured

2.  **Installation**:
    ```bash
    flutter pub get
    ```

3.  **Run the App**:
    ```bash
    flutter run
    ```

4.  **Build Release**:
    ```bash
    flutter build apk --release
    ```

## 🔒 Security

*   **Firebase Auth**: Secure email/password authentication.
*   **Data Isolation**: Submissions are tagged with `userId` and filtered at the controller level.
*   **Local Encryption**: (Optional future enhancement for Hive boxes).

## 📄 License

This specific implementation is proprietary.
