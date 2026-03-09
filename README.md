# Student Housing Finder 🏠📱

![Flutter](https://img.shields.io/badge/Flutter-Framework-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-Language-blue?logo=dart)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green)
![Status](https://img.shields.io/badge/Project-UI%20Prototype-orange)

A modern **Flutter mobile application** that helps students find suitable housing near universities and allows property owners to list their available properties.

This project demonstrates **clean UI architecture, modular Flutter structure, cross-platform mobile development, and Supabase backend integration**.

---

# 📌 Project Description

Finding accommodation near universities can be difficult for students.  
The **Student Housing Finder** application simplifies this process by providing a centralized platform where students can explore available housing and connect with property owners.

The project focuses on building a **clean, scalable, and well-structured Flutter UI application** with full backend integration using Supabase.

---

# ✨ Features

### 👨‍🎓 Student Features
* Browse student housing listings
* View property details
* Save favorite properties
* Filter housing options
* Contact property owners
* Manage personal profile

### 🏠 Owner Features
* Add new properties
* Edit property listings
* Manage available properties
* View property status

### 💬 Communication
* Chat interface between students and property owners
* Real-time updates using Supabase Realtime

### 🎨 UI/UX Experience
* Clean modern interface
* Reusable UI components
* Organized navigation
* Light and dark themes
* Error handling and loading states for async operations

---

# 🏗 Project Architecture

The project follows a **clean modular Flutter architecture** using Providers, Repositories, and Services.

```text
student_housing_finder/
│
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_strings.dart
│   │   │   └── app_assets.dart
│   │   ├── routing/
│   │   │   └── app_routes.dart
│   │   ├── theme/
│   │   │   ├── light_theme.dart
│   │   │   └── dark_theme.dart
│   │   └── utils/
│   │       ├── validators.dart
│   │       └── supabase_client.dart
│   ├── data/
│   │   ├── services/
│   │   │   ├── auth_service.dart
│   │   │   ├── property_service.dart
│   │   │   ├── favorite_service.dart
│   │   │   └── chat_service.dart
│   │   └── repositories/
│   │       ├── auth_repository.dart
│   │       ├── property_repository.dart
│   │       ├── favorite_repository.dart
│   │       └── chat_repository.dart
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── property_model.dart
│   │   ├── favorite_model.dart
│   │   └── message_model.dart
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── property_provider.dart
│   │   ├── favorite_provider.dart
│   │   ├── chat_provider.dart
│   │   └── theme_provider.dart
│   ├── screens/
│   │   ├── splash/
│   │   │   └── splash_screen.dart
│   │   ├── onboarding/
│   │   │   └── onboarding_screen.dart
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── student/
│   │   │   ├── student_home_screen.dart
│   │   │   ├── property_details_screen.dart
│   │   │   ├── favorites_screen.dart
│   │   │   └── student_profile_screen.dart
│   │   ├── owner/
│   │   │   ├── owner_dashboard_screen.dart
│   │   │   ├── add_property_screen.dart
│   │   │   ├── edit_property_screen.dart
│   │   │   └── owner_profile_screen.dart
│   │   ├── chat/
│   │   │   ├── chat_list_screen.dart
│   │   │   └── chat_screen.dart
│   │   └── common/
│   │       └── filter_screen.dart
│   ├── widgets/
│   │   ├── common/
│   │   │   ├── custom_button.dart
│   │   │   ├── custom_text_field.dart
│   │   │   └── custom_app_bar.dart
│   │   ├── property/
│   │   │   ├── property_card.dart
│   │   │   ├── property_slider.dart
│   │   │   └── property_info_section.dart
│   │   └── owner/
│   │       └── owner_property_card.dart
│   ├── main.dart
│   └── app.dart
├── assets/
│   ├── images/
│   └── icons/
├── pubspec.yaml
└── README.md
```

---

# 📱 Application Screens

## Splash Screen
Displays the application logo while initializing the app.

## Onboarding Screen
Introduces users to the main features of the application.

## Login Screen
Allows users to sign in using their credentials.

## Register Screen
Allows new users to create accounts and select their role (Student or Owner).

---

# 👨‍🎓 Student Interface

## Student Home Screen
Main dashboard displaying property listings.

## Property Details Screen
Shows detailed information about selected properties.

## Favorites Screen
Displays all saved properties.

## Student Profile Screen
Allows users to manage their personal profile.

---

# 🏠 Owner Interface

## Owner Dashboard
Displays all properties listed by the owner.

## Add Property Screen
Allows owners to add new housing listings.

## Edit Property Screen
Allows editing of existing listings.

## Owner Profile Screen
Displays owner account information.

---

# 💬 Chat System

## Chat List Screen
Shows all conversations.

## Chat Screen
Allows messaging between students and property owners.

---

# 🎨 Reusable Widgets

* Custom buttons
* Property cards
* Input fields
* Image sliders
* Property information sections

---

# 🚀 Installation

Clone the repository:

```bash
git clone https://github.com/your-username/student_housing_finder.git
```

Install dependencies:

```id="3w4do0"
flutter pub get
```

Run the project:

```id="32qkbe"
flutter run
```

---

# 🎯 Project Objective

This project demonstrates:

- Cross-platform mobile development with Flutter
- Clean project architecture with Providers, Repositories, and Services
- Reusable UI component design
- Integration with Supabase backend (Auth, Database, Storage, Realtime)
- Mobile UI/UX implementation with Error & Loading states

---

# 📚 Educational Purpose

This project was developed as part of a mobile application development learning project to practice:

- Flutter architecture
- State management with Providers
- UI/UX design
- Supabase integration

---

# 📄 License

This project is intended for educational purposes only.