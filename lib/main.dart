import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:host_app/helper/app_binding.dart';
import 'package:host_app/helper/app_colors.dart';
import 'package:host_app/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: AppBinding(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.mainColor),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
