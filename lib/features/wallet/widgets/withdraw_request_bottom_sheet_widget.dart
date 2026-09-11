import 'package:toto_user/common/widgets/custom_button_widget.dart';
import 'package:toto_user/common/widgets/custom_snackbar_widget.dart';
import 'package:toto_user/common/widgets/custom_text_field_widget.dart';
import 'package:toto_user/features/profile/controllers/profile_controller.dart';
import 'package:toto_user/features/splash/controllers/splash_controller.dart';
import 'package:toto_user/features/wallet/controllers/withdraw_controller.dart';
import 'package:toto_user/helper/date_converter.dart';
import 'package:toto_user/helper/price_converter.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WithdrawRequestBottomSheetWidget extends StatefulWidget {
  const WithdrawRequestBottomSheetWidget({super.key});

  @override
  State<WithdrawRequestBottomSheetWidget> createState() =>
      _WithdrawRequestBottomSheetWidgetState();
}

class _WithdrawRequestBottomSheetWidgetState
    extends State<WithdrawRequestBottomSheetWidget> {
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _amountController.text = Get.find<ProfileController>()
            .userInfoModel
            ?.walletBalance
            ?.toString() ??
        '0';
    // Withdraw methods are initialized before showing the bottom sheet
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<WithdrawController>()) {
      return Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Center(
          child: Text('error_loading_withdraw_options'.tr),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(Dimensions.radiusLarge)),
      ),
      child: GetBuilder<WithdrawController>(builder: (withdrawController) {
        return SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const SizedBox(width: 40),
              Container(
                height: 5,
                width: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).disabledColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              InkWell(
                onTap: () => Get.back(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.highlight_remove,
                      color: Theme.of(context).disabledColor, size: 25),
                ),
              ),
            ]),
            Text('withdraw_request'.tr,
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(children: [
                if (withdrawController.isLoading &&
                    withdrawController.withdrawMethods == null)
                  const Center(child: CircularProgressIndicator())
                else if (withdrawController.withdrawMethods == null ||
                    withdrawController.withdrawMethods!.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                    child: Text('no_withdrawal_methods_available'.tr,
                        style: robotoRegular),
                  )
                else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusDefault),
                      border:
                          Border.all(color: Theme.of(context).disabledColor),
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: Text('select_payment_method'.tr,
                          style: robotoRegular),
                      items: withdrawController.withdrawMethods!
                          .map(
                            (method) => DropdownMenuItem<String>(
                              value: method.methodName,
                              child: Text(method.methodName ?? '',
                                  style: robotoMedium.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color)),
                            ),
                          )
                          .toList(),
                      value: withdrawController.selectedPaymentMethod,
                      underline: const SizedBox(),
                      dropdownColor: Theme.of(context).cardColor,
                      style: robotoRegular.copyWith(color: Colors.white),
                      iconEnabledColor:
                          Theme.of(context).textTheme.bodyLarge?.color,
                      onChanged: (String? value) {
                        if (value != null) {
                          withdrawController.setSelectedPaymentMethod(value);
                          withdrawController.setPaymentMethod(value);
                          final selectedMethod = withdrawController
                              .withdrawMethods!
                              .firstWhereOrNull(
                                  (method) => method.methodName == value);
                          if (selectedMethod != null) {
                            withdrawController
                                .setSelectedPaymentMethodId(selectedMethod.id);
                          }
                        }
                      },
                    ),
                  ),
                  SizedBox(
                      height: withdrawController.methodFields.isNotEmpty
                          ? Dimensions.paddingSizeLarge
                          : 0),
                  ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: withdrawController.methodFields.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final field = withdrawController.methodFields[index];
                        return Column(children: [
                          Row(children: [
                            Expanded(
                              child: CustomTextFieldWidget(
                                hintText: field.placeholder ?? '',
                                labelText: field.inputName
                                        ?.toString()
                                        .replaceAll('_', ' ')
                                        .split(' ')
                                        .map((word) => word.isNotEmpty
                                            ? word[0].toUpperCase() +
                                                word.substring(1)
                                            : '')
                                        .join(' ') ??
                                    '',
                                controller: withdrawController
                                    .textControllerList[index],
                                capitalization: TextCapitalization.words,
                                inputType: field.inputType == 'phone'
                                    ? TextInputType.phone
                                    : field.inputType == 'number'
                                        ? TextInputType.number
                                        : field.inputType == 'email'
                                            ? TextInputType.emailAddress
                                            : TextInputType.name,
                                focusNode: withdrawController.focusList[index],
                                nextFocus: index !=
                                        withdrawController.methodFields.length -
                                            1
                                    ? withdrawController.focusList[index + 1]
                                    : _amountFocus,
                                required: field.isRequired == 1,
                                onChanged: (value) {
                                  setState(() {});
                                },
                              ),
                            ),
                            if (field.inputType == 'date')
                              IconButton(
                                  onPressed: () async {
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2100),
                                    );

                                    if (pickedDate != null) {
                                      String formattedDate =
                                          DateConverter.dateTimeForCoupon(
                                              pickedDate);
                                      setState(() {
                                        withdrawController
                                            .textControllerList[index]
                                            .text = formattedDate;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.date_range_sharp)),
                          ]),
                          SizedBox(
                              height: index !=
                                      withdrawController.methodFields.length - 1
                                  ? Dimensions.paddingSizeLarge
                                  : 0),
                        ]);
                      }),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  CustomTextFieldWidget(
                    hintText: 'enter_withdraw_amount'.tr,
                    labelText:
                        '${'enter_withdraw_amount'.tr} (${Get.find<SplashController>().configModel?.currencySymbol})',
                    controller: _amountController,
                    capitalization: TextCapitalization.words,
                    inputType: TextInputType.number,
                    focusNode: _amountFocus,
                    inputAction: TextInputAction.done,
                    required: true,
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  Builder(builder: (context) {
                    bool fieldEmpty = false;

                    for (var element in withdrawController.methodFields) {
                      if (element.isRequired == 1) {
                        if (withdrawController
                            .textControllerList[withdrawController.methodFields
                                .indexOf(element)]
                            .text
                            .isEmpty) {
                          fieldEmpty = true;
                        }
                      }
                    }

                    return CustomButtonWidget(
                      isLoading: withdrawController.isLoading,
                      buttonText: 'send_request'.tr,
                      onPressed: !fieldEmpty &&
                              withdrawController.selectedPaymentMethodId !=
                                  null &&
                              _amountController.text.isNotEmpty
                          ? () {
                              if (fieldEmpty) {
                                showCustomSnackBar(
                                    'required_fields_can_not_be_empty'.tr);
                              } else if (_amountController.text
                                  .trim()
                                  .isEmpty) {
                                showCustomSnackBar('enter_amount'.tr);
                              } else {
                                // Validate min/max withdrawal amounts
                                final amount = double.tryParse(_amountController.text.trim());
                                final configModel = Get.find<SplashController>().configModel;
                                final minAmount = configModel?.customerMinWithdrawAmount ?? 0.0;
                                final maxAmount = configModel?.customerMaxWithdrawAmount ?? 0.0;

                                if (amount == null || amount <= 0) {
                                  showCustomSnackBar('please_enter_valid_amount'.tr);
                                  return;
                                }

                                if (minAmount > 0 && amount < minAmount) {
                                  showCustomSnackBar('minimum_withdrawal_amount_is'.tr + ' ${PriceConverter.convertPrice(minAmount)}');
                                  return;
                                }

                                if (maxAmount > 0 && amount > maxAmount) {
                                  showCustomSnackBar('maximum_withdrawal_amount_is'.tr + ' ${PriceConverter.convertPrice(maxAmount)}');
                                  return;
                                }

                                Map<String, String> data = {};
                                data['id'] = withdrawController
                                    .selectedPaymentMethodId
                                    .toString();
                                data['amount'] = _amountController.text.trim();

                                for (var result
                                    in withdrawController.methodFields) {
                                  data[result.inputName ?? ''] =
                                      withdrawController
                                          .textControllerList[withdrawController
                                              .methodFields
                                              .indexOf(result)]
                                          .text
                                          .trim();
                                }

                                withdrawController.requestWithdraw(data);
                              }
                            }
                          : null,
                    );
                  }),
                ],
              ]),
            ),
          ]),
        );
      }),
    );
  }
}
