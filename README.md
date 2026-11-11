# 🏨 HotelConnect – Flutter Hotel Management App

A mobile Flutter application that lets hotel guests manage their entire stay: room booking, room service, activities, real-time invoicing, and complaints.

---

## 📱 Overview

**HotelConnect** is a mobile application developed as part of the **Mobile Development** practical exam.

The app solves the problem of scattered hotel services by centralizing:
- Room booking (with real-time availability)
- Room service
- Activities & events (with capacity management)
- Real-time invoicing (consolidated view)
- Guest complaints

**Target audience:** Hotel guests during their stay.

---

## ⚙️ Environment

| Item | Version |
| :--- | :--- |
| **Flutter SDK** | 3.24.0 or higher |
| **Dart** | 3.5.0 or higher |
| **OS** | Windows / macOS / Linux |
| **Recommended IDE** | Android Studio or VS Code |
| **Test device** | Android Emulator (API 34) or physical phone |

### Main dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  animate_do: ^3.3.4        # Animations (fade, slide)
  google_fonts: ^6.2.1      # Custom fonts (Poppins, aBeeZee)
  shared_preferences: ^2.3.2 # Local persistence (accounts, sessions, bookings)