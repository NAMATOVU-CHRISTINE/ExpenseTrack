# Android Studio Setup Instructions for Expense Tracker

## Step 1: Create New Android Project
1. Open Android Studio
2. Click "Create New Project"
3. Select "Empty Activity"
4. Set:
   - Name: `Expense Tracker`
   - Package name: `com.expensetracker.app`
   - Language: `Java`
   - Minimum SDK: `API 21 (Android 5.0)`

## Step 2: Add Dependencies
Add these to your `app/build.gradle` file:

```gradle
dependencies {
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.10.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
    implementation 'androidx.coordinatorlayout:coordinatorlayout:1.2.0'
    
    // Retrofit for API calls
    implementation 'com.squareup.retrofit2:retrofit:2.9.0'
    implementation 'com.squareup.retrofit2:converter-gson:2.9.0'
    implementation 'com.squareup.okhttp3:logging-interceptor:4.11.0'
    
    // Charts
    implementation 'com.github.PhilJay:MPAndroidChart:v3.1.0'
    
    // Image loading
    implementation 'com.github.bumptech.glide:glide:4.15.1'
    
    // RecyclerView
    implementation 'androidx.recyclerview:recyclerview:1.3.2'
}
```

## Step 3: Add Internet Permission
Add to `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

## Step 4: Update Django Backend for API
Add these to your Django project:

### 4.1 Install Django REST Framework
```bash
pip install djangorestframework
pip install django-cors-headers
```

### 4.2 Update settings.py
```python
INSTALLED_APPS = [
    # ... existing apps
    'rest_framework',
    'corsheaders',
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    # ... existing middleware
]

# Allow all origins for development
CORS_ALLOW_ALL_ORIGINS = True

REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.TokenAuthentication',
    ],
}
```

## Step 5: Copy Android Files
1. Copy all Java files from `android_app/` to your `app/src/main/java/com/expensetracker/app/`
2. Copy XML layouts to `app/src/main/res/layout/`
3. Add required drawable resources and colors

## Step 6: Update API Base URL
In `ApiClient.java`, change the BASE_URL to your computer's IP:
```java
private static final String BASE_URL = "http://YOUR_IP_ADDRESS:8000/";
```

## Step 7: Create Django API Views
You'll need to create API endpoints in Django for:
- Authentication (login/register)
- Expenses CRUD
- Categories
- Financial data
- Reports

## Step 8: Run Both Servers
1. Start Django: `python manage.py runserver 0.0.0.0:8000`
2. Run Android app in emulator or device
3. Make sure both are on the same network

## Features Included:
✅ Login/Signup screens
✅ Dashboard with charts
✅ Expense management
✅ Category-based organization
✅ Material Design UI
✅ API integration ready

## Next Steps:
1. Add remaining activities (AddExpense, Budgets, Reports)
2. Implement proper error handling
3. Add offline support with Room database
4. Add push notifications
5. Implement receipt scanning with camera

The Android app will communicate with your Django backend via REST API calls, giving you a native mobile experience for your expense tracker!