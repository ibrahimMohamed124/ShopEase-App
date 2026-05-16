# ShopEase Flutter (MVC)

This mobile app is now a Flutter project with an MVC-style structure:

- `lib/models`: app entities (`Product`, `Category`, `AppUser`, `CartItem`)
- `lib/services`: data + persistence services
- `lib/controllers`: app state and business logic
- `lib/views`: UI screens and widgets

## Run

1. Install dependencies:
   - `flutter pub get`
2. Run on Android:
   - `flutter run -d android`
3. Run on iOS (macOS + Xcode required):
   - `flutter run -d ios`

## Build

- Android APK: `flutter build apk`
- Android App Bundle: `flutter build appbundle`
- iOS (device build): `flutter build ios`
