import 'package:flutter/material.dart';
import 'package:toto_user/common/widgets/custom_app_bar_widget.dart';

class Dummy3 extends StatelessWidget {
  const Dummy3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: "Cart", isBackButtonExist: false,),
      body: const Center(
        child: Text(
          'Cart',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
