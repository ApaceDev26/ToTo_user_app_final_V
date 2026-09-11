import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

class ValidateCheck {
  static String? validateEmail(String? value) {
    const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
    final kEmailValid = RegExp(pattern);
    bool isValid = kEmailValid.hasMatch(value.toString());
    if (value!.isEmpty) {
      return 'please_enter_email'.tr;
    } else if (isValid == false) {
      return "enter_valid_email_address".tr;
    }
    // Check if email ends with .com extension
    final emailValue = value.toString().trim().toLowerCase();
    if (!emailValue.endsWith('.com')) {
      return "enter_valid_email_address".tr;
    }
    return null;
  }

  static String? validateEmptyText(String? value, String? message) {
    if (value == null || value.isEmpty) {
      return message?.tr ?? 'this_field_is_required'.tr;
    }
    return null;
  }

  static String? validatePhone(String? value, String? message) {
    if (value == null || value.isEmpty) {
      return message?.tr ?? 'this_field_is_required'.tr;
    } /* else {
      PhoneValid phoneValid = await CustomValidator.isPhoneValid(value);
      if(!phoneValid.isValid) {
        return message?.tr ?? 'invalid_phone_number'.tr;
      }
    }*/
    return null;
  }

  static String? validatePassword(String? value, String? message) {
    if (value == null || value.isEmpty) {
      return message?.tr ?? 'this_field_is_required'.tr;
    } else if (value.length < 8) {
      return 'minimum_password_is_8_character'.tr;
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'please_enter_confirm_password'.tr;
    } else if (value != password) {
      return 'confirm_password_does_not_matched'.tr;
    }
    return null;
  }

  static String? validateName(String? value, String? message) {
    if (value == null || value.isEmpty) {
      return message?.tr ?? 'this_field_is_required'.tr;
    }

    // Check for emojis and special characters using character codes
    for (int i = 0; i < value.length; i++) {
      int charCode = value.codeUnitAt(i);

      // Check for emoji ranges (simplified check)
      if ((charCode >= 0x1F600 && charCode <= 0x1F64F) || // Emoticons
          (charCode >= 0x1F300 && charCode <= 0x1F5FF) || // Misc Symbols
          (charCode >= 0x1F680 && charCode <= 0x1F6FF) || // Transport
          (charCode >= 0x2600 && charCode <= 0x26FF) || // Misc symbols
          (charCode >= 0x2700 && charCode <= 0x27BF)) {
        // Dingbats
        return 'name_cannot_contain_emoji'.tr;
      }

      // Check for other special characters (excluding allowed ones)
      String char = value[i];
      bool isAllowed =
          (char.codeUnitAt(0) >= 65 && char.codeUnitAt(0) <= 90) || // A-Z
              (char.codeUnitAt(0) >= 97 && char.codeUnitAt(0) <= 122) || // a-z
              (char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57) || // 0-9
              char == ' ' ||
              char == '-' ||
              char == '.' ||
              char == "'";

      if (!isAllowed) {
        return 'name_cannot_contain_special_characters'.tr;
      }
    }

    return null;
  }

  static String? loyaltyCheck(
      String? value, int? minimumExchangePoint, int? point) {
    int amount = 0;
    if (value != null && value.isNotEmpty) {
      amount = int.parse(value);
    }
    if (value == null || value.isEmpty) {
      return 'this_field_is_required'.tr;
    } else if (amount < minimumExchangePoint!) {
      return '${'please_exchange_more_then'.tr} $minimumExchangePoint ${'points'.tr}';
    } else if (point! < amount) {
      return 'you_do_not_have_enough_point_to_exchange'.tr;
    }
    return null;
  }

  static String getValidPhone(String number, {bool withCountryCode = false}) {
    bool isValid = false;
    String phone = "";

    try {
      PhoneNumber phoneNumber = PhoneNumber.parse(number);
      isValid = phoneNumber.isValid(type: PhoneNumberType.mobile);
      if (isValid) {
        phone = withCountryCode
            ? "+${phoneNumber.countryCode}${phoneNumber.nsn}"
            : phoneNumber.nsn.toString();
        if (kDebugMode) {
          print("Phone Number : $phone");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return phone;
  }
}
