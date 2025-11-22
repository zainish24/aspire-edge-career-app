# AspireEdge - Career Passport App 🚀

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

A modern Flutter application for career guidance and professional development.

</div>

## ✨ Features

### 🎯 Core Functionality
- **User Authentication** - Secure login/signup with Firebase Auth
- **Career Exploration** - Browse and discover career paths
- **Profile Management** - Personal information and preferences
- **Resource Library** - Educational content and materials
- **Career Assessment** - Quizzes and self-evaluation tools

### 🚀 Technical Features
- **Cross-Platform** - iOS, Android & Web support
- **Real-time Database** - Cloud Firestore integration
- **File Storage** - Firebase Storage for media files
- **Modern UI/UX** - Clean, intuitive Flutter design
- **State Management** - Efficient app state handling

## 🛠 Tech Stack

**Frontend:**
- Flutter 3.0+
- Dart 2.17+
- Material Design 3
- Responsive Layout

**Backend & Services:**
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Cloudinary Integration

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0 or later
- Firebase account
- Cloudinary account (for media uploads)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/zainish24/aspire-edge-career-app
   cd aspire-edge-career-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup Firebase**
   - Create Firebase project
   - Download config files:
     - `android/app/google-services.json`
     - `ios/Runner/GoogleService-Info.plist`
   - Run: `flutterfire configure`

4. **Configure Cloudinary**
   - Update `lib/config/app_config.dart` with your credentials

5. **Run the app**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
aspire_edge/
├── android/                 # Android specific files
├── ios/                     # iOS specific files  
├── lib/
│   ├── core/
│   │   ├── config/         # App configuration
│   │   ├── constants/      # App constants
│   │   ├── utils/          # Utilities & helpers
│   │   └── widgets/        # Reusable widgets
│   ├── data/
│   │   ├── models/         # Data models
│   │   ├── repositories/   # Data repositories
│   │   └── sources/        # Data sources
│   ├── domain/
│   │   ├── entities/       # Business entities
│   │   └── usecases/       # Business logic
│   ├── presentation/
│   │   ├── pages/          # App screens
│   │   ├── providers/      # State management
│   │   └── blocs/          # Business logic
│   └── main.dart           # App entry point
├── assets/                  # Images, fonts, etc.
├── web/                     # Web specific files
└── pubspec.yaml            # Dependencies
```

## 🔧 Development

### Build Commands
```bash
# Development build
flutter run

# Production build
flutter build apk --release
flutter build ios --release
flutter build web --release
```

### Testing
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request


<div align="center">

### ⭐️ If this project helped you, give it a star!

**Built with ❤️ using Flutter**

</div>
