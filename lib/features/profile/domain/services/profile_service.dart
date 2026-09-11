import 'package:toto_user/common/models/response_model.dart';
import 'package:toto_user/features/profile/domain/models/update_user_model.dart';
import 'package:toto_user/features/profile/domain/models/userinfo_model.dart';
import 'package:toto_user/features/profile/domain/repositories/profile_repository_interface.dart';
import 'package:toto_user/features/profile/domain/services/profile_service_interface.dart';
import 'package:toto_user/common/widgets/custom_snackbar_widget.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileService implements ProfileServiceInterface {
  final ProfileRepositoryInterface profileRepositoryInterface;
  ProfileService({required this.profileRepositoryInterface});

  @override
  Future<UserInfoModel?> getUserInfo() async {
    return await profileRepositoryInterface.get(null);
  }

  @override
  Future<ResponseModel> updateProfile(UpdateUserModel userInfoModel, XFile? data, String token) async {
    return await profileRepositoryInterface.updateProfile(userInfoModel, data, token);
  }

  @override
  Future<ResponseModel> changePassword(UserInfoModel userInfoModel) async {
    return profileRepositoryInterface.changePassword(userInfoModel);
  }

  @override
  Future<XFile?> pickImageFromGallery() async {
    XFile? pickedFile;
    XFile? pickLogo = await ImagePicker().pickImage(source: ImageSource.gallery);
    if(pickLogo != null) {
      const int maxSizeInBytes = 5 * 1024 * 1024; // 5MB
      await pickLogo.length().then((value) {
        if(value > maxSizeInBytes) {
          showCustomSnackBar('please_upload_lower_size_file'.tr);
        }else {
          pickedFile = pickLogo;
        }
      });
    }
    return pickedFile;
  }

  @override
  Future<Response> deleteUser() async {
    return await profileRepositoryInterface.delete(null);
  }

  @override
  Future<Response> deleteUserWithOtp(String? otp) async {
    // Use dynamic cast to access the method
    try {
      return await (profileRepositoryInterface as dynamic).deleteUserWithOtp(otp);
    } catch (e) {
      // Fallback to regular delete if method doesn't exist
      return await profileRepositoryInterface.delete(null);
    }
  }

}