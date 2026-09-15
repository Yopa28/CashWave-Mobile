import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashwave_mobile/core/extensions/build_context_ext.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../bloc/product/product_bloc.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> with WidgetsBindingObserver {
  final MobileScannerController cameraController = MobileScannerController(
    autoStart: false,
    torchEnabled: false,
  );

  Barcode? _barcode;
  StreamSubscription<Object?>? _subscription;

  Widget _buildBarcode(Barcode? value) {
    if (value == null) {
      return const Text(
        'Scan something!',
        overflow: TextOverflow.fade,
        style: TextStyle(color: Colors.white),
      );
    }

    return Text(
      value.displayValue ?? 'No display value.',
      overflow: TextOverflow.fade,
      style: const TextStyle(color: Colors.white),
    );
  }

  void _handleBarcode(BarcodeCapture barcodes) {
    if (!mounted) {
      return;
    }

    _barcode = barcodes.barcodes.firstOrNull;

    if (_barcode != null) {
      cameraController.stop();

      context.read<ProductBloc>().add(
        ProductEvent.searchProduct(_barcode!.displayValue ?? ''),
      );

      context.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _subscription = cameraController.barcodes.listen(_handleBarcode);

    unawaited(cameraController.start());
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);

    unawaited(_subscription?.cancel());

    _subscription = null;

    await cameraController.dispose();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!cameraController.value.isInitialized) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;

      case AppLifecycleState.resumed:
        _subscription ??= cameraController.barcodes.listen(_handleBarcode);

        unawaited(cameraController.start());

      case AppLifecycleState.inactive:
        unawaited(_subscription?.cancel());

        _subscription = null;

        unawaited(cameraController.stop());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () async {
            await cameraController.stop();

            if (mounted) {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text('Scanning'),
        actions: [
          // =========================
          // TORCH BUTTON
          // =========================
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: cameraController,
            builder: (context, state, child) {
              switch (state.torchState) {
                case TorchState.auto:
                  return IconButton(
                    color: Colors.white,
                    iconSize: 32.0,
                    icon: const Icon(Icons.flash_auto),
                    onPressed: () async {
                      await cameraController.toggleTorch();
                    },
                  );

                case TorchState.off:
                  return IconButton(
                    color: Colors.grey,
                    iconSize: 32.0,
                    icon: const Icon(Icons.flash_off),
                    onPressed: () async {
                      await cameraController.toggleTorch();
                    },
                  );

                case TorchState.on:
                  return IconButton(
                    color: Colors.yellow,
                    iconSize: 32.0,
                    icon: const Icon(Icons.flash_on),
                    onPressed: () async {
                      await cameraController.toggleTorch();
                    },
                  );

                case TorchState.unavailable:
                  return IconButton(
                    color: Colors.grey,
                    iconSize: 32.0,
                    icon: const Icon(Icons.no_flash),
                    onPressed: null,
                  );
              }
            },
          ),

          // =========================
          // SWITCH CAMERA BUTTON
          // =========================
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: cameraController,
            builder: (context, state, child) {
              if (!state.isInitialized || !state.isRunning) {
                return const SizedBox.shrink();
              }

              final int? availableCameras = state.availableCameras;

              if (availableCameras != null && availableCameras < 2) {
                return const SizedBox.shrink();
              }

              final Widget icon;

              switch (state.cameraDirection) {
                case CameraFacing.front:
                  icon = const Icon(Icons.camera_front);

                case CameraFacing.back:
                  icon = const Icon(Icons.camera_rear);

                case CameraFacing.external:
                  icon = const Icon(Icons.camera);

                case CameraFacing.unknown:
                  icon = const Icon(Icons.camera_alt);
              }

              return IconButton(
                iconSize: 32.0,
                icon: icon,
                onPressed: () async {
                  await cameraController.switchCamera();
                },
              );
            },
          ),
        ],
      ),

      // =========================
      // CAMERA BODY
      // =========================
      body: Stack(
        children: [
          MobileScanner(controller: cameraController),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.black.withOpacity(0.5),
              child: _buildBarcode(_barcode),
            ),
          ),
        ],
      ),
    );
  }
}
