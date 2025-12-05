// Create this file: lib/utils/responsive_helper.dart

import 'package:flutter/material.dart';

/// Device breakpoints for responsive design
class ResponsiveBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

/// Device type enum
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Responsive helper class for adaptive UI
class ResponsiveHelper {
  /// Get device type based on width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < ResponsiveBreakpoints.mobile) {
      return DeviceType.mobile;
    } else if (width < ResponsiveBreakpoints.tablet) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// Check if device is mobile
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  /// Check if device is desktop
  static bool isDesktop(BuildContext context) {
    return getDeviceType(context) == DeviceType.desktop;
  }

  /// Get responsive value based on device type
  static T getValue<T>(
      BuildContext context, {
        required T mobile,
        T? tablet,
        T? desktop,
      }) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }

  /// Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    return getValue(
      context,
      mobile: const EdgeInsets.all(16),
      tablet: const EdgeInsets.all(24),
      desktop: const EdgeInsets.all(32),
    );
  }

  /// Get responsive font size
  static double getResponsiveFontSize(
      BuildContext context,
      double baseFontSize,
      ) {
    return getValue(
      context,
      mobile: baseFontSize,
      tablet: baseFontSize * 1.1,
      desktop: baseFontSize * 1.2,
    );
  }

  /// Get responsive grid column count
  static int getGridColumnCount(BuildContext context) {
    return getValue(
      context,
      mobile: 1,
      tablet: 2,
      desktop: 3,
    );
  }

  /// Get responsive card width
  static double getCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return getValue(
      context,
      mobile: screenWidth - 40,
      tablet: (screenWidth - 64) / 2,
      desktop: (screenWidth - 96) / 3,
    );
  }

  /// Get responsive spacing
  static double getSpacing(BuildContext context) {
    return getValue(
      context,
      mobile: 16.0,
      tablet: 20.0,
      desktop: 24.0,
    );
  }

  /// Get responsive icon size
  static double getIconSize(BuildContext context) {
    return getValue(
      context,
      mobile: 24.0,
      tablet: 28.0,
      desktop: 32.0,
    );
  }

  /// Check if should use compact layout
  static bool shouldUseCompactLayout(BuildContext context) {
    return MediaQuery.sizeOf(context).width < ResponsiveBreakpoints.mobile;
  }

  /// Get max content width for large screens
  static double getMaxContentWidth(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    if (screenWidth > ResponsiveBreakpoints.desktop) {
      return ResponsiveBreakpoints.desktop;
    }
    return screenWidth;
  }

  /// Get responsive cross axis count for GridView
  static int getCrossAxisCount(BuildContext context, {int maxColumns = 4}) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < ResponsiveBreakpoints.mobile) {
      return 1;
    } else if (width < ResponsiveBreakpoints.tablet) {
      return 2.clamp(1, maxColumns);
    } else if (width < ResponsiveBreakpoints.desktop) {
      return 3.clamp(1, maxColumns);
    } else {
      return maxColumns;
    }
  }

  /// Adaptive text scale factor
  static double getTextScaleFactor(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < 360) {
      return 0.9;
    } else if (width > ResponsiveBreakpoints.desktop) {
      return 1.1;
    }
    return 1.0;
  }
}

/// Responsive builder widget
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;

  const ResponsiveBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = ResponsiveHelper.getDeviceType(context);
        return builder(context, deviceType);
      },
    );
  }
}

/// Responsive scaffold wrapper for consistent layouts
class ResponsiveScaffold extends StatelessWidget {
  final Widget child;
  final bool centerContent;
  final EdgeInsets? padding;

  const ResponsiveScaffold({
    Key? key,
    required this.child,
    this.centerContent = false,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveHelper.getMaxContentWidth(context);
    final defaultPadding = ResponsiveHelper.getResponsivePadding(context);

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: padding ?? defaultPadding,
            child: child,
          ),
        ),
      ),
    );
  }
}