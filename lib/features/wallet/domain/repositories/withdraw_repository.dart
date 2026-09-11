import 'package:toto_user/api/api_client.dart';
import 'package:toto_user/features/wallet/domain/models/withdraw_model.dart';
import 'package:toto_user/features/wallet/domain/models/withdraw_method_model.dart';
import 'package:toto_user/features/wallet/domain/repositories/withdraw_repository_interface.dart';
import 'package:toto_user/util/app_constants.dart';
import 'package:get/get_connect/connect.dart';

class WithdrawRepository implements WithdrawRepositoryInterface {
  final ApiClient apiClient;

  WithdrawRepository({required this.apiClient});

  @override
  Future<List<WithdrawMethodModel>?> getWithdrawMethodList() async {
    List<WithdrawMethodModel>? withdrawMethodList;
    Response response = await apiClient.getData(AppConstants.withdrawMethodListUri);
    if (response.statusCode == 200) {
      withdrawMethodList = [];
      response.body.forEach((method) {
        withdrawMethodList!.add(WithdrawMethodModel.fromJson(method));
      });
    }
    return withdrawMethodList;
  }

  @override
  Future<bool> requestWithdraw(Map<String, String> data) async {
    Response response = await apiClient.postData(AppConstants.withdrawRequestUri, data);
    return (response.statusCode == 200);
  }

  @override
  Future<List<WithdrawModel>?> getWithdrawList() async {
    List<WithdrawModel>? withdrawList = [];
    Response response = await apiClient.getData(AppConstants.withdrawListUri);
    if (response.statusCode == 200) {
      response.body.forEach((withdraw) {
        WithdrawModel withdrawModel = WithdrawModel.fromJson(withdraw);
        withdrawList.add(withdrawModel);
      });
    }
    return withdrawList;
  }

  @override
  Future<dynamic> getList({int? offset}) async {
    return await getWithdrawList();
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }
}
