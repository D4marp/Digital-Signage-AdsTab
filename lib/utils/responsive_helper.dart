import 'package:flutter/material.dart';

/// Helper class untuk responsive design
class ResponsiveHelper {
  static const double _mobileBreakpoint = 480;
  static const double _tabletBreakpoint = 768;
  static const double _desktopBreakpoint = 1024;
  static const double _largeDesktopBreakpoint = 1440;

  /// Get screen size
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  /// Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < _mobileBreakpoint) {
      return const EdgeInsets.all(12);
    } else if (width < _tabletBreakpoint) {
      return const EdgeInsets.all(16);
    } else if (width < _desktopBreakpoint) {
      return const EdgeInsets.all(20);
    } else {
      return const EdgeInsets.all(24);
    }
  }

  /// Get responsive spacing
  static double getResponsiveSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < _mobileBreakpoint) {
      return 8;
    } else if (width < _tabletBreakpoint) {
      return 12;
    } else if (width < _desktopBreakpoint) {
      return 16;
    } else {
      return 24;
    }
  }

  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final width = MediaQuery.of(context).size.width;
    final scaleFactor = width / 1024; // Normalize to desktop breakpoint
    return baseFontSize * scaleFactor.clamp(0.8, 1.2);
  }

  /// Get grid columns based on screen size
  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < _mobileBreakpoint) {
      return 1;
    } else if (width < _tabletBreakpoint) {
      return 2;
    } else if (width < _desktopBreakpoint) {
      return 3;
    } else {
      return 4;
    }
  }

  /// Get max content width
  static double getMaxContentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < _desktopBreakpoint) {
      return width;
    } else if (width < _largeDesktopBreakpoint) {
      return 1200;
    } else {
      return 1400;
    }
  }

  /// Deteksi ukuran device
  static DeviceSize getDeviceSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < _mobileBreakpoint) {
      return DeviceSize.small;
    } else if (width < _tabletBreakpoint) {
      return DeviceSize.mobile;
    } else if (width < _desktopBreakpoint) {
      return DeviceSize.tablet;
    } else {
      return DeviceSize.desktop;
    }
  }

  /// Cek apakah mobile (< 768)
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < _tabletBreakpoint;
  }

  /// Cek apakah small mobile (< 480)
  static bool isSmallMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < _mobileBreakpoint;
  }

  /// Cek apakah tablet (768 - 1024)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= _tabletBreakpoint && width < _desktopBreakpoint;
  }

  /// Cek apakah desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= _desktopBreakpoint;
  }

  /// Get padding responsif
  static EdgeInsets getPadding(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    if (isMobile) {
      return const EdgeInsets.all(12);
    } else if (isTablet) {
      return const EdgeInsets.all(16);
    } else {
      return const EdgeInsets.all(24);
    }
  }

  /// Get spacing responsif
  static double getSpacing(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    if (isMobile) {
      return 12;
    } else if (isTablet) {
      return 16;
    } else {
      return 24;
    }
  }

  /// Get border radius responsif
  static BorderRadius getBorderRadius(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    return BorderRadius.circular(isMobile ? 8 : 12);
  }

  /// Get width untuk card/container
  static double getContentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) {
      return 1200;
    }
    return width - 32; // padding
  }

  /// Get dialog width responsif
  static double getDialogWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = ResponsiveHelper.isMobile(context);

    if (isMobile) {
      return width * 0.9;
    } else if (ResponsiveHelper.isTablet(context)) {
      return width * 0.7;
    } else {
      return 600;
    }
  }

  /// Wrap widget untuk responsive grid
  static Widget wrapInGrid({
    required BuildContext context,
    required List<Widget> children,
    required double spacing,
  }) {
    final columns = getGridColumns(context);

    return GridView.count(
      crossAxisCount: columns,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}

enum DeviceSize {
  small,
  mobile,
  tablet,
  desktop,
}

/// Widget helper untuk responsive layout
class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final deviceSize = ResponsiveHelper.getDeviceSize(context);

    switch (deviceSize) {
      case DeviceSize.small:
      case DeviceSize.mobile:
        return mobile;
      case DeviceSize.tablet:
        return tablet;
      case DeviceSize.desktop:
        return desktop;
    }
  }
}

/// Widget wrapper untuk adaptive layout
class AdaptiveScaffold extends StatelessWidget {
  final Widget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final List<Widget>? persistentFooterButtons;

  const AdaptiveScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.persistentFooterButtons,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar as PreferredSizeWidget?,
      body: body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      persistentFooterButtons: persistentFooterButtons,
    );
  }
}
