import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashwave_mobile/core/extensions/build_context_ext.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../data/datasources/auth_local_datasource.dart';
import '../widgets/menu_printer_content.dart';

class ManagePrinterPage extends StatefulWidget {
  const ManagePrinterPage({super.key});

  @override
  State<ManagePrinterPage> createState() => _ManagePrinterPageState();
}

class _ManagePrinterPageState extends State<ManagePrinterPage> {
  // ==============================================================
  // COLORS
  // ==============================================================

  static const Color primary = Color(0xff087A55);
  static const Color primaryDark = Color(0xff065C40);
  static const Color primaryLight = Color(0xffE8F5F0);

  static const Color background = Color(0xffF7F9F8);
  static const Color cardColor = Colors.white;

  static const Color textPrimary = Color(0xff17221E);
  static const Color textSecondary = Color(0xff7A8581);

  static const Color borderColor = Color(0xffE5EBE8);

  static const Color danger = Color(0xffD9534F);
  static const Color dangerLight = Color(0xfffff1f0);

  // ==============================================================
  // STATE
  // ==============================================================

  String macName = '';
  String? macConnected;

  bool connected = false;
  bool isSearching = false;
  bool isConnecting = false;
  bool bluetoothEnabled = false;

  List<BluetoothInfo> items = [];

  String optionprinttype = '58mm';

  @override
  void initState() {
    super.initState();

    initPlatformState();
    loadDataPrinter();
    getBluetoots();
  }

  // ==============================================================
  // LOAD SAVED PRINTER
  // ==============================================================

  Future<void> loadDataPrinter() async {
    try {
      macConnected = await AuthLocalDatasource().getPrinter();

      if (macConnected != null && macConnected!.isNotEmpty) {
        macName = macConnected!;

        await connect(macName, showSnackbar: false);
      }

      final savedSize = await AuthLocalDatasource().getSizePrinter();

      if (!mounted) return;

      setState(() {
        optionprinttype = savedSize.isNotEmpty ? savedSize : '58mm';
      });
    } catch (e) {
      debugPrint('Load printer error: $e');
    }
  }

  // ==============================================================
  // PLATFORM / BLUETOOTH STATUS
  // ==============================================================

  Future<void> initPlatformState() async {
    try {
      await PrintBluetoothThermal.platformVersion;

      await PrintBluetoothThermal.batteryLevel;

      final bool result = await PrintBluetoothThermal.bluetoothEnabled;

      if (!mounted) return;

      setState(() {
        bluetoothEnabled = result;
      });
    } on PlatformException catch (e) {
      debugPrint('Bluetooth platform error: ${e.message}');
    }
  }

  // ==============================================================
  // SEARCH BLUETOOTH
  // ==============================================================

  Future<void> getBluetoots() async {
    if (mounted) {
      setState(() {
        isSearching = true;
        items = [];
      });
    }

    try {
      // ------------------------------------------------------------
      // Bluetooth Scan Permission
      // ------------------------------------------------------------

      var scanStatus = await Permission.bluetoothScan.status;

      if (scanStatus.isDenied) {
        scanStatus = await Permission.bluetoothScan.request();
      }

      // ------------------------------------------------------------
      // Bluetooth Connect Permission
      // ------------------------------------------------------------

      var connectStatus = await Permission.bluetoothConnect.status;

      if (connectStatus.isDenied) {
        connectStatus = await Permission.bluetoothConnect.request();
      }

      // ------------------------------------------------------------
      // Get Paired Bluetooth Devices
      // ------------------------------------------------------------

      final List<BluetoothInfo> listResult =
          await PrintBluetoothThermal.pairedBluetooths;

      if (!mounted) return;

      setState(() {
        items = listResult;
        isSearching = false;
      });
    } catch (e) {
      debugPrint('Get bluetooth devices error: $e');

      if (!mounted) return;

      setState(() {
        isSearching = false;
      });

      _showSnackBar('Gagal mencari printer Bluetooth', isError: true);
    }
  }

  // ==============================================================
  // CONNECT PRINTER
  // ==============================================================

  Future<void> connect(String mac, {bool showSnackbar = true}) async {
    if (isConnecting) return;

    if (mounted) {
      setState(() {
        isConnecting = true;
        connected = false;
      });
    }

    try {
      final bool result = await PrintBluetoothThermal.connect(
        macPrinterAddress: mac,
      );

      if (!mounted) return;

      if (result) {
        await AuthLocalDatasource().savePrinter(mac);

        setState(() {
          macName = mac;
          macConnected = mac;
          connected = true;
          isConnecting = false;
        });

        if (showSnackbar) {
          _showSnackBar('Printer berhasil terhubung');
        }
      } else {
        setState(() {
          connected = false;
          isConnecting = false;
        });

        _showSnackBar('Gagal menghubungkan printer', isError: true);
      }
    } catch (e) {
      debugPrint('Connect printer error: $e');

      if (!mounted) return;

      setState(() {
        connected = false;
        isConnecting = false;
      });

      _showSnackBar(
        'Terjadi kesalahan saat menghubungkan printer',
        isError: true,
      );
    }
  }

  // ==============================================================
  // DISCONNECT
  // ==============================================================

  Future<void> disconnect() async {
    try {
      final bool status = await PrintBluetoothThermal.disconnect;

      debugPrint('status disconnect $status');

      if (!mounted) return;

      setState(() {
        connected = false;
      });

      _showSnackBar('Printer berhasil diputus');
    } catch (e) {
      debugPrint('Disconnect error: $e');
    }
  }

