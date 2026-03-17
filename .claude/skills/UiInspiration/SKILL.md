---
name: UiInspiration
description: Translate a UI design screenshot or inspiration image into a Flutter widget or screen for Sportus. USE WHEN the user shares an image, screenshot, mockup, or reference design and wants to build it (or something like it) in Flutter. Do NOT copy the design pixel-for-pixel — adapt it to the Sportus design system (colors, typography, spacing, dark/light mode).
---

# UI Inspiration → Flutter

When the user shares a screenshot or inspiration image, follow this workflow.

## Step 1 — Analyse the image

Before writing any code, describe what you observe so the user can correct misreads:

- **Layout**: How is the screen divided? (list, grid, card stack, bottom sheet, etc.)
- **Components**: What widgets are present? (AppBar, FAB, chips, avatar, progress bar, etc.)
- **Hierarchy**: What is visually primary vs. secondary?
- **Interactions**: What tappable elements are visible? (buttons, cards, icons)
- **Colour mood**: Light, dark, vibrant, muted? Note anything that conflicts with the Sportus palette.

Ask the user: *"Does this match what you had in mind, or should I adjust the interpretation?"* before writing any code.

## Step 2 — Map to the Sportus design system

**Never copy colours from the screenshot directly.** Map to Sportus tokens:

| Inspiration element | Sportus token |
|---------------------|---------------|
| White / light background | `cs.surface` or `cs.surfaceContainerLowest` |
| Dark card / panel | `cs.surface` (dark mode handles this automatically) |
| Primary accent colour | `cs.primary` |
| Subtle chip / badge | `cs.primaryContainer` / `cs.onPrimaryContainer` |
| Body text | `cs.onSurface` |
| Secondary text | `cs.onSurfaceVariant` |
| Border / divider | `cs.outline` |
| Success / joined indicator | `ext.success` / `ext.onSuccess` |

Map typography to `AppTextStyles` tokens — never hardcode font sizes from the screenshot.
Map spacing to the 4px grid — round observed spacing to the nearest multiple of 4.

## Step 3 — Identify file placement

- New standalone screen → `lib/features/<feature>/<n>_screen.dart`
- Reusable component for one feature → `lib/features/<feature>/widgets/<n>.dart`
- Reusable component for multiple features → `lib/shared/widgets/<n>.dart`

## Step 4 — Build the widget

Follow the standard widget template (see `FlutterWidget` skill). Key rules:

```dart
@override
Widget build(BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  final ext = Theme.of(context).extension<AppColorScheme>()!;
  // All colours from cs.* or ext.* — never hardcoded
}
```

Faithfully reproduce the **layout and structure**. Adapt the **visual style** to Sportus tokens.

## Step 5 — Dark mode verification

Inspiration screenshots are almost always light-mode only. Before finishing, confirm:

- [ ] No `Color(...)` or `Colors.*` anywhere in the file
- [ ] All backgrounds adapt via `cs.surface` / `cs.surfaceContainerLowest`
- [ ] Text remains readable in both modes via `cs.onSurface` / `cs.onSurfaceVariant`
- [ ] Borders use `cs.outline`

## Step 6 — Confirm with the user

After scaffolding, tell the user:
- What was built and where the file lives
- Any design choices that differ from the screenshot, and why
- Any features that need additional packages (e.g. blur, custom animation) — list the package name and ask permission before adding it
