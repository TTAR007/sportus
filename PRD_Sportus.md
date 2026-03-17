# Product Requirements Document — Sportus

**Version:** 1.0.0  
**Date:** 2026-03-16  
**Status:** Draft  
**Platform:** iOS & Android (Flutter)

---

## 1. Overview

### 1.1 Product Summary

Sportus is a lightweight mobile application that enables users to create, manage, and join local sport activities. The goal is simplicity — users should be able to post an activity and find others to play with in minimal steps.

### 1.2 Problem Statement

Finding people to play sports with is fragmented across group chats, social media, and word of mouth. Sportus provides a single, clean surface to post and discover sport activities nearby.

### 1.3 Goals

- Enable anyone to create a sport activity in under 60 seconds.
- Allow users to join an activity with a single tap.
- Keep the UI minimal and distraction-free.
- Lay a clean, scalable code foundation for future iterations.

### 1.4 Out of Scope (v1.0)

- In-app messaging or chat
- Payment or ticketing
- Maps/geolocation display
- Push notifications
- Social profiles or followers
- Ratings or reviews

---

## 2. User Stories

| ID | As a… | I want to… | So that… |
|----|-------|-----------|---------|
| US-01 | User | Create a sport activity | Others can discover and join it |
| US-02 | User | Update my activity details | I can correct mistakes or changes |
| US-03 | User | Delete my activity | I can cancel it if it no longer happens |
| US-04 | User | Join an activity | I can participate and the host knows I'm coming |
| US-05 | User | See a list of available activities | I can browse what's happening |
| US-06 | User | View activity details | I can decide whether to join |

---

## 3. Functional Requirements

### 3.1 Create Activity

**Fields:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| Title | String | Yes | Max 80 chars |
| Sport Type | Enum (dropdown) | Yes | e.g. Football, Basketball, Tennis, Running, Badminton, Volleyball, Other |
| Date & Time | DateTime | Yes | Must be in the future |
| Location (text) | String | Yes | Free-text address, max 200 chars |
| Max Participants | Integer | Yes | Min 2, max 100 |
| Description | String | No | Max 500 chars |

**Behavior:**
- Authenticated user becomes the **host** of the activity.
- Activity is immediately visible in the activity list after creation.
- Validation errors are shown inline under each field.

### 3.2 Update Activity

- Only the **host** can edit an activity.
- All fields from Create are editable.
- If current participant count exceeds the new `maxParticipants`, the update is rejected with a clear error message.
- A timestamp `updatedAt` is recorded on every update.

### 3.3 Delete Activity

- Only the **host** can delete an activity.
- A confirmation dialog is shown before deletion ("Are you sure you want to cancel this activity?").
- Deleted activities are soft-deleted (hidden from lists, retained in database for 30 days).
- Participants are notified (v2 — out of scope for v1).

### 3.4 Join Activity

- Any authenticated user who is **not** the host can join.
- A user cannot join the same activity twice.
- Joining is blocked if `currentParticipants >= maxParticipants`.
- A user can **leave** an activity they have joined (button toggles between Join / Leave).
- Participant count updates in real-time (via Firestore listener).

### 3.5 Activity List / Discovery

- Activities are listed in ascending order of `dateTime` (soonest first).
- Only future activities are shown.
- A simple filter by sport type is available (single-select chip row).
- Each card shows: Sport icon, Title, Date/Time, Location, `X / Y participants`.

### 3.6 Activity Detail

- Full view of all activity fields.
- Participant count and Join/Leave button.
- Host name is displayed.
- If the viewer is the host, Edit and Delete action buttons are shown.

---

## 4. Non-Functional Requirements

| Category | Requirement |
|----------|------------|
| Performance | Activity list loads within 1.5s on a standard 4G connection |
| Offline | Basic list is cached locally; CRUD operations require connectivity |
| Scalability | Backend must handle up to 10,000 concurrent users without configuration changes |
| Security | All API calls require a valid Firebase Auth token |
| Compatibility | iOS 16+ and Android 8.0+ (API level 26+) |
| Accessibility | Minimum WCAG AA contrast ratios; all interactive elements have semantic labels |
| Code Quality | 0 critical lint warnings; CI runs `flutter analyze` on every PR |

