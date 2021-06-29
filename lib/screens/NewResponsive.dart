import 'package:flutter/material.dart';

class NewResponsiveView extends StatelessWidget {
  final Widget mobile;
  final Widget tab;
  final Widget desktop;
  NewResponsiveView({this.mobile, this.tab, this.desktop});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth >= 900) {
          return desktop;
        } else if (constraints.maxWidth >= 650) {
          return tab;
        } else {
          return mobile;
        }
      },
    );
  }
}
