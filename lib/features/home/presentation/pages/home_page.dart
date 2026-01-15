import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_service_wallet/features/home/presentation/widgets/active_booking_home_card.dart';
import 'package:smart_service_wallet/features/home/presentation/widgets/activity_item.dart';
import 'package:smart_service_wallet/features/home/presentation/widgets/balance_card.dart';
import 'package:smart_service_wallet/features/home/presentation/widgets/loyalty_progress_card.dart';
import 'package:smart_service_wallet/features/home/presentation/widgets/service_item.dart';
import 'package:smart_service_wallet/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:smart_service_wallet/features/services/presentation/bloc/services_bloc.dart';
import 'package:smart_service_wallet/features/services/presentation/pages/booking_selection_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good ${_greetingTime()},',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Text(
              'John Doe',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _showNotifications(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10),
                ],
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF64748B),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            BlocBuilder<WalletBloc, WalletState>(
              builder: (context, state) {
                if (state is WalletLoaded) {
                  return BalanceCard(
                    credits: state.balance.credits,
                    tokens: state.balance.loyaltyTokens,
                  );
                }
                return const _BalanceCardShimmer();
              },
            ),

            const SizedBox(height: 32),
            const _SectionHeader(title: 'Quick Services'),
            const SizedBox(height: 16),

            // Quick Services Grid - Synced with Bloc
            BlocBuilder<ServicesBloc, ServicesState>(
              builder: (context, state) {
                if (state is ServicesLoaded) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          childAspectRatio: 0.9,
                        ),
                    itemCount: state.services.length > 3
                        ? 3
                        : state.services.length,
                    itemBuilder: (context, index) {
                      final service = state.services[index];
                      return ServiceItem(
                        service: service,
                        color: _getServiceColor(service.name),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                BookingSelectionPage(service: service),
                          ),
                        ),
                      );
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),

            const SizedBox(height: 32),
            const _SectionHeader(title: 'Loyalty Progress'),
            const SizedBox(height: 16),
            const LoyaltyProgressCard(),

            const SizedBox(height: 32),
            const _SectionHeader(title: 'Active Booking'),
            const SizedBox(height: 16),

            BlocBuilder<ServicesBloc, ServicesState>(
              builder: (context, state) {
                if (state is ServicesLoaded &&
                    state.activeBookings.isNotEmpty) {
                  final booking = state.activeBookings.first;
                  return ActiveBookingHomeCard(booking: booking);
                }

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.withAlpha(10)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        color: Colors.grey.shade300,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No active bookings for today',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 32),
            const _SectionHeader(title: 'Recent Activity'),
            const SizedBox(height: 16),
            BlocBuilder<WalletBloc, WalletState>(
              builder: (context, state) {
                if (state is WalletLoaded) {
                  if (state.transactions.isEmpty) {
                    return _buildEmptyActivity();
                  }
                  final recent = state.transactions.take(3).toList();
                  return Column(
                    children: recent
                        .map((tx) => ActivityItem(transaction: tx))
                        .toList(),
                  );
                }
                return const SizedBox();
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyActivity() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_rounded,
            color: Colors.grey.shade300,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            'No recent activity yet',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getServiceColor(String name) {
    if (name.contains('Valet')) return const Color(0xFF6366F1);
    if (name.contains('Wash')) return const Color(0xFF10B981);
    return const Color(0xFFF59E0B);
  }

  void _showNotifications(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No new notifications'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _greetingTime() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 18) return 'afternoon';
    return 'evening';
  }
}

class _BalanceCardShimmer extends StatelessWidget {
  const _BalanceCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(32),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
      ),
    );
  }
}
