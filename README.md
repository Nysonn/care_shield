# CareShield 🏥

[![Flutter](https://img.shields.io/badge/Flutter-3.32.7-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev/)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey.svg)](https://flutter.dev/)

**Confidential HIV Health Delivery System**

CareShield is a comprehensive mobile health application designed to provide confidential and accessible HIV healthcare services to patients in Uganda. The app enables users to securely request HIV health services including medications, counseling, and professional consultations while maintaining complete privacy and dignity.

## ✨ Features

### 🏠 Dashboard
- **Personalized Welcome**: Greeting with user's name and health check-in
- **Healthcare Search**: Find nearby healthcare facilities with location-based services
- **Quick Health Assessment**: Daily symptom reporting and health surveys
- **Professional Consultation**: Direct access to healthcare professionals

### 💊 Medication Management
- **Drug Ordering**: Request HIV medications (ARVs) for new patients or refills
- **Free Delivery**: No-cost medication delivery across Uganda
- **Treatment Tracking**: Monitor medication adherence and schedules
- **Automatic Refill Reminders**: Never miss a dose with smart notifications

### 🩺 Care Services
- **Appointment Booking**: Schedule physical or virtual consultations
- **Counseling Services**: Access to trained HIV counselors
- **Health Education**: Information on staying safe and medication adherence
- **Support Resources**: Comprehensive HIV care guidance

### 💬 Health Chat
- **24/7 Support**: Real-time communication with healthcare assistants
- **Confidential Messaging**: Secure, encrypted conversations
- **Professional Guidance**: Expert advice and immediate support
- **Emergency Assistance**: Quick access to urgent care information

## 🛠 Technical Stack

- **Framework**: Flutter 3.32.7
- **Language**: Dart 3.0+
- **State Management**: Provider Pattern
- **Local Storage**: Hive (Encrypted)
- **Architecture**: Feature-based Clean Architecture
- **Platform**: Android & iOS

## 🎨 Design System

### Color Palette
- **Primary Blue**: `#2563EB` - Professional, trustworthy
- **Secondary Green**: `#10B981` - Health, positive outcomes  
- **Background**: `#F8FAFC` - Clean, medical
- **Surface**: `#FFFFFF` - Pure white
- **Text**: `#1E293B` - Dark slate
- **Accent**: `#F59E0B` - Warning/attention for emergency features

### Typography
- **Primary Font**: Inter / System UI
- **Characteristics**: Clean, modern, excellent readability

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.32.7 or higher
- Dart SDK 3.0 or higher
- Android Studio / VS Code
- Android SDK / Xcode (for iOS)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Nysonn/care_shield.git
   cd care_shield
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### Development Setup

1. **Enable developer options** on your device
2. **Connect device** via USB or use an emulator
3. **Verify installation**
   ```bash
   flutter doctor
   ```

## 📁 Project Structure

```
lib/
├── app.dart                     # Main app configuration
├── main.dart                    # Entry point
├── core/                        # Core utilities and constants
│   ├── constants.dart           # App constants and colors
│   ├── theme.dart              # Theme configuration
│   └── widgets/                # Shared widgets
├── features/                    # Feature modules
│   ├── auth/                   # Authentication
│   │   ├── providers/          # Auth state management
│   │   └── screens/            # Login, signup, onboarding
│   ├── dashboard/              # Home dashboard
│   │   └── screens/            # Home screen
│   ├── meds/                   # Medication management
│   │   ├── models/             # Drug models
│   │   ├── providers/          # Meds state management
│   │   └── screens/            # Medication ordering
│   ├── care/                   # Care services
│   │   └── screens/            # Appointments, counseling
│   ├── chat/                   # Health chat
│   │   └── screens/            # Chat interface
│   ├── navigation/             # Bottom navigation
│   │   └── bottom_nav.dart     # Navigation controller
│   └── survey/                 # Health surveys
│       ├── providers/          # Survey state management
│       └── models/             # Survey models
└── services/                   # Core services
    └── local_storage_service.dart # Encrypted storage
```

## 🔐 Security & Privacy

CareShield prioritizes user privacy and data security:

- **End-to-End Encryption**: All sensitive data is encrypted locally
- **HIPAA Compliance**: Follows healthcare data protection standards
- **No Backend Dependencies**: All data stored locally for maximum privacy
- **Secure Authentication**: Encrypted user credentials and session management
- **Anonymous Usage**: No personal data transmitted to external servers

## 🏥 HIV Medications Supported

The app includes comprehensive HIV medication management for:

- **First-line ARVs**: Efavirenz, Tenofovir, Emtricitabine
- **Second-line Options**: Lopinavir, Ritonavir, Atazanavir
- **Prevention**: PrEP and PEP medications
- **Opportunistic Infections**: Cotrimoxazole, Fluconazole
- **Custom Combinations**: Personalized treatment regimens

## 🌍 Uganda Healthcare Integration

Designed specifically for the Ugandan healthcare system:

- **Free Medication Delivery**: Aligned with Uganda's free ARV program
- **Local Healthcare Providers**: Integration with registered facilities
- **Cultural Sensitivity**: Respectful of local customs and practices
- **Language Support**: English with potential for local language expansion
- **Offline Functionality**: Works without continuous internet connectivity

## 🤝 Contributing

We welcome contributions to improve CareShield:

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Commit changes** (`git commit -m 'Add amazing feature'`)
4. **Push to branch** (`git push origin feature/amazing-feature`)
5. **Open a Pull Request**

### Development Guidelines

- Follow Flutter/Dart style guidelines
- Write comprehensive tests for new features
- Update documentation for any API changes
- Ensure accessibility compliance
- Test on both Android and iOS platforms

## 🔧 Configuration

### Prototype Mode

CareShield runs in prototype mode with:
- **Demo Authentication**: Any credentials work for testing
- **Sample Data**: Pre-populated with realistic dummy data
- **Offline Operation**: No external API dependencies
- **Full Functionality**: All features accessible without backend

### Environment Setup

```yaml
# pubspec.yaml dependencies
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.5
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  crypto: ^3.0.3
  uuid: ^3.0.7
  flutter_secure_storage: ^9.0.0
```

<div align="center">
  <strong>CareShield - Your Health, Your Privacy, Your Care</strong>
  <br>
  <em>Empowering HIV patients with dignified, confidential healthcare access</em>
</div>
