import 'package:flutter/material.dart';
import 'package:toto_user/design_system/components/app_feedback.dart';
import 'package:get/get.dart';

/// Prefer this over [Get.back] when a stuck GetX snackbar may be open.
/// [Get.back] tries to close snackbars first and can throw
/// LateInitializationError if overlay setup failed earlier.
void safeBack<T>([T? result]) {
  final navigator = Get.key.currentState;
  if (navigator != null && navigator.canPop()) {
    navigator.pop<T>(result);
    return;
  }
  try {
    Get.back<T>(result: result);
  } catch (_) {}
}

Future<void> showCustomSnackBar(
  String? message, {
  bool isError = true,
  Duration? duration,
  EdgeInsets? margin,
}) async {
  if (message == null || message.isEmpty) return;
  AppSnack.show(
    message,
    isError: isError,
    duration: duration ?? const Duration(seconds: 2),
    margin: margin,
  );
}
