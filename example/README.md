# drawer_rail example

A small app demonstrating [`drawer_rail`](https://pub.dev/packages/drawer_rail):

- A header logo, a dark-mode footer toggle, badges and an expandable group.
- A button to switch between the **default left drawer** and a **fully
  customized right-side drawer** (green accent, wider layout, flipped chevrons,
  non-uppercase sections).

## Run it

From this `example/` directory:

```bash
flutter pub get

# In a browser (best for seeing the wide sidebar):
flutter run -d chrome

# Or on Windows desktop:
flutter run -d windows

# Or on a connected Android device / emulator:
flutter run
```

If a target platform folder is missing, generate it once:

```bash
flutter create --platforms=windows,web,android .
```