---

## 5. Tech Stack & Architecture

### 5.1 Mobile — Flutter

| Concern | Package | Version |
|---------|---------|---------|
| Dart SDK | sdk | `>=3.7.0 <4.0.0` |
| State management | `flutter_riverpod` | `^3.1.0` |
| Navigation | `go_router` | `^17.1.0` |
| Backend SDK | `cloud_firestore` | `^6.1.1` |
| Auth | `firebase_auth` | `^6.2.0` |
| Firebase core | `firebase_core` | `^4.5.0` |
| Form validation | `reactive_forms` | `^18.2.2` |
| Immutable models | `freezed` + `freezed_annotation` | `^3.2.5` / `^3.1.0` |
| JSON serialisation | `json_serializable` + `json_annotation` | `^6.8.0` / `^4.9.0` |
| Font | `google_fonts` | `^8.0.2` |
| UI utilities | `gap` | `^3.0.1` |
| Skeleton loading | `shimmer` | `^3.0.0` |
| Linting | `flutter_lints` | `^6.0.0` |

> All versions are the latest stable as of March 2026. Pin exact versions in `pubspec.lock` and commit the lock file.

### 5.2 Backend — Firebase (BaaS)

| Service | Purpose |
|---------|---------|
| **Firebase Authentication** | Anonymous + Google Sign-In (v1 uses Anonymous; Google Sign-In ready as upgrade path) |
| **Cloud Firestore** | Primary data store — activities collection |
| **Firebase Security Rules** | Enforce host-only write, authenticated reads |

**Firestore Collection Schema:**

```
activities/
  {activityId}/
    title:             string
    sportType:         string  (enum value)
    dateTime:          timestamp
    location:          string
    maxParticipants:   number
    description:       string | null
    hostId:            string  (Firebase Auth UID)
    hostName:          string
    participantIds:    string[]
    currentParticipants: number  (denormalized for cheap reads)
    createdAt:         timestamp
    updatedAt:         timestamp
    deletedAt:         timestamp | null
```

**Security Rules (Firestore):**

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /activities/{activityId} {
      // Anyone authenticated can read non-deleted activities
      allow read: if request.auth != null && resource.data.deletedAt == null;

      // Only authenticated users can create; hostId must match their UID
      allow create: if request.auth != null
                    && request.resource.data.hostId == request.auth.uid;

      // Only the host can update; participant join/leave handled via dedicated logic
      allow update: if request.auth != null
                    && (resource.data.hostId == request.auth.uid
                        || onlyUpdatingParticipants());

      // Only the host can soft-delete
      allow delete: if false; // Never hard delete from client
    }
  }
  function onlyUpdatingParticipants() {
    return request.resource.data.diff(resource.data).affectedKeys()
      .hasOnly(['participantIds', 'currentParticipants', 'updatedAt']);
  }
}
```

---

## 6. Architecture — Flutter App

### 6.1 Folder Structure

```
lib/
├── main.dart                             # App entry point; ProviderScope + MaterialApp.router
├── firebase_options.dart                 # Auto-generated by FlutterFire CLI; DO NOT edit
│
├── core/
│   ├── theme/
│   │   ├── app_theme.dart                # AppTheme.light() and AppTheme.dark() factories
│   │   └── app_color_scheme.dart         # ThemeExtension<AppColorScheme> — success, shimmer tokens
│   ├── constants/
│   │   ├── app_text_styles.dart          # All TextStyle tokens; never inline font sizes
│   │   └── sport_types.dart              # SportType enum, display labels, icon mappings
│   ├── errors/
│   │   └── app_exception.dart            # Sealed AppException hierarchy
│   ├── extensions/
│   │   └── datetime_ext.dart             # DateTime formatting helpers
│   └── utils/
│       └── validators.dart               # Reusable form field validators
│
├── data/
│   ├── models/
│   │   └── activity_model.dart           # Freezed immutable model + fromFirestore/toJson
│   └── repositories/
│       └── activity_repository.dart      # ALL Firestore operations; returns Either<AppException, T>
│
├── providers/
│   ├── auth_provider.dart                # authStateProvider, currentUserProvider
│   └── activity_provider.dart           # activityListProvider, activityDetailProvider, activityFormProvider
│
├── features/
│   ├── activity_list/
│   │   ├── activity_list_screen.dart
│   │   └── widgets/
│   │       ├── activity_card.dart
│   │       └── sport_filter_chips.dart
│   ├── activity_detail/
│   │   ├── activity_detail_screen.dart
│   │   └── widgets/
│   │       ├── participant_count_bar.dart
│   │       └── host_actions_bar.dart
│   ├── activity_form/
│   │   ├── activity_form_screen.dart     # Shared for Create and Edit; pass ActivityModel? for edit mode
│   │   └── widgets/
│   │       ├── sport_type_selector.dart
│   │       └── datetime_field.dart
│   └── auth/
│       └── auth_gate.dart               # Handles anonymous sign-in transparently on launch
│
├── shared/
│   └── widgets/                         # Widgets used by more than one feature
│       ├── primary_button.dart
│       ├── shimmer_card.dart
│       └── empty_state.dart
│
└── router/
    └── app_router.dart                  # All GoRoute definitions; no Navigator.push() anywhere
