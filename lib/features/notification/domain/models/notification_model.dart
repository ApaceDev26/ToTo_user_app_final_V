import 'dart:convert';

class NotificationModel {
  int? id;
  Data? data;
  String? createdAt;
  String? updatedAt;
  String? imageFullUrl;

  NotificationModel({
    this.id,
    this.data,
    this.createdAt,
    this.updatedAt,
    this.imageFullUrl,
  });

  NotificationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    if (json['data'] != null) {
      if (json['data'] is String) {
        try {
          final decoded = jsonDecode(json['data']);
          if (decoded is Map<String, dynamic>) {
            data = Data.fromJson(decoded);
          }
        } catch (_) {}
      } else if (json['data'] is Map<String, dynamic>) {
        data = Data.fromJson(json['data']);
      } else if (json['data'] is Map) {
        data = Data.fromJson(Map<String, dynamic>.from(json['data']));
      }
    }
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
    imageFullUrl = json['image_full_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['image_full_url'] = imageFullUrl;
    return data;
  }
}

class Data {
  String? title;
  String? description;
  String? type;
  dynamic orderId;
  String? orderStatus;
  String? amount;

  Data({
    this.title,
    this.description,
    this.type,
    this.orderId,
    this.orderStatus,
    this.amount,
  });

  Data.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    type = json['type'];
    orderId = json['order_id'];
    orderStatus = json['order_status'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['description'] = description;
    data['type'] = type;
    data['order_id'] = orderId;
    data['order_status'] = orderStatus;
    data['amount'] = amount;
    return data;
  }
}
