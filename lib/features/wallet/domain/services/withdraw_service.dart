import 'package:toto_user/features/wallet/domain/models/withdraw_model.dart';
import 'package:toto_user/features/wallet/domain/models/withdraw_method_model.dart';
import 'package:toto_user/features/wallet/domain/repositories/withdraw_repository_interface.dart';
import 'package:toto_user/features/wallet/domain/services/withdraw_service_interface.dart';

class WithdrawService implements WithdrawServiceInterface {
  final WithdrawRepositoryInterface withdrawRepositoryInterface;

  WithdrawService({required this.withdrawRepositoryInterface});

  @override
  Future<List<WithdrawMethodModel>?> getWithdrawMethodList() async {
    return await withdrawRepositoryInterface.getWithdrawMethodList();
  }

  @override
  Future<bool> requestWithdraw(Map<String, String> data) async {
    return await withdrawRepositoryInterface.requestWithdraw(data);
  }

  @override
  Future<List<WithdrawModel>?> getWithdrawList() async {
    return await withdrawRepositoryInterface.getWithdrawList();
  }
}



