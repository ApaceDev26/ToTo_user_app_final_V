import 'package:toto_user/features/wallet/domain/models/withdraw_model.dart';
import 'package:toto_user/features/wallet/domain/models/withdraw_method_model.dart';

abstract class WithdrawServiceInterface {
  Future<List<WithdrawMethodModel>?> getWithdrawMethodList();
  Future<bool> requestWithdraw(Map<String, String> data);
  Future<List<WithdrawModel>?> getWithdrawList();
}



