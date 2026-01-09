#!/bin/bash

# Digital Signage App - Quick Start Script

echo "🚀 Digital Signage App Setup"
echo "=============================="
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null
then
    echo "❌ Flutter is not installed. Please install Flutter first."
    echo "Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter detected: $(flutter --version | head -n 1)"
echo ""

# Check Flutter doctor
echo "📋 Running Flutter Doctor..."
flutter doctor
echo ""

# Get dependencies
echo "📦 Installing dependencies..."
flutter pub get
echo ""

# Check for Firebase configuration
if [ ! -f "lib/firebase_options.dart" ]; then
    echo "⚠️  Firebase not configured yet!"
    echo ""
    echo "Please run the following commands to configure Firebase:"
    echo "  1. npm install -g firebase-tools"
    echo "  2. firebase login"
    echo "  3. dart pub global activate flutterfire_cli"
    echo "  4. flutterfire configure"
    echo ""
    read -p "Have you configured Firebase? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        echo "Please configure Firebase first. See SETUP.md for details."
        exit 1
    fi
fi

echo "✅ Firebase configuration found"
echo ""

# Ask which platform to run
echo "Select platform to run:"
echo "  1) Android"
echo "  2) iOS"
echo "  3) Web (Chrome)"
echo "  4) List devices"
echo ""
read -p "Enter choice (1-4): " choice

case $choice in
    1)
        echo "🤖 Running on Android..."
        flutter run
        ;;
    2)
        echo "🍎 Running on iOS..."
        flutter run -d ios
        ;;
    3)
        echo "🌐 Running on Web (Chrome)..."
        flutter run -d chrome
        ;;
    4)
        echo "📱 Available devices:"
        flutter devices
        ;;
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac
