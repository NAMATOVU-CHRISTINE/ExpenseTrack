#!/bin/bash

# Android App Build Script for Expense Tracker
echo "🚀 Setting up Android Expense Tracker App..."

# Check if Android Studio is installed
if ! command -v android &> /dev/null; then
    echo "❌ Android Studio/SDK not found. Please install Android Studio first."
    echo "Download from: https://developer.android.com/studio"
    exit 1
fi

# Create project directory structure
echo "📁 Creating project structure..."
mkdir -p ExpenseTrackerAndroid/app/src/main/java/com/expensetracker/app
mkdir -p ExpenseTrackerAndroid/app/src/main/res/layout
mkdir -p ExpenseTrackerAndroid/app/src/main/res/values
mkdir -p ExpenseTrackerAndroid/app/src/main/res/drawable

# Copy Java files
echo "📋 Copying Java source files..."
cp android_app/*.java ExpenseTrackerAndroid/app/src/main/java/com/expensetracker/app/
cp android_app/models/*.java ExpenseTrackerAndroid/app/src/main/java/com/expensetracker/app/

# Copy layout files
echo "🎨 Copying layout files..."
cp android_app/layouts/*.xml ExpenseTrackerAndroid/app/src/main/res/layout/

echo "✅ Android project structure created!"
echo "📱 Next steps:"
echo "1. Open Android Studio"
echo "2. Import the ExpenseTrackerAndroid project"
echo "3. Sync Gradle files"
echo "4. Update API URL in ApiClient.java"
echo "5. Build and run!"