import 'package:toto_user/common/widgets/hover_widgets/text_hover_widget.dart';
import 'package:toto_user/features/splash/controllers/splash_controller.dart';
import 'package:toto_user/features/splash/domain/models/config_model.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/util/images.dart';
import 'package:toto_user/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:universal_html/html.dart' as html;

class FooterViewWidget extends StatefulWidget {
  final Widget child;
  final double minHeight;
  final bool visibility;
  const FooterViewWidget(
      {super.key,
      required this.child,
      this.minHeight = 0.65,
      this.visibility = true});

  @override
  State<FooterViewWidget> createState() => _FooterViewWidgetState();
}

class _FooterViewWidgetState extends State<FooterViewWidget> {
  final TextEditingController _newsLetterController = TextEditingController();
  final Color _color = Colors.white;
  final ConfigModel? _config = Get.find<SplashController>().configModel;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      ConstrainedBox(
        constraints: BoxConstraints(
            minHeight:
                (widget.visibility && ResponsiveHelper.isDesktop(context))
                    ? MediaQuery.of(context).size.height * widget.minHeight
                    : MediaQuery.of(context).size.height * 0.65),
        child: Align(alignment: Alignment.topCenter, child: widget.child),
      ),
      (widget.visibility && ResponsiveHelper.isDesktop(context))
          ? Container(
              decoration: BoxDecoration(
                color: const Color(0xFF414141), // Fallback color
                image: DecorationImage(
                  image: AssetImage(
                      Images.footerBg), // Replace with your image path
                  fit: BoxFit.cover, // or BoxFit.fill, BoxFit.contain, etc.
                  // opacity: 0.3, // Optional: adjust opacity (0.0 to 1.0)
                ),
              ),
              width: context.width,
              margin: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
              child: Center(
                  child: Column(children: [
                SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 200,
                        width: 400,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset(Images.logowhite,
                                width: 200, height: 60),
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Text(
                                  "Your trusted food delivery partner. Order from your favorite restaurants and get it delivered fresh to your doorstep.",
                                  style: robotoRegular.copyWith(
                                      color: Colors.white,
                                      fontSize: Dimensions.fontSizeSmall)),
                            ),
                            const SizedBox(height: 10),
                            (_config?.appUrlAndroid != null ||
                                    _config?.appUrlIos != null)
                                ? Container(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _config?.appUrlAndroid != null
                                            ? InkWell(
                                                onTap: () => _launchURL(
                                                    _config?.appUrlAndroid ??
                                                        ''),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: Dimensions
                                                          .paddingSizeExtraSmall),
                                                  child: Image.asset(
                                                      Images.landingGooglePlay,
                                                      height: 40,
                                                      fit: BoxFit.contain),
                                                ),
                                              )
                                            : const SizedBox(),
                                        const SizedBox(width: 10),
                                        _config?.appUrlIos != null
                                            ? InkWell(
                                                onTap: () => _launchURL(
                                                    _config?.appUrlIos ?? ''),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: Dimensions
                                                          .paddingSizeExtraSmall),
                                                  child: Image.asset(
                                                      Images.landingAppStore,
                                                      height: 40,
                                                      fit: BoxFit.contain),
                                                ),
                                              )
                                            : const SizedBox(),
                                      ],
                                    ),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ),
                      SizedBox(width: 40),
                      Expanded(
                        flex: 8,
                        child: Padding(
                          padding:
                              const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          child: Container(
                            padding: const EdgeInsets.all(
                                Dimensions.paddingSizeSmall),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(Dimensions.radiusSmall),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Company'.tr,
                                        style: robotoBold.copyWith(
                                            color: _color,
                                            fontSize:
                                                Dimensions.fontSizeSmall)),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeLarge),
                                    FooterButton(
                                        title: 'about_us'.tr,
                                        route:
                                            "https://www.tastyso.com/about-us",
                                        url: true),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                    FooterButton(
                                        title: 'How TastySo Works'.tr,
                                        route:
                                            "https://tastyso.com/how-tastyso-works",
                                        url: true),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                    FooterButton(
                                        title: 'Careers'.tr,
                                        route: "https://tastyso.com/careers",
                                        url: true),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                    FooterButton(
                                        title: 'Team'.tr,
                                        route: "https://tastyso.com/team",
                                        url: true),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Contact Us'.tr,
                                        style: robotoBold.copyWith(
                                            color: _color,
                                            fontSize:
                                                Dimensions.fontSizeSmall)),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                    FooterButton(
                                        title: 'Contact Us'.tr,
                                        route: "https://tastyso.com/contact-us",
                                        url: true),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                    FooterButton(
                                        title: 'Help & Support'.tr,
                                        route:
                                            "https://tastyso.com/help-and-support",
                                        url: true),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                    FooterButton(
                                        title: 'Partner with Us'.tr,
                                        route:
                                            "https://tastyso.com/partner-with-us",
                                        url: true),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                    FooterButton(
                                        title: 'Ride with Us'.tr,
                                        route:
                                            "https://tastyso.com/ride-with-us",
                                        url: true),
                                    // const SizedBox(
                                    //     height: Dimensions.paddingSizeLarge),
                                    // _config!.refundPolicyStatus == 1
                                    //     ? FooterButton(
                                    //         title: 'refund_policy'.tr,
                                    //         route: RouteHelper.getHtmlRoute(
                                    //             'refund-policy'))
                                    //     : const SizedBox(),
                                    // SizedBox(
                                    //     height: _config.refundPolicyStatus == 1
                                    //         ? Dimensions.paddingSizeSmall
                                    //         : 0.0),
                                    // _config.shippingPolicyStatus == 1
                                    //     ? FooterButton(
                                    //         title: 'shipping_policy'.tr,
                                    //         route: RouteHelper.getHtmlRoute(
                                    //             'shipping-policy'))
                                    //     : const SizedBox(),
                                    // SizedBox(
                                    //     height:
                                    //         _config.shippingPolicyStatus == 1
                                    //             ? Dimensions.paddingSizeSmall
                                    //             : 0.0),
                                    // FooterButton(
                                    //     title: 'cancellation_policy'.tr,
                                    //     route: RouteHelper.getHtmlRoute(
                                    //         'cancellation-policy')),
                                    // const SizedBox(
                                    //     height: Dimensions.paddingSizeSmall),
                                    // FooterButton(
                                    //     title: 'privacy_policy'.tr,
                                    //     route: RouteHelper.getHtmlRoute(
                                    //         'privacy-policy')),
                                    // const SizedBox(
                                    //     height: Dimensions.paddingSizeSmall),
                                    // FooterButton(
                                    //     title: 'terms_and_condition'.tr,
                                    //     route: RouteHelper.getHtmlRoute(
                                    //         'terms-and-condition')),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Legal'.tr,
                                        style: robotoBold.copyWith(
                                            color: _color,
                                            fontSize:
                                                Dimensions.fontSizeSmall)),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                    FooterButton(
                                        title: 'Terms & Conditions'.tr,
                                        route:
                                            "https://tastyso.com/terms-and-conditions",
                                        url: true),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                    FooterButton(
                                        title: 'Cookie Policy'.tr,
                                        route:
                                            "https://tastyso.com/cookie-policy",
                                        url: true),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                    FooterButton(
                                        title: 'Privacy Policy'.tr,
                                        route:
                                            "https://tastyso.com/privacy-policy",
                                        url: true),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                    FooterButton(
                                        title: 'Rider Privacy Policy'.tr,
                                        route:
                                            "https://tastyso.com/rider-privacy",
                                        url: true),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                    FooterButton(
                                        title: 'Partner Privacy Policy'.tr,
                                        route:
                                            "https://tastyso.com/partner-privacy",
                                        url: true),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                    FooterButton(
                                        title: 'Security'.tr,
                                        route: "https://tastyso.com/security",
                                        url: true),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                    FooterButton(
                                        title:
                                            'Refund & Cancellation Policy'.tr,
                                        route:
                                            "https://tastyso.com/refund-cancellation",
                                        url: true),
                                    // const SizedBox(
                                    //     height: Dimensions.paddingSizeSmall),
                                    // FooterButton(
                                    //     title: 'live_chat'.tr,
                                    //     route:
                                    //         RouteHelper.getConversationRoute()),
                                    // const SizedBox(
                                    //     height: Dimensions.paddingSizeSmall),
                                    // FooterButton(
                                    //     title: 'my_orders'.tr,
                                    //     route: RouteHelper.getOrderRoute()),
                                    // const SizedBox(
                                    //     height: Dimensions.paddingSizeSmall),
                                    // FooterButton(
                                    //     title: 'help_support'.tr,
                                    //     route: RouteHelper.getSupportRoute()),
                                    // const SizedBox(
                                    //     height: Dimensions.paddingSizeSmall),
                                  ],
                                ),
                                SizedBox(width: 40),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Expanded(
                      //     flex: 4,
                      //     child: Column(
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           const SizedBox(
                      //               height: Dimensions.paddingSizeExtraLarge),
                      //           Row(children: [
                      //             Image.asset(Images.logo,
                      //                 width: 60, height: 40),
                      //             // Image.asset(Images.logoName, height: 40, width: 100),
                      //           ]),
                      //           const SizedBox(
                      //               height: Dimensions.paddingSizeSmall),
                      //           Padding(
                      //             padding: const EdgeInsets.only(left: 10),
                      //             child: Text(
                      //                 'subscribe_to_out_new_channel_to_get_latest_updates'
                      //                     .tr,
                      //                 style: robotoRegular.copyWith(
                      //                     color: _color,
                      //                     fontSize: Dimensions.fontSizeSmall)),
                      //           ),
                      //           const SizedBox(
                      //               height: Dimensions.paddingSizeSmall),
                      //           Padding(
                      //             padding: const EdgeInsets.only(left: 10),
                      //             child: Container(
                      //               width: 300,
                      //               decoration: BoxDecoration(
                      //                 color: Colors.white,
                      //                 borderRadius: BorderRadius.circular(
                      //                     Dimensions.radiusDefault),
                      //                 boxShadow: [
                      //                   BoxShadow(
                      //                       color: Colors.black
                      //                           .withValues(alpha: 0.05),
                      //                       blurRadius: 2)
                      //                 ],
                      //               ),
                      //               child: Row(children: [
                      //                 const SizedBox(width: 20),
                      //                 Expanded(
                      //                     child: TextField(
                      //                   controller: _newsLetterController,
                      //                   expands: false,
                      //                   style: robotoMedium.copyWith(
                      //                       color: Colors.black,
                      //                       fontSize:
                      //                           Dimensions.fontSizeExtraSmall),
                      //                   decoration: InputDecoration(
                      //                       hintText: 'your_email_address'.tr,
                      //                       hintStyle: robotoRegular.copyWith(
                      //                           color: Colors.grey,
                      //                           fontSize: Dimensions
                      //                               .fontSizeExtraSmall),
                      //                       border: InputBorder.none,
                      //                       isCollapsed: true),
                      //                   maxLines: 1,
                      //                 )),
                      //                 GetBuilder<SplashController>(
                      //                     builder: (splashController) {
                      //                   return InkWell(
                      //                     onTap: () {
                      //                       String email = _newsLetterController
                      //                           .text
                      //                           .trim()
                      //                           .toString();
                      //                       if (email.isEmpty) {
                      //                         showCustomSnackBar(
                      //                             'enter_email_address'.tr);
                      //                       } else if (!GetUtils.isEmail(
                      //                           email)) {
                      //                         showCustomSnackBar(
                      //                             'enter_a_valid_email_address'
                      //                                 .tr);
                      //                       } else {
                      //                         Get.find<SplashController>()
                      //                             .subscribeMail(email)
                      //                             .then((value) {
                      //                           if (value) {
                      //                             _newsLetterController.clear();
                      //                           }
                      //                         });
                      //                       }
                      //                     },
                      //                     child: Container(
                      //                       margin: const EdgeInsets.symmetric(
                      //                           horizontal: 2, vertical: 2),
                      //                       decoration: BoxDecoration(
                      //                           color: Theme.of(context)
                      //                               .primaryColor,
                      //                           borderRadius:
                      //                               BorderRadius.circular(
                      //                                   Dimensions
                      //                                       .radiusDefault)),
                      //                       padding: const EdgeInsets.symmetric(
                      //                           horizontal: 10, vertical: 5),
                      //                       child: !splashController.isLoading
                      //                           ? Text('subscribe'.tr,
                      //                               style: robotoRegular.copyWith(
                      //                                   color: Colors.white,
                      //                                   fontSize: Dimensions
                      //                                       .fontSizeExtraSmall))
                      //                           : const SizedBox(
                      //                               height: 15,
                      //                               width: 20,
                      //                               child:
                      //                                   CircularProgressIndicator(
                      //                                       color:
                      //                                           Colors.white)),
                      //                     ),
                      //                   );
                      //                 }),
                      //               ]),
                      //             ),
                      //           ),
                      //           const SizedBox(
                      //               height: Dimensions.paddingSizeExtraSmall),
                      //           GetBuilder<SplashController>(
                      //               builder: (splashController) {
                      //             return Padding(
                      //               padding: const EdgeInsets.only(left: 7),
                      //               child: SizedBox(
                      //                   height: 50,
                      //                   child: ListView.builder(
                      //                     scrollDirection: Axis.horizontal,
                      //                     shrinkWrap: true,
                      //                     physics:
                      //                         const NeverScrollableScrollPhysics(),
                      //                     padding: EdgeInsets.zero,
                      //                     itemCount: splashController
                      //                         .configModel!.socialMedia!.length,
                      //                     itemBuilder: (context, index) {
                      //                       String? name = splashController
                      //                           .configModel!
                      //                           .socialMedia![index]
                      //                           .name;
                      //                       late String icon;
                      //                       if (name == 'facebook') {
                      //                         icon = Images.facebook;
                      //                       } else if (name == 'linkedin') {
                      //                         icon = Images.linkedin;
                      //                       } else if (name == 'youtube') {
                      //                         icon = Images.youtube;
                      //                       } else if (name == 'twitter') {
                      //                         icon = Images.twitter;
                      //                       } else if (name == 'instagram') {
                      //                         icon = Images.instagram;
                      //                       } else if (name == 'pinterest') {
                      //                         icon = Images.pinterest;
                      //                       }
                      //                       return Padding(
                      //                         padding: const EdgeInsets
                      //                             .symmetric(
                      //                             horizontal: Dimensions
                      //                                 .paddingSizeExtraSmall),
                      //                         child: InkWell(
                      //                           onTap: () async {
                      //                             String url = splashController
                      //                                 .configModel!
                      //                                 .socialMedia![index]
                      //                                 .link!;
                      //                             if (!url
                      //                                 .startsWith('https://')) {
                      //                               url = 'https://$url';
                      //                             }
                      //                             url = url.replaceFirst(
                      //                                 'www.', '');
                      //                             if (await canLaunchUrlString(
                      //                                 url)) {
                      //                               _launchURL(url);
                      //                             }
                      //                           },
                      //                           child: Image.asset(icon,
                      //                               height: 30,
                      //                               width: 30,
                      //                               fit: BoxFit.contain),
                      //                         ),
                      //                       );
                      //                     },
                      //                   )),
                      //             );
                      //           }),
                      //         ])),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Divider(
                  thickness: 0.5,
                  color: Theme.of(context).disabledColor,
                  indent: 0,
                  height: 0,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeExtraSmall),
                  color: const Color(0xFF343434),
                  child: Center(
                      child: SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          '© ${_config?.footerText ?? ''}',
                          style: robotoRegular.copyWith(
                              color: _color,
                              fontSize: Dimensions.fontSizeExtraSmall,
                              fontWeight: FontWeight.w100),
                        ),
                      ),
                    ),
                  )),
                ),
              ])),
            )
          : const SizedBox.shrink(),
    ]);
  }

  _launchURL(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class FooterButton extends StatelessWidget {
  final String title;
  final String route;
  final bool url;
  const FooterButton(
      {super.key, required this.title, required this.route, this.url = false});

  @override
  Widget build(BuildContext context) {
    return TextHoverWidget(builder: (hovered) {
      return InkWell(
        hoverColor: Colors.transparent,
        onTap: route.isNotEmpty
            ? () async {
                if (url) {
                  if (kIsWeb) {
                    // For web, use window.open to open in new tab
                    html.window.open(route, '_blank');
                  } else {
                    if (await canLaunchUrlString(route)) {
                      await launchUrlString(route,
                          mode: LaunchMode.externalApplication);
                    }
                  }
                } else {
                  Get.toNamed(route);
                }
              }
            : null,
        child: Text(title,
            style: hovered
                ? robotoMedium.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontSize: Dimensions.fontSizeExtraSmall)
                : robotoRegular.copyWith(
                    color: Theme.of(context).disabledColor,
                    fontSize: Dimensions.fontSizeExtraSmall)),
      );
    });
  }
}
