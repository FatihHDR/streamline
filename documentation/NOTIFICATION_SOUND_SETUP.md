# 🔊 Custom Notification Sound Setup

## 📁 File Placement

Your custom notification sound file needs to be placed in **TWO** locations:

### 1. Assets (for Flutter)
```
assets/sounds/notification_sound.mp3
```

### 2. Android Native Resources
```
android/app/src/main/res/raw/notification_sound.mp3
```

## 📝 File Requirements

### Format
- **Recommended:** MP3 or WAV
- **Alternative:** OGG, AAC

### Duration
- **Recommended:** 1-3 seconds
- **Maximum:** 5 seconds
- Too long = annoying for users!

### Size
- **Recommended:** < 500 KB
- **Maximum:** 1 MB

### Naming
- **MUST** be lowercase
- **MUST NOT** contain spaces
- **MUST NOT** contain special characters
- **Example:** `notification_sound.mp3` ✅
- **Invalid:** `Notification Sound!.mp3` ❌

## 🎵 Getting Sound Files

### Option 1: Free Sound Libraries

**1. Freesound.org**
- Visit: https://freesound.org/
- Search: "notification sound"
- Filter: Short sounds (1-3 seconds)
- Download and convert to MP3

**2. Zapsplat**
- Visit: https://www.zapsplat.com/
- Search: "notification"
- Free for personal/commercial use

**3. Notification Sounds**
- Visit: https://notificationsounds.com/
- Ready-to-use notification sounds

### Option 2: Create Your Own

**Using Audacity (Free):**
1. Download Audacity: https://www.audacityteam.org/
2. Generate > Tone (or record your own)
3. Effect > Fade In/Out
4. File > Export > MP3
5. Keep it under 3 seconds

**Using Online Tools:**
- https://www.soundtrap.com/ (online audio editor)
- https://online-audio-converter.com/ (format converter)

### Option 3: Use System Sounds

Extract from Android:
```bash
# Connect Android device
adb pull /system/media/audio/notifications/ ./android_sounds/

# Pick a sound you like
# Convert to MP3 if needed
```

## 📥 Installation Steps

### Step 1: Prepare Your Sound File

1. Make sure it meets requirements above
2. Rename to: `notification_sound.mp3`

### Step 2: Place in Assets

```bash
# From project root
mkdir -p assets/sounds
cp /path/to/your/notification_sound.mp3 assets/sounds/
```

### Step 3: Place in Android Raw Resources

```bash
# From project root
mkdir -p android/app/src/main/res/raw
cp /path/to/your/notification_sound.mp3 android/app/src/main/res/raw/
```

### Step 4: Verify pubspec.yaml

Make sure `pubspec.yaml` has:

```yaml
flutter:
  assets:
    - assets/sounds/notification_sound.mp3
```

### Step 5: Clean & Rebuild

```bash
flutter clean
flutter pub get
flutter run
```

## 🧪 Testing Your Sound

### Test 1: In App
1. Open app
2. Go to notifications screen
3. Tap menu (⋮) > "Test Notification"
4. ✅ You should hear your custom sound

### Test 2: Firebase Console
1. Send test notification from Firebase
2. ✅ Custom sound should play

### Test 3: Verify in Android Settings
1. Open Android Settings
2. Apps > Streamline > Notifications
3. Tap "Warehouse Notifications" channel
4. Check "Sound" setting
5. ✅ Should show custom sound, not "Default"

## 🐛 Troubleshooting

### Sound not playing?

**Check 1: File exists?**
```bash
# Check assets
ls assets/sounds/notification_sound.mp3

# Check Android raw
ls android/app/src/main/res/raw/notification_sound.mp3
```

**Check 2: File name correct?**
- Must be lowercase
- No spaces or special chars
- Exact match in code

**Check 3: Phone not on silent?**
- Check phone volume
- Disable Do Not Disturb
- Check notification volume specifically

**Check 4: Notification channel settings**
```dart
// In fcm_notification_service.dart
// Make sure this matches your file name:
sound: RawResourceAndroidNotificationSound('notification_sound'),
```

**Check 5: Rebuild app**
```bash
flutter clean
flutter pub get
flutter run
```

### Still using default sound?

1. **Uninstall and reinstall app:**
   ```bash
   flutter clean
   flutter run
   ```
   Android caches notification channel settings!

2. **Or clear app data:**
   - Android Settings > Apps > Streamline
   - Storage > Clear Data
   - Relaunch app

3. **Check logcat:**
   ```bash
   adb logcat | grep -i "notification\|sound"
   ```

## 🎨 Sound Recommendations for Warehouse App

### For Critical Alerts (Stok Habis)
- **Style:** Sharp, attention-grabbing
- **Example:** Short alarm beep
- **Duration:** 1-2 seconds

### For Warnings (Stok Menipis)
- **Style:** Gentle but noticeable
- **Example:** Soft chime
- **Duration:** 1-2 seconds

### For Info (Transaksi Baru)
- **Style:** Pleasant, non-intrusive
- **Example:** Soft ping
- **Duration:** 0.5-1 second

### For Reminders
- **Style:** Friendly notification
- **Example:** Bell or bubble sound
- **Duration:** 1-2 seconds

## 📚 References

- [Android Notification Sounds](https://developer.android.com/training/notify-user/channels#sound)
- [Flutter Local Notifications - Sounds](https://pub.dev/packages/flutter_local_notifications#-sounds)
- [Audio File Formats](https://developer.android.com/guide/topics/media/media-formats)

---

**Note:** Remember to test on multiple devices! Some phones may handle audio differently.

**Pro Tip:** Keep a backup of your sound file in version control or cloud storage!
