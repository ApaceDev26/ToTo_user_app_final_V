import 'package:toto_user/common/widgets/custom_snackbar_widget.dart';
import 'package:toto_user/features/wallet/domain/models/withdraw_model.dart';
import 'package:toto_user/features/wallet/domain/models/withdraw_method_model.dart';
import 'package:toto_user/features/wallet/domain/services/withdraw_service_interface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WithdrawController extends GetxController implements GetxService {
  final WithdrawServiceInterface withdrawServiceInterface;

  WithdrawController({required this.withdrawServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<WithdrawModel>? _withdrawList;
  List<WithdrawModel>? get withdrawList => _withdrawList;

  late List<WithdrawModel> _allWithdrawList;

  final List<String> _statusList = ['All', 'Pending', 'Approved', 'Denied'];
  List<String> get statusList => _statusList;

  int _filterIndex = 0;
  int get filterIndex => _filterIndex;

  List<WithdrawMethodModel>? _withdrawMethods;
  List<WithdrawMethodModel>? get withdrawMethods => _withdrawMethods;

  List<TextEditingController> _textControllerList = [];
  List<TextEditingController> get textControllerList => _textControllerList;

  List<MethodField> _methodFields = [];
  List<MethodField> get methodFields => _methodFields;

  List<FocusNode> _focusList = [];
  List<FocusNode> get focusList => _focusList;

  int? _selectedPaymentMethodId;
  int? get selectedPaymentMethodId => _selectedPaymentMethodId;

  String? _selectedPaymentMethod;
  String? get selectedPaymentMethod => _selectedPaymentMethod;

  void setSelectedPaymentMethodId(int? id) {
    _selectedPaymentMethodId = id;
    update();
  }

  void setSelectedPaymentMethod(String? method) {
    _selectedPaymentMethod = method;
    update();
  }

  void setPaymentMethod(String value) {
    final selectedMethod = _withdrawMethods?.firstWhereOrNull(
      (method) => method.methodName == value,
    );

    if (selectedMethod != null) {
      _textControllerList = [];
      _focusList = [];
      _methodFields = [];

      for (var field in selectedMethod.methodFields ?? []) {
        _methodFields.add(field);
        _textControllerList.add(TextEditingController());
        _focusList.add(FocusNode());
      }

      update();
    }
  }

  Future<void> initWithdrawMethod() async {
    _isLoading = true;
    update();
    _withdrawMethods = await withdrawServiceInterface.getWithdrawMethodList();
    _isLoading = false;
    update();
  }

  Future<void> getWithdrawList() async {
    _isLoading = true;
    update();
    _withdrawList = await withdrawServiceInterface.getWithdrawList();
    _allWithdrawList = List.from(_withdrawList ?? []);
    _isLoading = false;
    update();
  }

  void filterWithdrawList(int index) {
    _filterIndex = index;
    if (index == 0) {
      _withdrawList = List.from(_allWithdrawList);
    } else {
      String status = _statusList[index];
      _withdrawList = _allWithdrawList
          .where((withdraw) => withdraw.status == status)
          .toList();
    }
    update();
  }

  Future<void> requestWithdraw(Map<String, String> data) async {
    _isLoading = true;
    update();
    bool success = await withdrawServiceInterface.requestWithdraw(data);
    _isLoading = false;
    update();

    if (success) {
      // Close bottom sheet first
      Get.back();
      // Show success message after a small delay to ensure bottom sheet is closed
      Future.delayed(const Duration(milliseconds: 300), () {
        showCustomSnackBar('withdraw_request_placed_successfully'.tr, isError: false);
      });
      // Clear form
      for (var controller in _textControllerList) {
        controller.clear();
      }
      _selectedPaymentMethodId = null;
      _selectedPaymentMethod = null;
      _methodFields = [];
      _textControllerList = [];
      _focusList = [];
      update();
    } else {
      showCustomSnackBar('failed_to_place_withdraw_request'.tr, isError: true);
    }
  }

  @override
  void onClose() {
    for (var controller in _textControllerList) {
      controller.dispose();
    }
    for (var focus in _focusList) {
      focus.dispose();
    }
    super.onClose();
  }
}



