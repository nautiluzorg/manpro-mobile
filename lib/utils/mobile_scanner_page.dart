import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:lottie/lottie.dart';

class MobileScannerPage extends StatefulWidget {
  const MobileScannerPage({super.key});

  @override
  State<MobileScannerPage> createState() => _MobileScannerPageState();
}

class _MobileScannerPageState extends State<MobileScannerPage> {
  final MobileScannerController controller = MobileScannerController(
    facing: CameraFacing.front, // Default kamera depan
  );

  bool scanned = false;
  CameraFacing cameraFacing = CameraFacing.front;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SCANNING QRCODE"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            onPressed: () async {
              cameraFacing = cameraFacing == CameraFacing.front
                  ? CameraFacing.back
                  : CameraFacing.front;

              await controller.switchCamera();

              setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context, null),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: controller,
            fit: BoxFit.cover,
            onDetect: (capture) {
              if (scanned) return;

              final List<Barcode> barcodes = capture.barcodes;

              if (barcodes.isNotEmpty) {
                final String? rawValue = barcodes.first.rawValue;

                if (rawValue != null && rawValue.isNotEmpty) {
                  scanned = true;
                  Navigator.pop(context, rawValue);
                }
              }
            },
          ),

          // Animasi Lottie
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Lottie.asset(
              'assets/lottie/scan_qr_code5.json',
              fit: BoxFit.contain,
              repeat: true,
              animate: true,
            ),
          ),
        ],
      ),
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:lottie/lottie.dart';

class MobileScannerPage extends StatefulWidget {
  const MobileScannerPage({super.key});

  @override
  State<MobileScannerPage> createState() => _MobileScannerPageState();
}

class _MobileScannerPageState extends State<MobileScannerPage> {
  final MobileScannerController controller = MobileScannerController();
  bool scanned = false;
  CameraFacing cameraFacing = CameraFacing.back; // default belakang

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SCANNING QRCODE"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            onPressed: () {
              cameraFacing = cameraFacing == CameraFacing.back
                  ? CameraFacing.front
                  : CameraFacing.back;
              controller.switchCamera();
              setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context, null),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center, // biar Lottie di tengah
        children: [
          MobileScanner(
            controller: controller,
            fit: BoxFit.cover, // kamera full screen
            onDetect: (capture) {
              if (scanned) return;
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? rawValue = barcodes.first.rawValue;
                if (rawValue != null && rawValue.isNotEmpty) {
                  scanned = true;
                  Navigator.pop(context, rawValue);
                }
              }
            },
          ),
          // Lottie animasi di atas kamera
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8, // 80% lebar layar
            height:
                MediaQuery.of(context).size.height * 0.5, // 50% tinggi layar
            child: Lottie.asset(
              'assets/lottie/scan_qr_code5.json',
              fit: BoxFit.contain, // tetap proporsional
              repeat: true,
              animate: true,
            ),
          ),
        ],
      ),
    );
  }
}
*/
