[readme so.md](https://github.com/user-attachments/files/28172048/readme.so.md)
# 📚 Skillora — Skill Exchange Platform

> **Learn • Teach • Grow**

A full-featured skill exchange mobile app built with **Flutter & Firebase**. Connect with people who want to learn what you know, and teach what you want to learn — no money, just skills!

---

## 📱 Screenshots

| Login | Teach Skills | Learn Skills | Messages |
|---|---|---|---|
| ![Login](screenshots/skillora_login.jpeg) | ![Teach](screenshots/skillora_teach.jpeg) | ![Learn](screenshots/skillora_learn.jpeg) | ![Messages](screenshots/skillora_messages.jpeg) |

| Schedule Session | Chat | Match Card | It's a Match! |
|---|---|---|---|
| ![Schedule](screenshots/skillora_schedule.jpeg) | ![Chat](screenshots/skillora_chat.jpeg) | ![Match Card](screenshots/skillora_match_card.jpeg) | ![Match](screenshots/skillora_its_a_match.jpeg) |

| Call Options | Profile | Receive Skill |
|---|---|---|
| ![Call](screenshots/skillora_call.jpeg) | ![Profile](screenshots/skillora_profile.jpeg) | ![Receive](screenshots/skillora_receive_skill.jpeg) |

---

## ✨ Features

### 👤 User Side
- 🔐 Sign Up / Sign In with Firebase Auth & Google Sign-In
- 🎯 Onboarding — select skills to learn & skills to teach
- 🏠 Home Screen with skill matches
- 🤝 Skill Matching System — find your perfect learning partner
- 💬 Real-time Chat with audio messages
- 📹 Video & Audio Calling (Zego UIKit)
- 📅 Session Scheduling — book learning sessions with date & time
- 📊 Learning Dashboard — track your progress
- 🏆 Leaderboard — top learners & teachers
- 🔔 Push Notifications (Firebase Messaging)
- 👥 Invite Friends
- ⚙️ Settings, Privacy & Security
- ℹ️ About, FAQ & Help Support

### 🛠️ Additional
- 🖼️ Cloudinary image uploads
- 📖 App Guide & Walkthrough screens
- 🌐 Availability scheduling

---

## 🛠️ Tech Stack

| Technology | Usage |
|---|---|
| Flutter | UI Framework |
| Dart | Programming Language |
| Firebase Auth | User Authentication |
| Cloud Firestore | Real-time Database |
| Firebase Messaging | Push Notifications |
| Google Sign-In | OAuth Authentication |
| Zego UIKit | Video & Audio Calling |
| Cloudinary | Image Storage |
| Provider | State Management |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK
- Dart SDK
- Firebase project setup
- Zego account (for calling)
- Cloudinary account (for image uploads)
- Android Studio / VS Code

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/HanzlaSajid888/skillora.git
cd skillora
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Firebase Setup**
   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Enable **Authentication** (Email/Password + Google)
   - Enable **Cloud Firestore**
   - Enable **Firebase Messaging**
   - Download `google-services.json` and place it in `android/app/`

4. **Zego Setup**
   - Create an account at [zegocloud.com](https://www.zegocloud.com)
   - Get your App ID & App Sign
   - Add them to your project config

5. **Run the app**
```bash
flutter run
```

---

## 📁 Project Structure

```
lib/
├── models/
│   ├── user_profile.dart
│   └── call_model.dart
├── providers/
│   └── user_provider.dart
├── screens/
│   ├── call_screen.dart
│   ├── incoming_call_screen.dart
│   └── outgoing_call_screen.dart
├── services/
│   └── call_service.dart
├── utils/
│   ├── cloudinary_helper.dart
│   └── notification_service.dart
├── walkthrough/
│   └── walkthrough_screen.dart
├── widgets/
│   └── audio_message_bubble.dart
├── home_screen.dart
├── chat_screen.dart
├── match_screen.dart
├── leaderboard_screen.dart
├── messages_screen.dart
├── schedule_session_screen.dart
├── learn_skills_screen.dart
├── teach_skills_screen.dart
├── learning_dashboard_screen.dart
├── availability_screen.dart
├── profile_setup_screen.dart
├── personal_info_screen.dart
├── settings_screen.dart
├── privacy_security_screen.dart
├── help_support_screen.dart
├── about_screen.dart
├── faq_screen.dart
├── app_guide_screen.dart
├── invite_friends_screen.dart
├── signup_screen.dart
├── welcome_screen.dart
├── splash_screen.dart
└── main.dart
```

---

## 🎓 About This Project

Skillora is a peer-to-peer skill exchange platform — the idea is simple: everyone has something to teach and something to learn. Instead of paying for courses, users match with each other based on complementary skills and schedule learning sessions directly in the app.

---

## 🙌 Connect With Me

- LinkedIn: [Hanzla Sajid](https://www.linkedin.com/in/hanzla-sajid-flutter/)
- GitHub: [HanzlaSajid888](https://github.com/HanzlaSajid888)

---

> ⭐ If you found this project helpful, please give it a star!
