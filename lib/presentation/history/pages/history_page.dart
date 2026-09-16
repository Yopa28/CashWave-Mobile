import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/history/history_bloc.dart';
import '../widgets/history_transaction_card.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primary = Color(0xff087A55);
  static const Color primaryLight = Color(0xffE8F5F0);

  static const Color background = Color(0xffF7F9F8);
  static const Color textPrimary = Color(0xff17221E);
  static const Color textSecondary = Color(0xff7A8581);
  static const Color borderColor = Color(0xffE5EBE8);

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    context.read<HistoryBloc>().add(const HistoryEvent.fetch());
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surface,
        elevation: 0,
        centerTitle: false,

        titleSpacing: 20,

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Riwayat Transaksi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Lihat transaksi yang sudah dilakukan',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  context.read<HistoryBloc>().add(const HistoryEvent.fetch());
                },
                borderRadius: BorderRadius.circular(11),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: primaryLight,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.refresh_rounded,
                    color: primary,
                    size: 21,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          return state.maybeWhen(
            // ==================================================
            // LOADING
            // ==================================================

            loading: () {
              return const _HistoryLoading();
            },

            // ==================================================
            // SUCCESS
            // ==================================================
            success: (data) {
              if (data.isEmpty) {
                return _buildEmptyState(context);
              }

              return _buildHistoryList(data);
            },

            // ==================================================
            // ERROR
            // ==================================================
            error: (message) {
              return _buildErrorState(context, message);
            },

            // ==================================================
            // DEFAULT
            // ==================================================
            orElse: () {
              return _buildEmptyState(context);
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // HISTORY LIST
  // ============================================================

  Widget _buildHistoryList(List<dynamic> data) {
    return RefreshIndicator(
      color: primary,
      onRefresh: () async {
        context.read<HistoryBloc>().add(const HistoryEvent.fetch());

        // Small delay so the refresh indicator feels natural.
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ====================================================
          // HEADER
          // ====================================================

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      color: primary,
                      size: 21,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Transaksi',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${data.length} transaksi tercatat',
                          style: const TextStyle(
                            fontSize: 11,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // TOTAL TRANSACTION
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    child: Text(
                      '${data.length}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ====================================================
          // TRANSACTION CARDS
          // ====================================================
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: HistoryTransactionCard(
                    padding: EdgeInsets.zero,
                    data: data[index],
                  ),
                );
              }, childCount: data.length),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState(BuildContext context) {
    return RefreshIndicator(
      color: primary,
      onRefresh: () async {
        context.read<HistoryBloc>().add(const HistoryEvent.fetch());

        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 30),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.23),

          Center(
            child: Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: primaryLight,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: primary,
                size: 40,
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Belum Ada Riwayat',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'Transaksi yang sudah dilakukan akan muncul di halaman ini.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, height: 1.5, color: textSecondary),
          ),

          const SizedBox(height: 20),

          Center(
            child: SizedBox(
              height: 42,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.read<HistoryBloc>().add(const HistoryEvent.fetch());
                },
                icon: const Icon(Icons.refresh_rounded, size: 17),
                label: const Text(
                  'Muat Ulang',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primary,
                  side: const BorderSide(color: borderColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0xfffff1f0),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.cloud_off_outlined,
                color: Color(0xffD9534F),
                size: 34,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Gagal Memuat Riwayat',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                height: 1.5,
                color: textSecondary,
              ),
            ),

            const SizedBox(height: 18),

            SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<HistoryBloc>().add(const HistoryEvent.fetch());
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text(
                  'Coba Lagi',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// LOADING SKELETON
// ==================================================================

class _HistoryLoading extends StatelessWidget {
  const _HistoryLoading();

  static const Color background = Color(0xffF7F9F8);
  static const Color shimmer = Color(0xffE8EEEB);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      children: [
        // Header skeleton
        Row(
          children: [
            _skeleton(width: 42, height: 42, radius: 12),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _skeleton(width: 90, height: 13, radius: 5),
                  const SizedBox(height: 7),
                  _skeleton(width: 130, height: 10, radius: 5),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Cards
        for (int i = 0; i < 5; i++) ...[
          Container(
            height: 115,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  _skeleton(width: 70, height: 70, radius: 13),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _skeleton(width: 140, height: 13, radius: 5),
                        const SizedBox(height: 9),
                        _skeleton(width: 90, height: 11, radius: 5),
                        const SizedBox(height: 9),
                        _skeleton(width: 110, height: 11, radius: 5),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _skeleton({
    required double width,
    required double height,
    required double radius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: shimmer,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
