import 'package:toto_user/common/enums/data_source_enum.dart';
import 'package:toto_user/common/widgets/custom_loader_widget.dart';
import 'package:toto_user/features/address/controllers/address_controller.dart';
import 'package:toto_user/features/auth/controllers/auth_controller.dart';
import 'package:toto_user/helper/route_helper.dart';
import 'package:get/get.dart';

class AuthHelper {

  static bool isGuestLoggedIn() {
    return Get.find<AuthController>().isGuestLoggedIn();
  }

  static String getGuestId() {
    return Get.find<AuthController>().getGuestId();
  }

  static bool isLoggedIn() {
    return Get.find<AuthController>().isLoggedIn();
  }

  /// After login/signup verification: pick from saved addresses if any,
  /// otherwise open add-address for first-time location setup.
  static Future<void> navigateAfterLoginForAddress() async {
    Get.dialog(const CustomLoaderWidget(), barrierDismissible: false);
    try {
      final addressController = Get.find<AddressController>();
      await addressController.getAddressList(
          dataSource: DataSourceEnum.client);
      final hasAddresses =
          addressController.addressList?.isNotEmpty ?? false;
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      if (hasAddresses) {
        Get.offAllNamed(RouteHelper.getAccessLocationRoute('sign-in'));
      } else {
        Get.offAllNamed(RouteHelper.getAddAddressRoute(false, null,
            forGuest: false, fromNewUser: true));
      }
    } catch (_) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      Get.offAllNamed(RouteHelper.getAddAddressRoute(false, null,
          forGuest: false, fromNewUser: true));
    }
  }
}
