import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toto_user/design_system/app_colors.dart';

class ColorResources {

  static Color getRightBubbleColor() {
    final context = Get.context;
    if (context == null) return AppColors.light.accent;
    return AppColors.of(context).accent;
  }

  static Color getLeftBubbleColor() {
    final context = Get.context;
    if (context == null) return AppColors.light.accentSoft;
    return AppColors.of(context).accentSoft;
  }
}
