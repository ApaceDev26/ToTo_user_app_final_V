import 'package:toto_user/design_system/app_typography.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:flutter/material.dart';

/// Legacy aliases → Lumen Atelier (Noto Serif Bengali). Prefer [AppTypography].
TextStyle get robotoRegular => AppTypography.bodyMd().copyWith(
      fontSize: Dimensions.fontSizeDefault,
      fontWeight: FontWeight.w400,
    );

TextStyle get robotoMedium => AppTypography.bodyMd().copyWith(
      fontSize: Dimensions.fontSizeDefault,
      fontWeight: FontWeight.w500,
    );

TextStyle get robotoBold => AppTypography.bodyMd().copyWith(
      fontSize: Dimensions.fontSizeDefault,
      fontWeight: FontWeight.w700,
    );

TextStyle get robotoBlack => AppTypography.bodyMd().copyWith(
      fontSize: Dimensions.fontSizeDefault,
      fontWeight: FontWeight.w900,
    );
