# 📸 Camora - Camera & Accessories Shop

<div align="center">

![Camora Logo](assets/icons/camora%20icon%20300.png)

**Your Premium Camera & Accessories E-Commerce Platform**

[![Flutter](https://img.shields.io/badge/Flutter-3.8.0-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Integrated-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-Private-red.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-blue.svg)](https://flutter.dev)

[Features](#-features) • [Screenshots](#-screenshots) • [Getting Started](#-getting-started) • [Architecture](#-architecture) • [Contributing](#-contributing)

</div>

---

## 🌟 Overview

**Camora** is a modern, full-featured e-commerce mobile application built with Flutter, specializing in cameras and photography accessories. With a sleek UI, robust backend integration, and comprehensive e-commerce features, Camora provides an exceptional shopping experience for photography enthusiasts.

### ✨ Key Highlights

- 🎨 **Beautiful UI/UX** - Clean, modern interface with smooth animations
- 🔥 **Firebase Backend** - Real-time data synchronization with Cloud Firestore
- 💳 **Stripe Integration** - Secure payment processing
- 🛒 **Full E-Commerce** - Complete shopping cart, checkout, and order management
- 🔐 **Authentication** - Secure login/signup with Firebase Auth
- 💬 **Live Chat** - Real-time customer support chat
- 📱 **Cross-Platform** - Works on Android, iOS, and Web
- 🎯 **State Management** - Powered by GetX for reactive programming

---

## 🚀 Features

### 👤 User Features

#### 🛍️ Shopping Experience
- **Product Catalog** - Browse through a wide range of cameras and accessories
- **Advanced Search** - Find products quickly with search and filter options
- **Product Details** - High-quality images, detailed descriptions, and specifications
- **Categories** - Organized product categories for easy navigation
- **Wishlist** - Save favorite items for later

#### 🛒 Cart & Checkout
- **Shopping Cart** - Add, remove, and manage items with quantity controls
- **Real-time Updates** - Cart syncs across devices with Firebase
- **Multiple Payment Methods** - Stripe integration for secure payments
- **Order Tracking** - View order history and current order status
- **Shipping Management** - Save and manage multiple shipping addresses

#### 👤 Account Management
- **User Authentication** - Secure login/signup with email and password
- **Profile Management** - Update personal information and preferences
- **Order History** - View past orders and reorder easily
- **Payment Methods** - Securely store and manage payment cards

#### 💬 Communication
- **Live Chat Support** - Real-time chat with customer service
- **Order Notifications** - Stay updated on order status changes

### 🔧 Admin Features
- **Product Management** - Add, edit, and delete products
- **Category Management** - Organize products into categories
- **Order Management** - View and process customer orders
- **User Management** - Monitor and manage user accounts

---

## 📱 Screenshots

> Add your app screenshots here to showcase the UI

```
[Login Screen] [Home Screen] [Product Details] [Cart] [Checkout]
```

---

## 🛠️ Tech Stack

### Frontend
- **Flutter** - Cross-platform UI framework
- **Dart** - Programming language
- **GetX** - State management and navigation
- **Provider** - Additional state management

### Backend & Services
- **Firebase**
  - Firebase Auth - User authentication
  - Cloud Firestore - Real-time database
  - Firebase Storage - Image and file storage
- **Stripe** - Payment processing
- **Dio** - HTTP client for API calls

### Key Packages
- `image_picker` - Image selection from gallery/camera
- `cached_network_image` - Efficient image loading and caching
- `flutter_secure_storage` - Secure local storage for sensitive data
- `shared_preferences` - Local data persistence
- `shimmer` - Loading state animations
- `permission_handler` - Runtime permission management
- `intl` - Internationalization and date formatting

---

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.8.0 or higher)
- **Dart SDK** (included with Flutter)
- **Android Studio** or **Xcode** (for mobile development)
- **VS Code** (recommended) with Flutter extensions
- **Git** for version control
- **Firebase Account** for backend services
- **Stripe Account** for payment processing

---

## 🚀 Getting Started

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/Hews99vi/Camora-Mobile-app.git
cd Camora-Mobile-app
```

### 2️⃣ Install Dependencies

```bash
flutter pub get
```

### 3️⃣ Firebase Setup

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Add Android and/or iOS apps to your Firebase project
3. Download and place configuration files:
   - **Android**: `google-services.json` → `android/app/`
   - **iOS**: `GoogleService-Info.plist` → `ios/Runner/`
4. Run Firebase configuration:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

5. Enable Firebase services:
   - Authentication (Email/Password)
   - Cloud Firestore
   - Firebase Storage

### 4️⃣ Stripe Configuration

1. Create a [Stripe account](https://stripe.com)
2. Get your API keys from the Stripe Dashboard
3. Update `lib/config/app_config.dart` with your keys:

```dart
static const String stripePublishableKeyTest = 'pk_test_your_key_here';
static const String stripeSecretKeyTest = 'sk_test_your_key_here';
```

> ⚠️ **Security Note**: Never commit your secret keys to version control. Use environment variables for production.

### 5️⃣ Run the App

```bash
# Check for issues
flutter doctor

# Run on connected device
flutter run

# Build for release
flutter build apk --release  # Android
flutter build ios --release  # iOS
flutter build web --release  # Web
```

---

## 📂 Project Structure

```
lib/
├── main.dart                    # App entry point
├── firebase_options.dart        # Firebase configuration
├── config/
│   └── app_config.dart         # App-wide configuration
├── controllers/                 # Business logic (GetX)
│   ├── auth_controller.dart
│   ├── cart_controller.dart
│   ├── product_controller.dart
│   ├── order_controller.dart
│   ├── category_controller.dart
│   └── chat_controller.dart
├── models/                      # Data models
│   ├── user.dart
│   ├── product.dart
│   ├── cart_item.dart
│   ├── order.dart
│   └── chat_message.dart
├── screens/                     # UI screens
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── product_details_screen.dart
│   ├── cart_screen.dart
│   ├── checkout_screen.dart
│   ├── profile_screen.dart
│   └── admin/                  # Admin-specific screens
├── services/                    # External services
│   ├── firebase_auth_service.dart
│   └── stripe_service.dart
├── utils/                       # Utilities and helpers
│   ├── theme.dart
│   └── logger.dart
└── widgets/                     # Reusable widgets
    └── network_image.dart
```

---

## 🏗️ Architecture

The app follows a **clean architecture** pattern with clear separation of concerns:

### State Management
- **GetX** for reactive state management
- **Controllers** handle business logic
- **Models** define data structures
- **Services** manage external integrations

### Data Flow
```
UI (Screens/Widgets)
    ↓
Controllers (Business Logic)
    ↓
Services (Firebase, Stripe, etc.)
    ↓
Models (Data Structures)
```

### Key Design Patterns
- **MVC** (Model-View-Controller)
- **Repository Pattern** for data access
- **Singleton** for service instances
- **Observer Pattern** via GetX reactive programming

---

## 🔒 Security & Best Practices

- 🔐 **Secure Storage** - Sensitive data encrypted with `flutter_secure_storage`
- 🛡️ **Firebase Rules** - Firestore security rules in `firestore.rules`
- 🔑 **Authentication** - Firebase Auth with email/password
- 💳 **PCI Compliance** - Stripe handles all payment data securely
- 🚫 **Never commit** API keys or secrets to version control
- ✅ **Input Validation** - All user inputs are validated
- 🔄 **Error Handling** - Comprehensive error handling throughout the app

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Integration tests
flutter drive --target=test_driver/app.dart
```

---

## 📦 Building for Production

### Android

```bash
# Create release APK
flutter build apk --release

# Create App Bundle (recommended for Play Store)
flutter build appbundle --release
```

### iOS

```bash
# Create release IPA
flutter build ios --release
```

### Web

```bash
# Build for web
flutter build web --release
```

---

## 🐛 Troubleshooting

### Common Issues

**Firebase initialization fails:**
```bash
flutterfire configure
flutter clean
flutter pub get
```

**Build fails on Android:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

**Stripe not working:**
- Verify your API keys in `app_config.dart`
- Check that you're using test keys in development
- Ensure Stripe is initialized in `main.dart`

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style
- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add comments for complex logic
- Write tests for new features

---

## 📄 License

This project is private and proprietary. All rights reserved.

---

## 👥 Team

- **Developer**: [Hews99vi](https://github.com/Hews99vi)
- **Repository**: [Camora-Mobile-app](https://github.com/Hews99vi/Camora-Mobile-app)

---

## 📞 Support

For questions, issues, or suggestions:

- 📧 Email: support@camora.com
- 🐛 Issues: [GitHub Issues](https://github.com/Hews99vi/Camora-Mobile-app/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/Hews99vi/Camora-Mobile-app/discussions)

---

## 🗺️ Roadmap

### Upcoming Features
- [ ] Social login (Google, Facebook, Apple)
- [ ] Push notifications
- [ ] Advanced product filtering
- [ ] Product reviews and ratings
- [ ] Wishlist sharing
- [ ] Multi-language support
- [ ] Dark mode
- [ ] Augmented Reality product preview
- [ ] Voice search
- [ ] Product recommendations AI

---

## 📊 Version History

### v1.0.0 (Current)
- ✅ Initial release
- ✅ User authentication
- ✅ Product catalog
- ✅ Shopping cart
- ✅ Checkout & payment
- ✅ Order management
- ✅ Live chat support
- ✅ Admin panel

---

## 🙏 Acknowledgments

- [Flutter Team](https://flutter.dev) for the amazing framework
- [Firebase](https://firebase.google.com) for backend services
- [Stripe](https://stripe.com) for payment processing
- All open-source contributors

---

<div align="center">

**⭐ Star this repository if you find it helpful!**

Made with ❤️ using Flutter

[⬆ Back to Top](#-camora---camera--accessories-shop)

</div>