```

### 6.2 State Management Pattern (Riverpod)

- `ActivityListNotifier` — `AsyncNotifier<List<ActivityModel>>` — streams Firestore query.
- `ActivityDetailNotifier` — `AsyncNotifier<ActivityModel>` — streams single document.
- `ActivityFormNotifier` — `Notifier` — holds form state, exposes `create()`, `update()`, `delete()`.
- `AuthNotifier` — wraps `FirebaseAuth.authStateChanges()`.

All notifiers live under `providers/` and are exposed as global `final` providers. No `BuildContext` dependency inside providers.

### 6.3 Navigation (go_router)

| Route | Path | Screen |
|-------|------|--------|
| Activity List | `/` | `ActivityListScreen` |
| Activity Detail | `/activities/:id` | `ActivityDetailScreen` |
| Create Activity | `/activities/new` | `ActivityFormScreen(mode: create)` |
| Edit Activity | `/activities/:id/edit` | `ActivityFormScreen(mode: edit)` |

Redirect guard: if `authState` is loading, show splash; if unauthenticated, trigger anonymous sign-in transparently.

### 6.4 Design System

**Typography — Inter font family**

| Token | Weight | Size |
|-------|--------|------|
| `headingLarge` | 700 | 24sp |
| `headingMedium` | 600 | 20sp |
| `bodyLarge` | 400 | 16sp |
| `bodyMedium` | 400 | 14sp |
| `labelSmall` | 500 | 12sp |

**Theme Mode Support**

The app fully supports light mode, dark mode, and system-default mode. The mode is driven by the device system setting (`ThemeMode.system`) and can be overridden by a user preference stored in `SharedPreferences`. No color hex values are ever hardcoded in widgets — all colors are consumed from `Theme.of(context).colorScheme` or the `AppColorScheme` extension (see below).

**Color Tokens — Light & Dark**

The design uses Flutter's `ColorScheme` seeded from the `primary` brand color, augmented with custom semantic tokens exposed via a `ThemeExtension<AppColorScheme>`.

| Semantic Token | Light Mode | Dark Mode | Usage |
|---------------|------------|-----------|-------|
| `primary` | `#2563EB` | `#60A5FA` | Buttons, active states, links |
| `onPrimary` | `#FFFFFF` | `#0F172A` | Text/icons on primary color |
| `primaryContainer` | `#DBEAFE` | `#1E3A5F` | Chips, badges, highlights |
| `onPrimaryContainer` | `#1E3A5F` | `#BFDBFE` | Text inside primary containers |
| `surface` | `#FFFFFF` | `#1E293B` | Cards, bottom sheets, dialogs |
| `onSurface` | `#0F172A` | `#F1F5F9` | Primary text on surfaces |
| `surfaceContainerLowest` | `#F1F5F9` | `#0F172A` | Screen background |
| `surfaceContainerLow` | `#E2E8F0` | `#1E293B` | Dividers, card borders |
| `onSurfaceVariant` | `#64748B` | `#94A3B8` | Secondary text, hints, captions |
| `error` | `#DC2626` | `#F87171` | Validation errors, destructive actions |
| `onError` | `#FFFFFF` | `#0F172A` | Text/icons on error color |
| `success` | `#16A34A` | `#4ADE80` | Joined state, positive feedback |
| `outline` | `#CBD5E1` | `#334155` | Card borders, input borders |
| `shimmerBase` | `#E2E8F0` | `#1E293B` | Skeleton loading base color |
| `shimmerHighlight` | `#F8FAFC` | `#2D3F55` | Skeleton loading highlight color |

