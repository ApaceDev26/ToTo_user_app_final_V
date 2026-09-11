import 'package:flutter/material.dart';
import 'package:toto_user/common/widgets/custom_app_bar_widget.dart';

class Dummy2 extends StatelessWidget {
  const Dummy2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: "Order", isBackButtonExist: false,),
      body: const Center(
        child: Text(
          'Order',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
