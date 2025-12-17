# Android Studio Project Structure for Expense Tracker

## Project Setup
1. Create new Android project in Android Studio
2. Choose "Empty Activity" 
3. Set minimum SDK to API 21 (Android 5.0)
4. Language: Java or Kotlin

## Required Dependencies (build.gradle)
```gradle
dependencies {
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.10.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
    
    // For HTTP requests
    implementation 'com.squareup.retrofit2:retrofit:2.9.0'
    implementation 'com.squareup.retrofit2:converter-gson:2.9.0'
    implementation 'com.squareup.okhttp3:logging-interceptor:4.11.0'
    
    // For charts
    implementation 'com.github.PhilJay:MPAndroidChart:v3.1.0'
    
    // For image loading
    implementation 'com.github.bumptech.glide:glide:4.15.1'
    
    // For date picker
    implementation 'com.wdullaer:materialdatetimepicker:4.2.3'
}
```