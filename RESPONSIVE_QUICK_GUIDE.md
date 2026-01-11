# 📱 Responsive Admin - Quick Reference Guide

## 🚀 Quick Start

Import responsive helper di screen mu:
```dart
import '../../../utils/responsive_helper.dart';
```

## 📏 Device Detection

```dart
// Cek device type
if (ResponsiveHelper.isMobile(context)) { }
if (ResponsiveHelper.isTablet(context)) { }
if (ResponsiveHelper.isDesktop(context)) { }

// Get device size enum
final size = ResponsiveHelper.getDeviceSize(context);
switch(size) {
  case DeviceSize.mobile: // Handle mobile
  case DeviceSize.tablet: // Handle tablet
  case DeviceSize.desktop: // Handle desktop
  case DeviceSize.small: // Handle small
}
```

## 🎨 Common Patterns

### 1. Different Layouts per Device
```dart
if (ResponsiveHelper.isMobile(context)) {
  return _buildMobileView();
} else if (ResponsiveHelper.isTablet(context)) {
  return _buildTabletView();
} else {
  return _buildDesktopView();
}
```

### 2. Responsive Padding/Spacing
```dart
final padding = ResponsiveHelper.getPadding(context); // 12/16/24
final spacing = ResponsiveHelper.getSpacing(context); // 12/16/24

SizedBox(height: spacing),
Padding(padding: padding, child: ...),
```

### 3. Responsive Dialog
```dart
final width = ResponsiveHelper.getDialogWidth(context);
// Mobile: 90% width, Tablet: 70%, Desktop: 600px

return Dialog(
  child: Container(
    width: width,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.9,
    ),
    // ...
  ),
);
```

### 4. Responsive Grid
```dart
final columns = ResponsiveHelper.getGridColumns(context);
// Mobile: 1, Tablet: 2, Desktop: 3-4

GridView.count(
  crossAxisCount: columns,
  // ...
)
```

### 5. Responsive Font Size
```dart
final fontSize = ResponsiveHelper.getResponsiveFontSize(
  context,
  mobile: 14,
  tablet: 16,
  desktop: 18,
);

Text('Title', style: TextStyle(fontSize: fontSize));
```

## 📐 Breakpoints Reference

| Device | Width | Type |
|--------|-------|------|
| Small Phone | < 480px | small |
| Phone | 480-768px | mobile |
| Tablet | 768-1024px | tablet |
| Desktop | ≥ 1024px | desktop |

## ✨ Helper Methods Summary

| Method | Returns | Purpose |
|--------|---------|---------|
| `isMobile()` | bool | Check if width < 768px |
| `isTablet()` | bool | Check if 768-1024px |
| `isDesktop()` | bool | Check if width ≥ 1024px |
| `getPadding()` | EdgeInsets | Get responsive padding |
| `getSpacing()` | double | Get responsive spacing |
| `getGridColumns()` | int | Get grid column count |
| `getDialogWidth()` | double | Get optimal dialog width |
| `getResponsiveFontSize()` | double | Get adaptive font size |
| `getBorderRadius()` | BorderRadius | Get responsive radius |

## 🎯 Real Examples from Admin

### Ads Tab - Grid/List Layout
```dart
// Desktop: 2-column grid
if (!isMobile && ResponsiveHelper.isDesktop(context)) {
  return _buildDesktopView(ads); // GridView
}
// Mobile/Tablet: List view
return _buildMobileView(ads); // ReorderableListView
```

### Admin Home - AppBar User Info
```dart
// Mobile: avatar only
if (isMobile && authProvider.userModel != null)
  CircleAvatar(...)

// Desktop: full user info
if (!isMobile && authProvider.userModel != null)
  Row(children: [CircleAvatar, Column(name, role)])
```

### Dialog - Responsive Size
```dart
final dialogWidth = ResponsiveHelper.getDialogWidth(context);

Dialog(
  child: Container(
    width: dialogWidth, // 90% mobile, 70% tablet, 600px desktop
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.9,
    ),
    child: Column(...), // header/body/footer
  ),
)
```

## 💡 Pro Tips

1. **Always use Expanded/Flexible** untuk layout yang scalable
2. **Use Wrap untuk chips/buttons** agar responsive
3. **Set maxWidth pada content** untuk desktop (1200px)
4. **Test semua breakpoints** sebelum commit
5. **Use SingleChildScrollView** untuk mobile dialogs
6. **Prefer Columns/Rows** over hardcoded sizes

## 🔍 Testing Your Changes

```dart
// Test responsiveness di berbagai ukuran:
// - 375px (iPhone)
// - 480px (Android Phone)
// - 768px (Tablet Portrait)
// - 1024px (Tablet Landscape)
// - 1920px (Desktop)

// Gunakan Device Preview package untuk testing:
// flutter pub add device_preview
```

## 📚 Files to Reference

- `lib/utils/responsive_helper.dart` - Helper class
- `lib/screens/admin/admin_home_screen.dart` - Example: AppBar
- `lib/screens/admin/tabs/ads_tab.dart` - Example: Grid/List
- `lib/screens/admin/widgets/ad_edit_dialog.dart` - Example: Dialog

## 🐛 Common Issues & Fixes

| Issue | Solution |
|-------|----------|
| Dialog too wide on mobile | Use `getDialogWidth()` |
| Text overflow | Use `maxLines` + `overflow` |
| Buttons too small | Use `SizedBox(height: 48)` |
| Layout breaks at breakpoint | Test exact breakpoint width |
| Content doesn't scroll | Wrap with `SingleChildScrollView` |
| Padding inconsistent | Use `getPadding()` helper |

---

**Last Updated:** January 11, 2026  
**Status:** ✅ Ready for Production
