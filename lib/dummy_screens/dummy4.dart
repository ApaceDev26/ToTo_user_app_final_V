import 'package:flutter/material.dart';
import 'package:toto_user/common/widgets/custom_app_bar_widget.dart';

class DummyProfile extends StatelessWidget {
  const DummyProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
        title: "Profile",
        isBackButtonExist: false,
      ),
      body: const Center(
        child: Text(
          'Profile',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
