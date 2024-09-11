import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';
import 'package:get/get.dart';
import 'package:host_app/helper/app_helper.dart';
import 'package:permission_handler/permission_handler.dart';

class ConnectionController extends GetxController {
  final _flutterP2pConnectionPlugin = FlutterP2pConnection();
  RxList<DiscoveredPeers> peers = <DiscoveredPeers>[].obs;
  Rx<WifiP2PInfo?> wifiP2PInfo = Rx<WifiP2PInfo?>(null);
  Rx<bool> isDiscoveryLoading = false.obs;
  Rx<bool> allPermissionGranted = false.obs;
  Rx<bool> hasError = false.obs;
  Rx<bool> wifiEnable = false.obs;
  Rx<bool> locationEnable = false.obs;

  final Dio dio = Dio();

  @override
  void onInit() {
    super.onInit();
    p2pInit();
    askAllPermissions();
    // fetchData();
  }

  void p2pInit() async {
    print("p2p connection is called");
    await _flutterP2pConnectionPlugin.initialize();
    await _flutterP2pConnectionPlugin.register();

    _flutterP2pConnectionPlugin.streamWifiP2PInfo().listen((event) async {
      wifiP2PInfo.value = event;
      print("----------<<<<<<<<<<<>>>>>>>>>>>>>>");
      print("----------<<<<<<<<<<<${event.isConnected}>>>>>>>>>>>>>>");
      if (event.isConnected) {
        isDiscoveryLoading.value = false;
        startSocket();
      }

      print(
          "connected: ${wifiP2PInfo.value?.isConnected}, isGroupOwner: ${wifiP2PInfo.value?.isGroupOwner}, groupFormed: ${wifiP2PInfo.value?.groupFormed}, groupOwnerAddress: ${wifiP2PInfo.value?.groupOwnerAddress}, clients: ${wifiP2PInfo.value?.clients}");
    });

    _flutterP2pConnectionPlugin.streamPeers().listen((event) {
      print("event -------->>>>>>>>>$event");
      peers.assignAll(event); // Updating the observable list
    });
  }

  Future<void> p2pCreateGroup() async {
    try {
      isDiscoveryLoading.value = await _flutterP2pConnectionPlugin
          .createGroup()
          .onError((error, stackTrace) {
        print(error);
        print(stackTrace);

        return false;
      });

      AppHelper.showToastMessage("created group: ${isDiscoveryLoading.value}");
    } catch (error, stackTrace) {
      AppHelper.showToastMessage(error.toString());
    }
  }

  Future<void> p2pRemoveGroup() async {
    bool? removed = await _flutterP2pConnectionPlugin.removeGroup();
    if (removed) {
      isDiscoveryLoading.value = false;
      AppHelper.showToastMessage("wifi group closed");
    } else {
      AppHelper.showToastMessage("something went wrong");
    }
  }

  Future<void> p2pRestartConnection() async {
    await p2pRemoveGroup();
    await p2pCreateGroup();
  }

  sendMessage(String message) async {
    bool messageSent = _flutterP2pConnectionPlugin.sendStringToSocket(message);
    if (messageSent == false) {
      AppHelper.showToastMessage(
          "connection restarted due to some interruption");
      await p2pRestartConnection();
    }
  }

  Future startSocket() async {
    print("ifiP2PInfo.value--->>>${wifiP2PInfo.value}");
    if (wifiP2PInfo.value != null) {
      bool started = await _flutterP2pConnectionPlugin.startSocket(
        groupOwnerAddress: wifiP2PInfo.value!.groupOwnerAddress,
        downloadPath: "/storage/emulated/0/Download/",
        maxConcurrentDownloads: 2,
        deleteOnError: true,
        onConnect: (name, address) {
          AppHelper.showToastMessage(
              "$name connected to socket with address: $address");
        },
        transferUpdate: (transfer) {
          if (transfer.completed) {
            AppHelper.showToastMessage(
                "${transfer.failed ? "failed to ${transfer.receiving ? "receive" : "send"}" : transfer.receiving ? "received" : "sent"}: ${transfer.filename}");
          }
          print(
              "ID: ${transfer.id}, FILENAME: ${transfer.filename}, PATH: ${transfer.path}, COUNT: ${transfer.count}, TOTAL: ${transfer.total}, COMPLETED: ${transfer.completed}, FAILED: ${transfer.failed}, RECEIVING: ${transfer.receiving}");
        },
        receiveString: (req) async {
          AppHelper.showToastMessage(req);
        },
      );
      AppHelper.showToastMessage("open socket: $started");
    }
  }

  Future<bool> askAllPermissions() async {
    if (await _requestPermission(Permission.location, "Location")) {
      if (Platform.isAndroid) {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        int androidVersion = androidInfo.version.sdkInt;

        if (androidVersion >= 33) {
          if (await _requestPermission(
              Permission.nearbyWifiDevices, "Nearby Wi-Fi Devices")) {
            if (await _requestPermission(Permission.photos, "Photos") ||
                await _requestPermission(Permission.videos, "Videos")) {
              allPermissionGranted.value =
                  await checkAndEnableServices(wifi: true, location: true);
              return allPermissionGranted.value;
            }
          }
        } else {
          if (await _requestPermission(Permission.storage, "Storage")) {
            allPermissionGranted.value =
                await checkAndEnableServices(wifi: true, location: true);
            return allPermissionGranted.value;
          }
        }
      }
    }

    allPermissionGranted.value = false;
    return false;
  }

  Future<bool> _requestPermission(
      Permission permission, String permissionName) async {
    if (await permission.isGranted) {
      print("$permissionName permission already granted.");
      return true;
    } else {
      PermissionStatus status = await permission.request();
      if (status.isGranted) {
        print("$permissionName permission granted.");
        return true;
      } else if (status.isPermanentlyDenied) {
        AppHelper.showToastMessage(
            "The $permissionName permission is required for the app to function properly. Please go to settings to enable it.");
        return false;
      } else {
        print("$permissionName permission denied.");
        return false;
      }
    }
  }

  Future<bool> checkAndEnableServices({bool? wifi, bool? location}) async {
    if (location ?? false) {
      locationEnable.value =
          await _flutterP2pConnectionPlugin.checkLocationEnabled();
      print("Location is $locationEnable.value.");
      if (!locationEnable.value) {
        await _flutterP2pConnectionPlugin.enableLocationServices();
      }
    }
    if (wifi ?? false) {
      wifiEnable.value = await _flutterP2pConnectionPlugin.checkWifiEnabled();
      print("Wi-Fi is ${wifiEnable.value}.");
      if (!wifiEnable.value) {
        bool wifiSuccess =
            await _flutterP2pConnectionPlugin.enableWifiServices();
        if (!wifiSuccess) return false;
      }
    }

    return locationEnable.value && wifiEnable.value;
  }
}
