class WithdrawModel {
  int? id;
  double? amount;
  String? updatedAt;
  String? status;
  String? bankName;
  String? requestedAt;
  Map<String, dynamic>? detail;

  WithdrawModel({
    this.id,
    this.amount,
    this.updatedAt,
    this.status,
    this.bankName,
    this.requestedAt,
    this.detail,
  });

  WithdrawModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    amount = json['amount']?.toDouble();
    updatedAt = json['updated_at'];
    status = json['status'];
    bankName = json['bank_name'];
    requestedAt = json['requested_at'];
    detail = json['detail'] != null ? Map<String, dynamic>.from(json['detail']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['amount'] = amount;
    data['updated_at'] = updatedAt;
    data['status'] = status;
    data['bank_name'] = bankName;
    data['requested_at'] = requestedAt;
    data['detail'] = detail;
    return data;
  }
}



