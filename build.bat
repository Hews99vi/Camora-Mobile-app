@echo off
REM Build script for Camora Mobile App (Windows)
REM This script handles platform-specific builds

echo Camora Build Script
echo ====================

REM Get the platform argument
set PLATFORM=%1
if "%PLATFORM%"=="" set PLATFORM=android

if "%PLATFORM%"=="web" (
    echo Building for Web...
    echo Note: TensorFlow Lite will be disabled for web platform
    
    REM Clean previous builds
    flutter clean
    flutter pub get
    
    REM Build for web with additional optimizations
    flutter build web --release
    
    echo Web build completed successfully!
    echo Output: build\web\
) else if "%PLATFORM%"=="android" (
    echo Building for Android...
    echo TensorFlow Lite will be included for Android platform
    
    REM Clean previous builds
    flutter clean
    flutter pub get
    
    REM Build for Android
    flutter build apk --release
    
    echo Android build completed successfully!
    echo Output: build\app\outputs\flutter-apk\app-release.apk
) else if "%PLATFORM%"=="ios" (
    echo Building for iOS...
    echo TensorFlow Lite will be included for iOS platform
    
    REM Clean previous builds
    flutter clean
    flutter pub get
    
    REM Build for iOS
    flutter build ios --release
    
    echo iOS build completed successfully!
    echo Output: build\ios\iphoneos\Runner.app
) else (
    echo Usage: %0 [web^|android^|ios]
    echo Default: android
    exit /b 1
)