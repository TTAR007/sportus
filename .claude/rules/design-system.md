---
name: design-system
description: Sportus design system — colors, typography, spacing, and component patterns for light and dark mode.
globs:
  - "lib/features/**/*.dart"
  - "lib/shared/widgets/**/*.dart"
  - "lib/core/theme/**/*.dart"
---

# Sportus Design System

## Theme Architecture

The app uses Flutter Material 3 with `ThemeMode.system`. Two sources of color truth:

1. `Theme.of(context).colorScheme` — Material 3 tokens
2. `Theme.of(context).extension<AppColorScheme>()!` — custom Sportus tokens

**Never hardcode a color hex in any widget file.**

## Color Tokens

### Material 3 ColorScheme tokens

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `primary` | `#2563EB` | `#60A5FA` | Buttons, active states, links |
| `onPrimary` | `#FFFFFF` | `#0F172A` | Text/icons on primary |
| `primaryContainer` | `#DBEAFE` | `#1E3A5F` | Filter chips, badges |
| `onPrimaryContainer` | `#1E3A5F` | `#BFDBFE` | Text inside containers |
| `surface` | `#FFFFFF` | `#1E293B` | Cards, sheets, dialogs |
| `onSurface` | `#0F172A` | `#F1F5F9` | Primary body text |
| `surfaceContainerLowest` | `#F1F5F9` | `#0F172A` | Screen scaffold background |
| `onSurfaceVariant` | `#64748B` | `#94A3B8` | Subtitles, hints, captions |
| `error` | `#DC2626` | `#F87171` | Validation errors, delete actions |
| `outline` | `#CBD5E1` | `#334155` | Card borders, input borders |

### AppColorScheme extension tokens (`core/theme/app_color_scheme.dart`)

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `success` | `#16A34A` | `#4ADE80` | Joined state indicator |
| `onSuccess` | `#FFFFFF` | `#0F172A` | Text on success background |
| `shimmerBase` | `#E2E8F0` | `#1E293B` | Skeleton loading base |
| `shimmerHighlight` | `#F8FAFC` | `#2D3F55` | Skeleton loading highlight |

### Correct usage pattern

```dart
final cs = Theme.of(context).colorScheme;
final ext = Theme.of(context).extension<AppColorScheme>()!;

// ✅ Correct
Container(color: cs.surface);
Text('Joined!', style: TextStyle(color: ext.success));

// ❌ Wrong — never hardcode
Container(color: const Color(0xFF1E293B));
Text('Joined!', style: TextStyle(color: Colors.green));
```

## Typography

Font family: **Inter** via `google_fonts`.
All text styles come from `AppTextStyles` (`core/constants/app_text_styles.dart`).
**Never** specify `fontSize` or `fontWeight` inline in a widget.

| Style token | Size | Weight | Usage |
|-------------|------|--------|-------|
| `headingLarge` | 24sp | 700 | Screen titles |
| `headingMedium` | 20sp | 600 | Card titles, section headers |
| `bodyLarge` | 16sp | 400 | Primary body copy |
| `bodyMedium` | 14sp | 400 | Secondary body, descriptions |
| `labelSmall` | 12sp | 500 | Badges, chips, timestamps |

## Spacing

Use multiples of **4px** only. Use the `Gap` widget (`gap` package) between children.
Standard screen horizontal padding: `16px`.

```dart
Column(children: [
  const Text('Title'),
  const Gap(8),    // ✅
  const Text('Subtitle'),
  // ❌ SizedBox(height: 13) — not on the 4px grid
])
```

## Components

### Cards
```dart
Card(
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: BorderSide(color: cs.outline),
  ),
  color: cs.surface,
)
```

### Screen Background
```dart
Scaffold(backgroundColor: cs.surfaceContainerLowest)
```

### Primary Button
- Height: `52px`
- Border radius: `BorderRadius.circular(12)`
- Background: `cs.primary`, foreground: `cs.onPrimary`

### Filter Chips
- Selected: background `cs.primaryContainer`, label `cs.onPrimaryContainer`
- Unselected: background transparent, border `cs.outline`

### Touch Targets
All interactive elements must be at least **44×44px**.

### Shimmer Skeletons
Use `ShimmerCard` from `lib/shared/widgets/shimmer_card.dart`.
Base color: `ext.shimmerBase`. Highlight color: `ext.shimmerHighlight`.
Never show a bare `CircularProgressIndicator` as the only full-screen loading state.

### Empty States
Use `EmptyState` from `lib/shared/widgets/empty_state.dart` with an illustration and a CTA button.

## Accessibility

- Minimum contrast: **4.5:1** for body text, **3:1** for large text and UI components.
- All icon-only buttons must have `semanticLabel` or `Semantics(label: '...')`.
- All images must have a meaningful `semanticsLabel`.
