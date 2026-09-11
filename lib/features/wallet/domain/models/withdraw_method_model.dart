class WithdrawMethodModel {
  int? id;
  String? methodName;
  List<MethodField>? methodFields;
  int? isActive;

  WithdrawMethodModel({
    this.id,
    this.methodName,
    this.methodFields,
    this.isActive,
  });

  WithdrawMethodModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    methodName = json['method_name'];
    isActive = json['is_active'];
    if (json['method_fields'] != null) {
      methodFields = <MethodField>[];
      if (json['method_fields'] is List) {
        json['method_fields'].forEach((v) {
          methodFields!.add(MethodField.fromJson(Map<String, dynamic>.from(v)));
        });
      } else if (json['method_fields'] is Map) {
        // Handle if it comes as a map
        json['method_fields'].forEach((key, value) {
          if (value is Map) {
            methodFields!.add(MethodField.fromJson(Map<String, dynamic>.from(value)));
          }
        });
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['method_name'] = methodName;
    data['is_active'] = isActive;
    if (methodFields != null) {
      data['method_fields'] = methodFields!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MethodField {
  String? inputName;
  String? inputType;
  String? placeholder;
  int? isRequired;

  MethodField({
    this.inputName,
    this.inputType,
    this.placeholder,
    this.isRequired,
  });

  MethodField.fromJson(Map<String, dynamic> json) {
    inputName = json['input_name'];
    inputType = json['input_type'];
    placeholder = json['placeholder'];
    isRequired = json['is_required'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['input_name'] = inputName;
    data['input_type'] = inputType;
    data['placeholder'] = placeholder;
    data['is_required'] = isRequired;
    return data;
  }
}
