import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

/// Responsive layout yang otomatis adjust berdasarkan screen size
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    required this.mobile,
    this.tablet,
    this.desktop,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final deviceSize = ResponsiveHelper.getDeviceSize(context);
    
    switch (deviceSize) {
      case DeviceSize.small:
      case DeviceSize.mobile:
        return mobile;
      case DeviceSize.tablet:
        return tablet ?? mobile;
      case DeviceSize.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}

/// Responsive grid builder
class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? padding;
  final double? childAspectRatio;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ResponsiveGridView({
    required this.children,
    this.padding,
    this.childAspectRatio,
    this.shrinkWrap = false,
    this.physics,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveHelper.getGridColumns(context);
    final padding = this.padding ?? ResponsiveHelper.getResponsivePadding(context);
    final spacing = ResponsiveHelper.getResponsiveSpacing(context);

    return GridView.builder(
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        childAspectRatio: childAspectRatio ?? 1.0,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// Responsive column/row based on screen size
class ResponsiveDirection extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final bool mobile;

  const ResponsiveDirection({
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mobile = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    if (isMobile && mobile) {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      );
    } else {
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      );
    }
  }
}

/// Responsive card dengan adaptive padding
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final double? borderRadius;
  final BoxBorder? border;

  const ResponsiveCard({
    required this.child,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final padding = this.padding ?? ResponsiveHelper.getResponsivePadding(context);
    final borderRadius = this.borderRadius ?? 16;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

/// Responsive container dengan max width constraint
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final AlignmentGeometry alignment;

  const ResponsiveContainer({
    required this.child,
    this.padding,
    this.alignment = Alignment.topCenter,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveHelper.getMaxContentWidth(context);
    final padding = this.padding ?? ResponsiveHelper.getResponsivePadding(context);

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: padding,
        alignment: alignment,
        child: child,
      ),
    );
  }
}

/// Responsive spacer
class ResponsiveSpacer extends StatelessWidget {
  final double? height;
  final double? width;

  const ResponsiveSpacer({
    this.height,
    this.width,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveHelper.getResponsiveSpacing(context);
    return SizedBox(
      height: height ?? spacing,
      width: width ?? spacing,
    );
  }
}

/// Responsive text
class ResponsiveText extends StatelessWidget {
  final String text;
  final double baseFontSize;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;

  const ResponsiveText(
    this.text, {
    this.baseFontSize = 16,
    this.style,
    this.textAlign,
    this.maxLines,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = ResponsiveHelper.getResponsiveFontSize(context, baseFontSize);
    final baseStyle = style ?? const TextStyle();

    return Text(
      text,
      style: baseStyle.copyWith(fontSize: fontSize),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