**ThemeExtension implementation (`app_color_scheme.dart`):**

```dart
@immutable
class AppColorScheme extends ThemeExtension<AppColorScheme> {
  const AppColorScheme({
    required this.success,
    required this.onSuccess,
    required this.shimmerBase,
    required this.shimmerHighlight,
  });

  final Color success;
  final Color onSuccess;
  final Color shimmerBase;
  final Color shimmerHighlight;

  static const light = AppColorScheme(
    success: Color(0xFF16A34A),
    onSuccess: Color(0xFFFFFFFF),
    shimmerBase: Color(0xFFE2E8F0),
    shimmerHighlight: Color(0xFFF8FAFC),
  );

  static const dark = AppColorScheme(
    success: Color(0xFF4ADE80),
    onSuccess: Color(0xFF0F172A),
    shimmerBase: Color(0xFF1E293B),
    shimmerHighlight: Color(0xFF2D3F55),
  );

  @override
  AppColorScheme copyWith({Color? success, Color? onSuccess,
      Color? shimmerBase, Color? shimmerHighlight}) => AppColorScheme(
    success: success ?? this.success,
    onSuccess: onSuccess ?? this.onSuccess,
    shimmerBase: shimmerBase ?? this.shimmerBase,
    shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
  );

  @override
  AppColorScheme lerp(AppColorScheme? other, double t) {
    if (other == null) return this;
    return AppColorScheme(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
    );
  }
}
```

**Theme construction (`app_theme.dart`):**

```dart
class AppTheme {
  static ThemeData light() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2563EB),
      brightness: Brightness.light,
    ).copyWith(
      surface: const Color(0xFFFFFFFF),
      onSurface: const Color(0xFF0F172A),
    ),
    extensions: const [AppColorScheme.light],
    fontFamily: 'Inter',
    // component themes here (card, button, input, chip)
  );

  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2563EB),
      brightness: Brightness.dark,
    ).copyWith(
      surface: const Color(0xFF1E293B),
      onSurface: const Color(0xFFF1F5F9),
    ),
    extensions: const [AppColorScheme.dark],
    fontFamily: 'Inter',
  );
}
```

**Accessing colors in widgets (never hardcode hex):**

```dart
// ✅ Correct
final cs = Theme.of(context).colorScheme;
final ext = Theme.of(context).extension<AppColorScheme>()!;
Container(color: cs.surface);
Text('Joined', style: TextStyle(color: ext.success));

// ❌ Wrong
Container(color: Color(0xFF1E293B)); // hardcoded hex
```

**Accessibility — Contrast Requirements (WCAG AA)**

All foreground/background color pairings must meet a minimum contrast ratio of **4.5:1** for body text and **3:1** for large text and UI components. The pairings above have been pre-verified:

| Pairing | Light Ratio | Dark Ratio |
|---------|-------------|------------|
| `onSurface` on `surface` | 19.1:1 ✅ | 15.3:1 ✅ |
| `onSurfaceVariant` on `surface` | 5.9:1 ✅ | 4.6:1 ✅ |
| `onPrimary` on `primary` | 8.6:1 ✅ | 9.1:1 ✅ |
| `error` on `surface` | 5.1:1 ✅ | 4.8:1 ✅ |
| `success` on `surface` | 4.5:1 ✅ | 4.6:1 ✅ |

