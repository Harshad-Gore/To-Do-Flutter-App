# Installing TaskMaster on Your Phone

This guide will help you install the TaskMaster app on your Android or iOS device.

## Android Installation

### Option 1: Direct Installation via USB

1. **Enable USB debugging on your Android device:**
   - Go to Settings > About phone
   - Tap "Build number" 7 times to enable Developer options
   - Go back to Settings > System > Developer options
   - Enable "USB debugging"

2. **Connect your device via USB**
   - Connect your Android device to your computer using a USB cable
   - You may need to authorize your computer on your phone

3. **Build and install the app:**
   - Open a command prompt or terminal
   - Navigate to the project directory:
     ```
     cd "d:\Git repository\Android\first"
     ```
   - Run the following command:
     ```
     flutter install
     ```

### Option 2: Install Using an APK File

1. **Build an APK file:**
   - Open a command prompt or terminal
   - Navigate to the project directory:
     ```
     cd "d:\Git repository\Android\first"
     ```
   - Run the build command:
     ```
     flutter build apk
     ```
   - The APK will be created at:
     ```
     d:\Git repository\Android\first\build\app\outputs\flutter-apk\app-release.apk
     ```

2. **Transfer the APK to your device:**
   - Via email
   - Via cloud storage (Google Drive, Dropbox, etc.)
   - Via USB transfer

3. **Install the APK:**
   - Open the APK file on your device
   - If prompted, enable "Install from unknown sources" in your device settings
   - Follow the installation prompts

## iOS Installation

Installing on iOS requires a Mac with Xcode and an Apple Developer account.

1. **Build the iOS app:**
   - On a Mac computer:
     ```
     cd /path/to/project
     flutter build ios
     ```

2. **Open the project in Xcode:**
   - Open the iOS folder in Xcode:
     ```
     open ios/Runner.xcworkspace
     ```

3. **Connect your iOS device**

4. **Select your device as the build target and click Run**

## Troubleshooting

### Common Android Issues:

1. **USB debugging not working:**
   - Try a different USB cable
   - Try a different USB port
   - Restart both your computer and phone

2. **"Install failed" error:**
   - Check that you have enough storage on your device
   - Uninstall any previous version of the app
   - Make sure your phone's OS version is compatible

### Common iOS Issues:

1. **Code signing errors:**
   - Make sure you have a valid Apple Developer account
   - Check your team and provisioning profile settings in Xcode

2. **App won't install on device:**
   - Check that your device is trusted on your Mac
   - Verify that your iOS version is compatible with the app

If you encounter any other issues, please open an issue in the project repository.
