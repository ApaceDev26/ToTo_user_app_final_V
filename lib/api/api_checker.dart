import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:toto_user/common/widgets/custom_snackbar_widget.dart';
import 'package:toto_user/features/auth/controllers/auth_controller.dart';
import 'package:toto_user/features/favourite/controllers/favourite_controller.dart';
import 'package:toto_user/helper/route_helper.dart';

class ApiChecker {
  static Future<void> checkApi(Response response,
      {bool showToaster = false}) async {
    if (response.statusCode == 401) {
      await Get.find<AuthController>()
          .clearSharedData(removeToken: false)
          .then((value) {
        Get.find<FavouriteController>().removeFavourites();
        Get.offAllNamed(RouteHelper.getInitialRoute());
      });
    } else {
      if (showToaster) {
        showCustomSnackBar(response.statusText);
      } else if (kDebugMode) {
        debugPrint('Suppressed toast: ${response.statusText}');
      }
    }
  }
}
