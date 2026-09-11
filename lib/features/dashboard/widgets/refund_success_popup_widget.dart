import 'package:toto_user/features/order/domain/models/order_model.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class RefundSuccessPopupWidget extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onDismiss;
  final VoidCallback onViewOrder;

  const RefundSuccessPopupWidget({
    super.key,
    required this.order,
    required this.onDismiss,
    required this.onViewOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      ),
      insetPadding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  color: Theme.of(context).disabledColor,
                ),
                onPressed: onDismiss,
              ),
            ),

            // Lottie Animation - using same animation as delivery
            SizedBox(
              height: 200,
              width: 200,
              child: Lottie.asset(
                'assets/image/gifs/animation.json',
                fit: BoxFit.contain,
                repeat: true,
                animate: true,
              ),
            ),

            const SizedBox(height: Dimensions.paddingSizeLarge),

            // Title
            Text(
              'Hurray! You got a refund on your order',
              textAlign: TextAlign.center,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: Theme.of(context).primaryColor,
              ),
            ),

            const SizedBox(height: Dimensions.paddingSizeDefault),

            // Order ID
            Text(
              'Order #${order.id}',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).disabledColor,
              ),
            ),

            const SizedBox(height: Dimensions.paddingSizeLarge),

            // View Order Details Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  onViewOrder();
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(
                    vertical: Dimensions.paddingSizeDefault,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                ),
                child: Text(
                  'View Order Details',
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
