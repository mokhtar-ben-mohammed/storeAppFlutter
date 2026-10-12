# Google Maps API key (addresses)

Do **not** commit API keys.

## Android

In `android/local.properties` add:

```properties
GOOGLE_MAPS_API_KEY=your_key_here
```

`AndroidManifest` reads it via Gradle `manifestPlaceholders`.

## iOS

Set build setting / scheme env `GOOGLE_MAPS_API_KEY`, or replace `$(GOOGLE_MAPS_API_KEY)` in `Info.plist` locally (keep secrets out of git).
