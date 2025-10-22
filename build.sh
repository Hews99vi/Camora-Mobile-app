#!/bin/bash

# Build script for Camora Mobile App
# This script handles platform-specific builds

set -e

echo "Camora Build Script"
echo "===================="

# Get the platform argument
PLATFORM=${1:-"android"}

case $PLATFORM in
  "web")
    echo "Building for Web..."
    echo "Note: TensorFlow Lite will be disabled for web platform"
    
    # Clean previous builds
    flutter clean
    flutter pub get
    
    # Build for web with additional optimizations
    flutter build web --release
    
    echo "Web build completed successfully!"
    echo "Output: build/web/"
    ;;
    
  "android")
    echo "Building for Android..."
    echo "TensorFlow Lite will be included for Android platform"
    
    # Clean previous builds
    flutter clean
    flutter pub get
    
    # Build for Android
    flutter build apk --release
    
    echo "Android build completed successfully!"
    echo "Output: build/app/outputs/flutter-apk/app-release.apk"
    ;;
    
  "ios")
    echo "Building for iOS..."
    echo "TensorFlow Lite will be included for iOS platform"
    
    # Clean previous builds
    flutter clean
    flutter pub get
    
    # Build for iOS
    flutter build ios --release
    
    echo "iOS build completed successfully!"
    echo "Output: build/ios/iphoneos/Runner.app"
    ;;
    
  *)
    echo "Usage: $0 [web|android|ios]"
    echo "Default: android"
    exit 1
    ;;
esac