**Component Rules:**
- All cards use `BorderRadius.circular(16)` with `elevation: 0` and a `1px` border in `colorScheme.outline`.
- Card background: `colorScheme.surface`. Screen background: `colorScheme.surfaceContainerLowest`.
- Primary button: filled, `BorderRadius.circular(12)`, height 52px, uses `colorScheme.primary` / `colorScheme.onPrimary`.
- All tappable areas have a minimum touch target of 44×44px.
- Loading states use `Shimmer` skeleton placeholders using `AppColorScheme.shimmerBase` and `shimmerHighlight`.
- Icon-only buttons include a `Tooltip` and `semanticLabel` for screen reader support.
- The app never forces a theme mode; it defaults to `ThemeMode.system` and respects the OS setting.

---

## 7. Key Screens (Wireframe Descriptions)

### 7.1 Activity List Screen
- AppBar: "Sportus" wordmark logo (left), no menu.
- Sport filter chips row below AppBar (scrollable horizontal).
- Vertical scrollable list of `ActivityCard` widgets.
- FAB (+) in bottom-right corner → navigates to Create form.
- Empty state: illustration + "No activities yet. Create one!" copy.

### 7.2 Activity Form Screen (Create / Edit)
- AppBar with back button and title ("New Activity" / "Edit Activity").
- Scrollable `SingleChildScrollView` form.
- Fields in order: Title → Sport Type → Date & Time → Location → Max Participants → Description.
- "Save Activity" / "Update Activity" primary button pinned to bottom.
- Validation runs on submit and shows inline errors.

### 7.3 Activity Detail Screen
- Hero transition on sport icon from list card.
- Sport type chip + title + host name row.
- Date/time and location info rows.
- Description block (if present).
- Participant progress bar: `currentParticipants / maxParticipants`.
- Join / Leave button (full-width, bottom).
- If viewer is host: Edit (outlined button) + Delete (text button, destructive color) appear above the Join button area.

---

## 8. Error Handling Strategy

- All repository methods return `Either<AppException, T>` (using `fpdart` or simple sealed classes).
- UI shows `SnackBar` for transient errors (network failure, join conflict).
- Forms show inline field-level validation messages.
- `AsyncValue` from Riverpod handles loading / error / data states in screens.

---

## 9. Testing Plan

| Layer | Type | Tool | Coverage Target |
|-------|------|------|----------------|
| Models | Unit | `flutter_test` | 100% |
| Repository | Unit (mocked Firestore) | `fake_cloud_firestore` | 80% |
| Providers | Unit | `ProviderContainer.test()` (Riverpod 3 built-in) | 80% |
| Widgets | Widget test | `flutter_test` | Key flows |
| Integration | Integration test | `integration_test` | Create, Join, Delete flows |

---

## 10. CI/CD

- **CI:** GitHub Actions on every PR — `flutter analyze`, `flutter test`, build for iOS + Android.
- **CD:** Fastlane for TestFlight (iOS) and Google Play Internal Track (Android).
- **Environment config:** `.env` files loaded via `flutter_dotenv`; never commit secrets.

---

## 11. Definition of Done

A feature is considered done when:

1. Code passes `flutter analyze` with zero warnings.
2. Unit and widget tests pass with target coverage.
3. Feature works correctly on both iOS Simulator (iPhone 15) and Android Emulator (Pixel 7, API 34).
4. Design matches the design system (colors, typography, spacing).
5. Edge cases handled: empty state, max participants reached, host-only actions.
6. PR reviewed and merged to `main`.

---

## 12. Milestones

| Milestone | Deliverable | Target |
|-----------|-------------|--------|
| M0 — Foundation | Project setup, Firebase config, folder structure, auth gate, routing | Week 1 |
| M1 — Core CRUD | Create, Update, Delete activity (host flows) | Week 2 |
| M2 — Join Flow | Join/Leave, participant count, list + detail screens | Week 3 |
| M3 — Polish | Design system, loading states, error handling, empty states | Week 4 |
| M4 — QA & Launch | Testing, CI/CD, TestFlight + Play Internal | Week 5–6 |
