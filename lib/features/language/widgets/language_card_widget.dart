import 'package:flutter/material.dart';
import 'package:toto_user/common/widgets/custom_ink_well_widget.dart';
import 'package:toto_user/features/language/controllers/localization_controller.dart';
import 'package:toto_user/features/language/domain/models/language_model.dart';
import 'package:toto_user/util/app_constants.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/util/styles.dart';

class LanguageCardWidget extends StatelessWidget {
  final LanguageModel languageModel;
  final LocalizationController localizationController;
  final int index;
  final bool fromBottomSheet;
  final bool fromWeb;
  const LanguageCardWidget(
      {super.key,
      required this.languageModel,
      required this.localizationController,
      required this.index,
      this.fromBottomSheet = false,
      this.fromWeb = false});

  @override
  Widget build(BuildContext context) {
    return CustomInkWellWidget(
      onTap: () {
        if (fromBottomSheet) {
          localizationController.setLanguage(
              Locale(
                AppConstants.languages[index].languageCode!,
                AppConstants.languages[index].countryCode,
              ),
              fromBottomSheet: fromBottomSheet);
        }
        localizationController.setSelectLanguageIndex(index);
      },
      radius: Dimensions.radiusLarge,
      child: Container(
        height: 70,
        width: double.infinity,
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: !fromWeb
            ? BoxDecoration(
                color: localizationController.selectedLanguageIndex == index
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.05)
                    : null,
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                border: localizationController.selectedLanguageIndex == index
                    ? Border.all(
                        color: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.2))
                    : null,
              )
            : BoxDecoration(
                color: localizationController.selectedLanguageIndex == index
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.05)
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                border: Border.all(
                    color: localizationController.selectedLanguageIndex == index
                        ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
                        : Theme.of(context)
                            .disabledColor
                            .withValues(alpha: 0.3)),
              ),
            //  margin: !fromWeb ? EdgeInsets.only(bottom: 10): EdgeInsets.only(bottom: 0),
        child: !fromWeb ? 
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          Image.asset(languageModel.imageUrl!, width: 36, height: 36),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text(languageModel.languageName!,
                  style:
                      robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),
          localizationController.selectedLanguageIndex == index
              ? Icon(Icons.check_circle,
                  color: Theme.of(context).primaryColor, size: 25)
              : const SizedBox(),
        ])
        : Row(children: [
          Image.asset(languageModel.imageUrl!, width: 46, height: 46),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Text(languageModel.languageName!,
              style:
                  robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),
          const Spacer(),
          localizationController.selectedLanguageIndex == index
              ? Icon(Icons.check_circle,
                  color: Theme.of(context).primaryColor, size: 25)
              : const SizedBox(),
        ]),
      ),
    );
  }
}
