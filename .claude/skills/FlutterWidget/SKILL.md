---
name: FlutterWidget
description: Generate a new reusable Flutter widget for Sportus. USE WHEN the user asks to create, add, or scaffold a widget, UI component, or screen widget. Produces a component-based widget file that follows the Sportus design system (theme tokens, dark/light mode, spacing) and is placed in the correct feature widgets/ subfolder.
---

# Flutter Widget Generator

Follow this workflow every time a new widget is created for Sportus.

## Step 1 — Determine placement

- Widget used by **one feature** → `lib/features/<feature>/widgets/<widget_name>.dart`
- Widget used by **multiple features** → `lib/shared/widgets/<widget_name>.dart`

## Step 2 — Scaffold the file

Every widget must follow this template:

```dart
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sportus/core/theme/app_color_scheme.dart';
import 'package:sportus/core/constants/app_text_styles.dart';

class <WidgetName> extends StatelessWidget {
  const <WidgetName>({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<AppColorScheme>()!;

    return /* widget tree */;
  }
}
```

## Step 3 — Apply design system rules

- **Colors**: Always `cs.*` or `ext.*`. Zero hardcoded hex values or `Colors.*` constants.
- **Spacing**: Multiples of 4px. Use `Gap` between widgets — never `SizedBox(height: 13)`.
- **Typography**: Use `AppTextStyles` tokens. Never inline `fontSize` or `fontWeight`.
- **Cards**: `BorderRadius.circular(16)`, `elevation: 0`, border `cs.outline`, background `cs.surface`.
- **Screen background**: `cs.surfaceContainerLowest`.
- **Touch targets**: All interactive elements at least 44×44px.
- **Semantics**: `semanticLabel` on icon-only buttons; `semanticsLabel` on images.

## Step 4 — Dark & light mode verification checklist

Before finishing, confirm:
- [ ] No `Color(0xFF...)` or `Colors.*` anywhere in the file
- [ ] Backgrounds use `cs.surface` or `cs.surfaceContainerLowest`
- [ ] Text uses `cs.onSurface` or `cs.onSurfaceVariant`
- [ ] Borders/dividers use `cs.outline`
- [ ] Success state uses `ext.success` / `ext.onSuccess`
- [ ] Shimmer placeholders use `ext.shimmerBase` / `ext.shimmerHighlight`

## Step 5 — Export

Add the widget to the feature's barrel file if one exists:

```dart
// lib/features/<feature>/widgets/widgets.dart
export '<widget_name>.dart';
```
