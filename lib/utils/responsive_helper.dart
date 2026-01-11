import 'package:flutter/material.dart';

/// Helper class untuk responsive design
class ResponsiveHelper {
  static const double _mobileBreakpoint = 480;
  static const double _tabletBreakpoint = 768;
  static const double _desktopBreakpoint = 1024;

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

  /// Cek apakah mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < _tabletBreakpoint;
  }

  /// Cek apakah tablet
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

  /// Get grid columns count
  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < _tabletBreakpoint) {
      return 1;
    } else if (width < _desktopBreakpoint) {
      return 2;
    } else if (width < 1200) {
      return 3;
    } else {
      return 4;
    }
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

  /// Get font size responsif
  static double getResponsiveFontSize(
    BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    if (ResponsiveHelper.isMobile(context)) {
      return mobile;
    } else if (ResponsiveHelper.isTablet(context)) {
      return tablet;
    } else {
      return desktop;
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