  // ==============================================================
  // SNACKBAR
  // ==============================================================

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: isError ? danger : primary,
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,

      // ============================================================
      // APP BAR
      // ============================================================
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,

        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textPrimary,
            size: 20,
          ),
        ),

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Printer',
              style: TextStyle(
                color: textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Kelola printer Bluetooth',
              style: TextStyle(
                color: textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        centerTitle: false,

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: borderColor),
        ),
      ),

      // ============================================================
      // BODY
      // ============================================================
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
        children: [
          _buildConnectionStatus(),

          const SizedBox(height: 16),

          _buildSearchCard(),

          const SizedBox(height: 16),

          _buildPaperSizeCard(),

          const SizedBox(height: 24),

          _buildPrinterHeader(),

          const SizedBox(height: 12),

          _buildPrinterList(),
        ],
      ),
    );
  }

  // ==============================================================
  // CONNECTION STATUS
  // ==============================================================

  Widget _buildConnectionStatus() {
    final bool hasPrinter = macName.isNotEmpty && connected;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: hasPrinter
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasPrinter ? primary.withOpacity(0.20) : borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: hasPrinter ? primary : colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              hasPrinter ? Icons.print_rounded : Icons.print_disabled_outlined,
              color: hasPrinter ? Colors.white : textSecondary,
              size: 25,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasPrinter ? 'Printer Terhubung' : 'Belum Terhubung',
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  hasPrinter
                      ? macName
                      : 'Pilih printer Bluetooth untuk digunakan',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          if (hasPrinter)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'AKTIF',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==============================================================
  // SEARCH CARD
  // ==============================================================

  Widget _buildSearchCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bluetooth_searching_rounded, color: primary, size: 21),
              SizedBox(width: 9),
              Text(
                'Cari Printer',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          const Text(
            'Pastikan printer sudah dinyalakan dan terhubung melalui Bluetooth.',
            style: TextStyle(color: textSecondary, fontSize: 12, height: 1.45),
          ),

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: isSearching ? null : getBluetoots,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                disabledBackgroundColor: primary.withOpacity(0.5),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: isSearching
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.refresh_rounded, size: 20),
              label: Text(
                isSearching ? 'Mencari Printer...' : 'Cari Printer',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // PAPER SIZE
  // ==============================================================

  Widget _buildPaperSizeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: primary,
              size: 23,
            ),
          ),

          const SizedBox(width: 13),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ukuran Kertas',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Sesuaikan dengan printer thermal',
                  style: TextStyle(color: textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),

          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: optionprinttype,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: primary,
                  size: 20,
                ),
                borderRadius: BorderRadius.circular(14),
                dropdownColor: Colors.white,
                items: const [
                  DropdownMenuItem(
                    value: '58mm',
                    child: Text(
                      '58mm',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: '80mm',
                    child: Text(
                      '80mm',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                onChanged: (String? value) async {
                  if (value == null) return;

                  await AuthLocalDatasource().saveSizePrinter(value);

                  if (!mounted) return;

                  setState(() {
                    optionprinttype = value;
                  });

                  _showSnackBar('Ukuran kertas diubah ke $value');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // PRINTER HEADER
  // ==============================================================

  Widget _buildPrinterHeader() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Printer Tersedia',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Pilih printer yang ingin digunakan',
                style: TextStyle(color: textSecondary, fontSize: 11),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${items.length} device',
            style: const TextStyle(
              color: primary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // PRINTER LIST
  // ==============================================================

  Widget _buildPrinterList() {
    if (isSearching) {
      return _buildLoading();
    }

    if (items.isEmpty) {
      return _buildEmptyPrinter();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (context, index) {
          return const SizedBox(height: 8);
        },
        itemBuilder: (context, index) {
          final printer = items[index];

          final bool isSelected = macName == printer.macAdress;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: isConnecting
                  ? null
                  : () async {
                      await connect(printer.macAdress);
                    },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? primaryLight : background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? primary.withOpacity(0.35) : borderColor,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected ? primary : cardColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.print_rounded,
                        color: isSelected ? Colors.white : primary,
                        size: 23,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: MenuPrinterContent(
                        isSelected: isSelected,
                        data: printer,
                      ),
                    ),

                    const SizedBox(width: 8),

                    if (isSelected)
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                      )
                    else
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: textSecondary,
                        size: 22,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ==============================================================
  // LOADING
  // ==============================================================

  Widget _buildLoading() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: const Column(
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 3, color: primary),
          ),
          SizedBox(height: 14),
          Text(
            'Mencari perangkat Bluetooth...',
            style: TextStyle(
              color: textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // EMPTY
  // ==============================================================

  Widget _buildEmptyPrinter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: primaryLight,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.print_disabled_outlined,
              color: primary,
              size: 34,
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Belum Ada Printer',
            style: TextStyle(
              color: textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'Tidak ditemukan printer Bluetooth yang sudah dipasangkan dengan perangkat ini.',
            textAlign: TextAlign.center,
            style: TextStyle(color: textSecondary, fontSize: 12, height: 1.5),
          ),

          const SizedBox(height: 16),

          TextButton.icon(
            onPressed: isSearching ? null : getBluetoots,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text(
              'Cari Lagi',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            style: TextButton.styleFrom(foregroundColor: primary),
          ),
        ],
      ),
    );
  }
}
