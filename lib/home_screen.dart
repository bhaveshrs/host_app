import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:host_app/connection_controller.dart';
import 'package:host_app/helper/app_colors.dart';
import 'package:host_app/widgets/button.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ConnectionController connectionController =
      Get.find<ConnectionController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
            child: Column(
              children: [
                PrimaryButton(
                  onPressed: () {
                    connectionController.p2pCreateGroup();
                  },
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.mainColor,
                  title: "Make connection",
                  isLoading: false,
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          connectionController.checkAndEnableServices(
                              location: true);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: connectionController.locationEnable.value
                                  ? Colors.green.withOpacity(0.5)
                                  : Colors.red.withOpacity(0.5)),
                          child: Text(
                              "Location :${connectionController.locationEnable.value ? "Enable" : "Disable"}"),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          connectionController.checkAndEnableServices(
                              wifi: true);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: connectionController.wifiEnable.value
                                  ? Colors.green.withOpacity(0.5)
                                  : Colors.red.withOpacity(0.5)),
                          child: Text(
                              "wifi :${connectionController.wifiEnable.value ? "Enable" : "Disable"}"),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                PrimaryButton(
                  onPressed: () {
                    connectionController.p2pRestartConnection();
                  },
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.mainColor,
                  title: "restart connection",
                  isLoading: false,
                ),
                const SizedBox(
                  height: 10,
                ),
                PrimaryButton(
                  onPressed: () {
                    connectionController.p2pRemoveGroup();
                  },
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.mainColor,
                  title: "stop connection",
                  isLoading: false,
                ),
                if (connectionController.wifiP2PInfo.value?.isConnected ??
                    false) ...[
                  const SizedBox(
                    height: 10,
                  ),
                  PrimaryButton(
                    onPressed: () {
                      connectionController.sendMessage("show images");
                    },
                    foregroundColor: Colors.white,
                    backgroundColor: AppColors.mainColor,
                    title: "show images",
                    isLoading: false,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  PrimaryButton(
                    onPressed: () {
                      connectionController.sendMessage("show video");
                    },
                    foregroundColor: Colors.white,
                    backgroundColor: AppColors.mainColor,
                    title: "show video",
                    isLoading: false,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  PrimaryButton(
                    onPressed: () {
                      connectionController.sendMessage("show pdf");
                    },
                    foregroundColor: Colors.white,
                    backgroundColor: AppColors.mainColor,
                    title: "show pdf",
                    isLoading: false,
                  ),
                ],
                if (connectionController.isDiscoveryLoading.value) ...[
                  const Spacer(),
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: RippleAnimation(
                      color: AppColors.mainColor,
                      delay: Duration(milliseconds: 300),
                      repeat: true,
                      minRadius: 75,
                      ripplesCount: 6,
                      duration: Duration(milliseconds: 6 * 300),
                      child: Icon(
                        Icons.wifi,
                        size: 60,
                        color: AppColors.mainColor,
                      ),
                    ),
                  )
                ]
              ],
            ),
          ),
        );
      }),
    );
  }
}
