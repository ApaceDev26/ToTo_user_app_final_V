import 'package:toto_user/common/enums/data_source_enum.dart';
import 'package:toto_user/common/models/product_model.dart';
import 'package:toto_user/common/models/response_model.dart';
import 'package:toto_user/common/models/review_model.dart';
import 'package:toto_user/features/order/domain/models/order_details_model.dart';
import 'package:toto_user/features/product/domain/models/review_body_model.dart';
import 'package:toto_user/features/review/domain/services/review_service_interface.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReviewController extends GetxController implements GetxService {
  final ReviewServiceInterface reviewServiceInterface;

  ReviewController({required this.reviewServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<int> _ratingList = [];
  List<int> get ratingList => _ratingList;

  List<String> _reviewList = [];
  List<String> get reviewList => _reviewList;

  List<bool> _loadingList = [];
  List<bool> get loadingList => _loadingList;

  List<bool> _submitList = [];
  List<bool> get submitList => _submitList;

  int _deliveryManRating = 0;
  int get deliveryManRating => _deliveryManRating;

  String _reviewedType = 'all';
  String get reviewType => _reviewedType;

  List<Product>? _reviewedProductList;
  List<Product>? get reviewedProductList => _reviewedProductList;

  List<ReviewModel>? _restaurantReviewList;
  List<ReviewModel>? get restaurantReviewList => _restaurantReviewList;

  // Store existing product reviews by product id
  Map<int, ReviewModel> _existingProductReviews = {};
  Map<int, ReviewModel> get existingProductReviews => _existingProductReviews;

  // Store existing delivery man review
  ReviewModel? _existingDeliveryManReview;
  ReviewModel? get existingDeliveryManReview => _existingDeliveryManReview;

  void initRatingData(List<OrderDetailsModel> orderDetailsList) {
    _ratingList = [];
    _reviewList = [];
    _loadingList = [];
    _submitList = [];
    _deliveryManRating = 0;
    _existingProductReviews = {};
    _existingDeliveryManReview = null;
    for (var orderDetails in orderDetailsList) {
      debugPrint('$orderDetails');
      _ratingList.add(0);
      _reviewList.add('');
      _loadingList.add(false);
      _submitList.add(false);
    }
  }

  Future<void> loadExistingProductReviews(
      List<OrderDetailsModel> orderDetailsList) async {
    _existingProductReviews = {};
    if (orderDetailsList.isEmpty) return;

    int orderId = orderDetailsList[0].orderId ?? 0;
    for (int index = 0; index < orderDetailsList.length; index++) {
      var orderDetail = orderDetailsList[index];
      if (orderDetail.foodDetails?.id != null) {
        try {
          List<ReviewModel>? reviews =
              await reviewServiceInterface.getProductReviewsByFoodId(
            orderDetail.foodDetails!.id.toString(),
          );
          if (reviews != null && reviews.isNotEmpty) {
            // Find review for this specific order and product
            ReviewModel? reviewForOrder;
            try {
              reviewForOrder = reviews.firstWhere(
                (review) =>
                    review.foodId == orderDetail.foodDetails!.id &&
                    review.orderId == orderId,
              );
            } catch (e) {
              // No review found for this order
            }
            if (reviewForOrder != null) {
              _existingProductReviews[orderDetail.foodDetails!.id!] =
                  reviewForOrder;
              // Mark as submitted if review exists
              if (index < _submitList.length) {
                _submitList[index] = true;
                _ratingList[index] = reviewForOrder.rating ?? 0;
                _reviewList[index] = reviewForOrder.comment ?? '';
              }
            }
          }
        } catch (e) {
          debugPrint(
              'Error loading review for product ${orderDetail.foodDetails!.id}: $e');
        }
      }
    }
    update();
  }

  Future<void> loadExistingDeliveryManReview(
      String orderId, int? deliveryManId) async {
    _existingDeliveryManReview = null;
    if (deliveryManId != null) {
      try {
        List<ReviewModel>? reviews =
            await reviewServiceInterface.getDeliveryManReviewsByDeliveryManId(
          deliveryManId.toString(),
        );
        if (reviews != null && reviews.isNotEmpty) {
          // Find review for this specific order
          int orderIdInt = int.tryParse(orderId) ?? 0;
          ReviewModel? reviewForOrder;
          try {
            reviewForOrder = reviews.firstWhere(
              (review) =>
                  review.orderId == orderIdInt &&
                  review.deliveryManId == deliveryManId,
            );
          } catch (e) {
            // No review found for this order
          }
          if (reviewForOrder != null) {
            _existingDeliveryManReview = reviewForOrder;
            _deliveryManRating = reviewForOrder.rating ?? 0;
          }
        }
      } catch (e) {
        debugPrint('Error loading delivery man review: $e');
      }
    }
    update();
  }

  void setRating(int index, int rate) {
    _ratingList[index] = rate;
    update();
  }

  void setReview(int index, String review) {
    _reviewList[index] = review;
  }

  void setDeliveryManRating(int rate) {
    _deliveryManRating = rate;
    update();
  }

  Future<void> getReviewedProductList(bool reload, String type, bool notify,
      {DataSourceEnum dataSource = DataSourceEnum.local,
      bool fromRecall = false}) async {
    _reviewedType = type;
    if (reload && !fromRecall) {
      _reviewedProductList = null;
    }
    if (notify) {
      update();
    }
    List<Product>? reviewedProductList;
    if (_reviewedProductList == null || reload || fromRecall) {
      if (dataSource == DataSourceEnum.local) {
        reviewedProductList = await reviewServiceInterface
            .getReviewedProductList(type: type, source: DataSourceEnum.local);
        _prepareReviewedProductList(reviewedProductList);
        getReviewedProductList(false, type, false,
            dataSource: DataSourceEnum.client, fromRecall: true);
      } else {
        reviewedProductList = await reviewServiceInterface
            .getReviewedProductList(type: type, source: DataSourceEnum.client);
        _prepareReviewedProductList(reviewedProductList);
      }
    }
  }

  _prepareReviewedProductList(List<Product>? reviewedProductList) {
    if (reviewedProductList != null) {
      _reviewedProductList = [];
      _reviewedProductList = reviewedProductList;
    }
    update();
  }

  Future<ResponseModel> submitReview(
      int index, ReviewBodyModel reviewBody) async {
    _loadingList[index] = true;
    update();

    ResponseModel responseModel =
        await reviewServiceInterface.submitProductReview(reviewBody);
    if (responseModel.isSuccess) {
      _submitList[index] = true;
      update();
    }
    _loadingList[index] = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> submitDeliveryManReview(
      ReviewBodyModel reviewBody) async {
    _isLoading = true;
    update();

    ResponseModel responseModel =
        await reviewServiceInterface.submitDeliverymanReview(reviewBody);
    if (responseModel.isSuccess) {
      _deliveryManRating = 0;
      update();
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<void> getRestaurantReviewList(String? restaurantID) async {
    _restaurantReviewList =
        await reviewServiceInterface.getRestaurantReviewList(restaurantID);

    update();
  }
}
