import 'package:flutter/widgets.dart';

extension Navigation on BuildContext {
  // push 
  Future<dynamic> pushNamed(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamed(routeName, arguments: arguments);
  }

  // Replaces the current route with a named route (removes the previous screen)
  Future<dynamic> pushReplacementNamed(String routeName, {Object? arguments}) {
    return Navigator.of(this)
        .pushReplacementNamed(routeName, arguments: arguments);
  }

  // Pushes a named route and removes all previous routes until the predicate is met
  Future<dynamic> pushNamedAndRemoveUntil(String routeName,
      {Object? arguments, required RoutePredicate predicate}) {
    return Navigator.of(this)
        .pushNamedAndRemoveUntil(routeName, predicate, arguments: arguments);
  }

  // Pops the top-most route off the navigator (Back)
  void pop() => Navigator.of(this).pop();
}