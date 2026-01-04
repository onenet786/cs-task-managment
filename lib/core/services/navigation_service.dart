import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  Future<void> navigateTo(String routeName) async {
    await navigatorKey.currentState?.pushNamed(routeName);
  }

  Future<void> navigateToWithData(String routeName, dynamic data) async {
    await navigatorKey.currentState?.pushNamed(routeName, arguments: data);
  }

  Future<void> navigateAndRemoveUntil(String routeName) async {
    await navigatorKey.currentState?.pushNamedAndRemoveUntil(routeName, (route) => false);
  }

  void goBack() {
    navigatorKey.currentState?.pop();
  }

  void popUntil(String routeName) {
    navigatorKey.currentState?.popUntil(ModalRoute.withName(routeName));
  }
}
