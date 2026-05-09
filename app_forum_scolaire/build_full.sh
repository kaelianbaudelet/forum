#!/bin/bash

# Script to build Android app and move it to assets for the web landing page

echo "🚀 Starting full build process..."

# 1. Build Android APK
echo "🤖 Building Android APK..."
flutter build apk --release
if [ $? -eq 0 ]; then
    cp build/app/outputs/flutter-apk/app-release.apk assets/app-release.apk
    echo "✅ APK copied to assets/app-release.apk"
else
    echo "❌ APK build failed"
fi

# 2. Build Web
echo "🌐 Building Web..."
flutter build web --release
if [ $? -eq 0 ]; then
    echo "✅ Web build completed"
    echo "🚀 Full build finished! You can now run 'npx serve build/web'"
else
    echo "❌ Web build failed"
fi
