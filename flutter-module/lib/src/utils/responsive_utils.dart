import 'package:flutter/material.dart';

/// Breakpoint types for responsive design
enum Breakpoint {
  mobile,
  tablet,
  desktop,
}

/// Utility class for responsive design
class ResponsiveUtils {
  /// Mobile breakpoint (< 600px)
  static const double mobileBreakpoint = 600;

  /// Tablet breakpoint (600px - 1024px)
  static const double tabletBreakpoint = 1024;

  /// Get current breakpoint based on screen width
  static Breakpoint getBreakpoint(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return Breakpoint.mobile;
    } else if (width < tabletBreakpoint) {
      return Breakpoint.tablet;
    } else {
      return Breakpoint.desktop;
    }
  }

  /// Check if current device is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Check if current device is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  /// Check if current device is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  /// Get responsive column count for grid layouts
  static int getColumnCount(BuildContext context, {
    int mobileColumns = 1,
    int tabletColumns = 2,
    int desktopColumns = 3,
  }) {
    final breakpoint = getBreakpoint(context);
    switch (breakpoint) {
      case Breakpoint.mobile:
        return mobileColumns;
      case Breakpoint.tablet:
        return tabletColumns;
      case Breakpoint.desktop:
        return desktopColumns;
    }
  }

  /// Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context, {
    EdgeInsets? mobilePadding,
    EdgeInsets? tabletPadding,
    EdgeInsets? desktopPadding,
  }) {
    final breakpoint = getBreakpoint(context);
    switch (breakpoint) {
      case Breakpoint.mobile:
        return mobilePadding ?? const EdgeInsets.all(8);
      case Breakpoint.tablet:
        return tabletPadding ?? const EdgeInsets.all(16);
      case Breakpoint.desktop:
        return desktopPadding ?? const EdgeInsets.all(24);
    }
  }

  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, {
    double mobileSize = 14,
    double tabletSize = 16,
    double desktopSize = 18,
  }) {
    final breakpoint = getBreakpoint(context);
    switch (breakpoint) {
      case Breakpoint.mobile:
        return mobileSize;
      case Breakpoint.tablet:
        return tabletSize;
      case Breakpoint.desktop:
        return desktopSize;
    }
  }

  /// Get responsive spacing
  static double getResponsiveSpacing(BuildContext context, {
    double mobileSpacing = 8,
    double tabletSpacing = 12,
    double desktopSpacing = 16,
  }) {
    final breakpoint = getBreakpoint(context);
    switch (breakpoint) {
      case Breakpoint.mobile:
        return mobileSpacing;
      case Breakpoint.tablet:
        return tabletSpacing;
      case Breakpoint.desktop:
        return desktopSpacing;
    }
  }

  /// Get responsive value based on breakpoint
  static T getValue<T>(BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final breakpoint = getBreakpoint(context);
    switch (breakpoint) {
      case Breakpoint.mobile:
        return mobile;
      case Breakpoint.tablet:
        return tablet ?? mobile;
      case Breakpoint.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}

/// Widget that adapts its layout based on screen size
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, Breakpoint breakpoint) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final breakpoint = ResponsiveUtils.getBreakpoint(context);
    return builder(context, breakpoint);
  }
}

/// Widget that shows different layouts for different breakpoints
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, breakpoint) {
        switch (breakpoint) {
          case Breakpoint.mobile:
            return mobile;
          case Breakpoint.tablet:
            return tablet ?? mobile;
          case Breakpoint.desktop:
            return desktop ?? tablet ?? mobile;
        }
      },
    );
  }
}

/// Responsive grid view that adjusts column count based on screen size
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;
  final double runSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 8,
    this.runSpacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    final columnCount = ResponsiveUtils.getColumnCount(
      context,
      mobileColumns: mobileColumns,
      tabletColumns: tabletColumns,
      desktopColumns: desktopColumns,
    );

    return GridView.count(
      crossAxisCount: columnCount,
      crossAxisSpacing: spacing,
      mainAxisSpacing: runSpacing,
      children: children,
    );
  }
}

/// Responsive form field that adjusts width based on screen size
class ResponsiveFormField extends StatelessWidget {
  final Widget child;
  final double? mobileWidth;
  final double? tabletWidth;
  final double? desktopWidth;

  const ResponsiveFormField({
    super.key,
    required this.child,
    this.mobileWidth,
    this.tabletWidth,
    this.desktopWidth,
  });

  @override
  Widget build(BuildContext context) {
    final width = ResponsiveUtils.getValue<double?>(
      context,
      mobile: mobileWidth,
      tablet: tabletWidth,
      desktop: desktopWidth,
    );

    if (width == null) {
      return child;
    }

    return SizedBox(
      width: width,
      child: child,
    );
  }
}
