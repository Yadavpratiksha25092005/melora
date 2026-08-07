import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:Melora/core/routes/route_names.dart';

/// Fixes the "back button closes the whole app" problem that happens
/// because bottom-nav tabs use context.go() (which replaces the current
/// route instead of pushing on top of it), so there's no back-stack entry
/// for the system back button to pop.
///
/// Wrap any tab screen's Scaffold with this: if there's a real navigator
/// stack, pop it normally; else if we're not already on Home, go to Home;
/// only if we're already on Home does back actually exit the app.
///
/// [isAtHome] / [goHome] let a caller that manages its own tab state
/// (e.g. [MainShell]'s `IndexedStack`, where switching tabs never
/// changes the router location) override the route-based "am I on
/// Home?" check with the real current tab instead.
class AppBackHandler extends StatelessWidget {
  final Widget child;
  final bool Function()? isAtHome;
  final VoidCallback? goHome;

  const AppBackHandler({
    super.key,
    required this.child,
    this.isAtHome,
    this.goHome,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (context.canPop()) {
          context.pop();
          return;
        }

        final atHome = isAtHome != null
            ? isAtHome!()
            : GoRouterState.of(context).uri.toString() == RouteNames.home;

        if (!atHome) {
          if (goHome != null) {
            goHome!();
          } else {
            context.go(RouteNames.home);
          }
        } else {
          SystemNavigator.pop();
        }
      },
      child: child,
    );
  }
}