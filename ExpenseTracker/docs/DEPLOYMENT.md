# Deployment Guide

## Android

### Debug APK

```bash
flutter build apk --debug
```

Output: `build/app/outputs/flutter-apk/app-debug.apk`

### Release APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### App Bundle (Play Store)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

## iOS

### Build for iOS

```bash
flutter build ios --release
```

### Archive for App Store

Open in Xcode and use Product > Archive.

## Signing

### Android

1. Generate keystore:
```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. Create `android/key.properties`:
```
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path>/upload-keystore.jks
```

3. Update `android/app/build.gradle` to use the keystore.

### iOS

Configure signing in Xcode with your Apple Developer account.

## Version Bumping

Update version in `pubspec.yaml`:
```yaml
version: 1.0.1+2
```

Format: `major.minor.patch+buildNumber`
