import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toto_user/api/api_client.dart';
import 'package:toto_user/common/models/product_model.dart';
import 'package:toto_user/common/widgets/custom_snackbar_widget.dart';
import 'package:toto_user/common/widgets/in_app_message_dialog.dart';
import 'package:toto_user/common/widgets/product_bottom_sheet_widget.dart';
import 'package:toto_user/features/auth/controllers/auth_controller.dart';
import 'package:toto_user/features/location/controllers/location_controller.dart';
import 'package:toto_user/features/product/controllers/product_controller.dart';
import 'package:toto_user/helper/address_helper.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/helper/route_helper.dart';
import 'package:toto_user/util/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class InAppMessagingHelper {
  static const String _seenMessagesKey = 'seen_in_app_messages';
  static const String _messageDisplayCountKey = 'in_app_message_display_count_';

  // Track currently displaying messages to prevent duplicates
  static final Set<int> _currentlyDisplayingMessages = <int>{};
  // Lock to prevent concurrent fetching
  static bool _isFetching = false;
  static Completer<void>? _fetchCompleter;
  // Timer for periodic immediate message checks
  static Timer? _immediateMessageTimer;

  /// Initialize In-App Messaging (placeholder for future Firebase integration)
  static Future<void> initialize() async {
    try {
      startImmediateMessagePolling();
    } catch (e) {
      debugPrint('Error initializing In-App Messaging: $e');
    }
  }

  /// Start periodic polling for immediate messages
  static void startImmediateMessagePolling() {
    // Stop any existing timer
    stopImmediateMessagePolling();

    // Check immediately first (with a small delay to ensure controllers are ready)
    Future.delayed(const Duration(milliseconds: 500), () {
      checkForImmediateMessages();
    });

    // Then check every 3 seconds for immediate messages (aggressive polling for faster response)
    _immediateMessageTimer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) {
        checkForImmediateMessages();
      },
    );
  }

  /// Stop periodic polling for immediate messages
  static void stopImmediateMessagePolling() {
    _immediateMessageTimer?.cancel();
    _immediateMessageTimer = null;
  }

  /// Check specifically for immediate messages (without screen filter)
  static Future<void> checkForImmediateMessages() async {
    try {
      // Prevent concurrent fetching - if already fetching, wait for it to complete
      if (_isFetching) {
        if (_fetchCompleter != null) {
          await _fetchCompleter!.future;
        }
        return;
      }

      _isFetching = true;
      _fetchCompleter = Completer<void>();

      try {
        // Check if required controllers are registered before using them
        if (!Get.isRegistered<AuthController>()) {
          _isFetching = false;
          _fetchCompleter?.complete();
          _fetchCompleter = null;
          return;
        }

        if (!Get.isRegistered<ApiClient>()) {
          _isFetching = false;
          _fetchCompleter?.complete();
          _fetchCompleter = null;
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        final authController = Get.find<AuthController>();

        // Determine user type
        String userType = 'all';
        String? guestId;
        if (authController.isLoggedIn()) {
          userType = 'customer';
        } else if (authController.isGuestLoggedIn()) {
          userType = 'guest';
          guestId = authController.getGuestId();
        }

        // Build query parameters - don't include screen to get immediate messages
        final Map<String, String> queryParams = {
          'user_type': userType,
        };
        if (guestId != null && guestId.isNotEmpty) {
          queryParams['guest_id'] = guestId;
        }

        final int? resolvedZoneId = _resolveZoneId(null);
        if (resolvedZoneId != null && resolvedZoneId > 0) {
          queryParams['zone_id'] = resolvedZoneId.toString();
        }

        // Make API call
        final ApiClient apiClient = Get.find<ApiClient>();
        final response = await apiClient.getData(
          '${AppConstants.inAppMessageUri}?${Uri(queryParameters: queryParams).query}',
        );

        if (response.statusCode == 200 &&
            response.body['status'] == 'success') {
          final List<dynamic> messages = response.body['messages'] ?? [];

          final immediateMessages = messages.where((msg) {
            return msg['trigger_type'] == 'immediate';
          }).toList();

          if (immediateMessages.isNotEmpty) {
            for (var messageData in immediateMessages) {
              await _displayMessageIfNeeded(messageData, prefs);
            }
          }
        } else {
          debugPrint(
              '⚠️ checkForImmediateMessages API response: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        debugPrint('❌ Error checking for immediate messages: $e');
      } finally {
        _isFetching = false;
        _fetchCompleter?.complete();
        _fetchCompleter = null;
      }
    } catch (e) {
      debugPrint('❌ Error in checkForImmediateMessages: $e');
      _isFetching = false;
      _fetchCompleter?.complete();
      _fetchCompleter = null;
    }
  }

  /// Fetch and display active in-app messages
  static Future<void> fetchAndDisplayMessages({
    String? screen,
    int? zoneId,
  }) async {
    // Prevent concurrent fetching - if already fetching, wait for it to complete
    if (_isFetching) {
      if (_fetchCompleter != null) {
        await _fetchCompleter!.future;
      }
      return;
    }

    _isFetching = true;
    _fetchCompleter = Completer<void>();

    try {
      final prefs = await SharedPreferences.getInstance();
      final authController = Get.find<AuthController>();

      // Determine user type
      String userType = 'all';
      String? guestId;
      if (authController.isLoggedIn()) {
        userType = 'customer';
      } else if (authController.isGuestLoggedIn()) {
        userType = 'guest';
        guestId = authController.getGuestId();
      }

      // Build query parameters
      final Map<String, String> queryParams = {
        'user_type': userType,
      };
      if (guestId != null && guestId.isNotEmpty) {
        queryParams['guest_id'] = guestId;
      }
      if (screen != null) {
        queryParams['screen'] = screen;
      }

      final int? resolvedZoneId = _resolveZoneId(zoneId);
      if (resolvedZoneId != null && resolvedZoneId > 0) {
        queryParams['zone_id'] = resolvedZoneId.toString();
      }

      // Make API call
      final ApiClient apiClient = Get.find<ApiClient>();
      final response = await apiClient.getData(
        '${AppConstants.inAppMessageUri}?${Uri(queryParameters: queryParams).query}',
      );

      if (response.statusCode == 200 && response.body['status'] == 'success') {
        final List<dynamic> messages = response.body['messages'] ?? [];

        for (var messageData in messages) {
          await _displayMessageIfNeeded(messageData, prefs);
        }
      } else {
        debugPrint(
            '⚠️ fetchAndDisplayMessages API response: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching in-app messages: $e');
    } finally {
      _isFetching = false;
      _fetchCompleter?.complete();
      _fetchCompleter = null;
    }
  }

  /// Display message if it hasn't been shown too many times
  static Future<void> _displayMessageIfNeeded(
    Map<String, dynamic> messageData,
    SharedPreferences prefs,
  ) async {
    try {
      final int messageId = messageData['id'];
      final int displayCount = messageData['display_count'] ?? 1;
      final String triggerType = messageData['trigger_type'] ?? 'on_app_open';

      if (_currentlyDisplayingMessages.contains(messageId)) {
        return;
      }

      // IMMEDIATE: Show only ONCE ever (one-time urgent notification)
      if (triggerType == 'immediate') {
        // Check if this immediate message has ever been shown
        final String seenKey = '${_seenMessagesKey}_immediate_${messageId}';
        final bool hasBeenShown = prefs.getBool(seenKey) ?? false;

        if (hasBeenShown) {
          return;
        }

        await prefs.setBool(seenKey, true);
        _currentlyDisplayingMessages.add(messageId);

        await Future.delayed(const Duration(milliseconds: 300));
        await _showInAppMessageDialog(messageData);

        _currentlyDisplayingMessages.remove(messageId);
        return;
      }

      // ON_APP_OPEN and ON_SPECIFIC_SCREEN: Check display count and caching
      if (triggerType == 'on_app_open' || triggerType == 'on_specific_screen') {
        // Check how many times this message has been displayed
        final String countKey = '$_messageDisplayCountKey$messageId';
        final int currentCount = prefs.getInt(countKey) ?? 0;

        if (currentCount < displayCount) {
          final String seenKey = '${_seenMessagesKey}_${messageId}';
          final bool wasSeenRecently = prefs.getBool(seenKey) ?? false;

          if (!wasSeenRecently) {
            await prefs.setBool(seenKey, true);
            await prefs.setInt(countKey, currentCount + 1);
            _currentlyDisplayingMessages.add(messageId);

            await _showInAppMessageDialog(messageData);

            _currentlyDisplayingMessages.remove(messageId);
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error displaying in-app message: $e');
      // Make sure to remove from set even if there's an error
      final int messageId = messageData['id'];
      _currentlyDisplayingMessages.remove(messageId);
    }
  }

  /// Show in-app message as a dialog
  static Future<void> _showInAppMessageDialog(
    Map<String, dynamic> messageData,
  ) async {
    try {
      final String title = messageData['title'] ?? '';
      final String body = messageData['body'] ?? '';
      final String? imageUrl = messageData['image'];
      final String? buttonText = messageData['button_text'];
      Future<void> Function()? buttonAction;
      if (buttonText != null && buttonText.isNotEmpty) {
        buttonAction = () async {
          await _handleButtonAction(messageData);
        };
      }

      await Get.dialog(
        InAppMessageDialog(
          title: title,
          body: body,
          imageUrl: imageUrl,
          buttonText: buttonText,
          onButtonTap: buttonAction,
        ),
        barrierDismissible: true,
      );
    } catch (e) {
      debugPrint('Error showing in-app message dialog: $e');
    }
  }

  static Future<void> _handleButtonAction(
    Map<String, dynamic> messageData,
  ) async {
    try {
      final String actionType = messageData['action_type'] ?? 'external_url';
      final dynamic rawActionId = messageData['action_id'];
      final int? actionId =
          rawActionId is int ? rawActionId : int.tryParse('$rawActionId');

      if (actionType == 'restaurant' && actionId != null) {
        await Get.toNamed(RouteHelper.getRestaurantRoute(actionId));
      } else if (actionType == 'food' && actionId != null) {
        final productController = Get.find<ProductController>();
        Product? product =
            await productController.getProductDetails(actionId, null);
        if (product != null) {
          final context = Get.context;
          if (context == null) {
            showCustomSnackBar('sorry_something_went_wrong'.tr);
            return;
          }
          if (ResponsiveHelper.isMobile(context)) {
            await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (con) => ProductBottomSheetWidget(
                product: product,
                fromReview: true,
              ),
            );
          } else {
            await showDialog(
              context: context,
              builder: (con) => Dialog(
                child: ProductBottomSheetWidget(
                  product: product,
                  fromReview: true,
                ),
              ),
            );
          }
        } else {
          showCustomSnackBar('sorry_something_went_wrong'.tr);
        }
      } else if (actionType == 'external_url') {
        final String? urlString = messageData['button_url'];
        if (urlString != null && urlString.isNotEmpty) {
          final Uri url = Uri.parse(urlString);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            showCustomSnackBar('sorry_something_went_wrong'.tr);
          }
        }
      }
    } catch (e) {
      debugPrint('Error handling in-app message action: $e');
    }
  }

  /// Clear seen messages (call this on app restart or after a certain period)
  static Future<void> clearSeenMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (String key in keys) {
        if (key.startsWith(_seenMessagesKey)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      debugPrint('Error clearing seen messages: $e');
    }
  }

  /// Trigger message fetch for specific screen
  static Future<void> triggerForScreen(String screen, {int? zoneId}) async {
    await fetchAndDisplayMessages(screen: screen, zoneId: zoneId);
  }

  static int? _resolveZoneId(int? explicitZoneId) {
    if (explicitZoneId != null && explicitZoneId > 0) {
      return explicitZoneId;
    }

    final address = AddressHelper.getAddressFromSharedPref();
    if (address != null && (address.zoneId ?? 0) > 0) {
      return address.zoneId;
    }

    if (Get.isRegistered<LocationController>()) {
      final locationController = Get.find<LocationController>();
      if (locationController.zoneID > 0) {
        return locationController.zoneID;
      }
    }
    return null;
  }
}
