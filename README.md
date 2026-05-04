# Student Housing Finder 🏠📱

[![Flutter](https://img.shields.io/badge/Flutter-Framework-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-Language-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-34A853?logo=android&logoColor=white)](https://www.android.com)

A premium **Flutter mobile application** designed to bridge the gap between students seeking accommodation and property owners. It provides a seamless, localized, and real-time experience for finding the perfect home near campus.

---

## 📌 Project Overview

**Student Housing Finder** is built to solve the struggle of finding reliable student housing. The app offers a dual-interface experience tailored for both students and owners, integrated with a robust Supabase backend for real-time data management.

### Key Highlights:
- **Clean Architecture:** Modular and scalable code structure.
- **Multilingual Support:** Full Arabic and English localization.
- **Real-time Interaction:** Instant messaging and notifications.
- **Modern UI:** Sleek, responsive design with Dark/Light mode support.

---

## ✨ Core Features

### 👨‍🎓 For Students
- **Smart Discovery:** Browse and filter listings by location, price, and amenities.
- **Detailed Insights:** Comprehensive property views with image sliders and feature lists.
- **Favorites:** Save preferred listings for quick access.
- **Direct Connect:** Chat directly with owners and receive instant notifications.

### 🏠 For Property Owners
- **Listing Management:** Add, edit, and manage property status (Available/Rented).
- **Dashboard:** Overview of active listings and views.
- **Engagement:** Real-time chat with interested students.

### ⚙️ System Features
- **Localization:** Seamless toggle between Arabic and English.
- **Theming:** Dynamic Light and Dark mode.
- **Authentication:** Secure sign-up/login with role selection (Student/Owner).
- **Push Notifications:** Stay updated on messages and property status.

---

## 🏗 Project Structure

```text
lib/
├── core/
│   ├── theme/          # Light & Dark theme definitions
│   └── utils/          # App constants, localization keys, and helpers
├── data/
│   └── services/       # Supabase integration (Auth, Chat, Property, Notifications)
├── models/             # Data models (User, Property, Message, etc.)
├── providers/          # State management (App, Auth, Property providers)
├── screens/
│   ├── auth/           # Login, Register, Forgot Password
│   ├── home/           # Student Home & Owner Dashboard
│   ├── chat/           # Conversation list and Chat screen
│   ├── notifications/  # User notifications center
│   ├── property/       # Details and listing views
│   └── splash/         # Initializing screen
├── widgets/            # Reusable UI components (Buttons, Cards, Inputs)
├── app.dart            # Root widget & routing configuration
└── main.dart           # Application entry point
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest version recommended)
- Supabase Account & Project

### Installation
1. **Clone the repo:**
   ```bash
   git clone https://github.com/your-username/student_housing_finder.git
   ```
2. **Install dependencies:**
   ```bash
   flutter pub get
   ```
3. **Setup Environment:**
   Create a configuration for your Supabase URL and Anon Key in the initialization logic.
4. **Run the app:**
   ```bash
   flutter run
   ```

---

## 🎯 Educational Goals
This project serves as a showcase for:
- Implementing **Provider** for state management.
- Integrating **Supabase** (Auth, Database, Storage, and Realtime).
- Building a **Localized UI** with RTL support.
- Following **Clean Code** principles and modular design.

---

## 📄 License
This project is developed for educational and portfolio purposes.

---
*Developed with ❤️ for Students and Developers.*
