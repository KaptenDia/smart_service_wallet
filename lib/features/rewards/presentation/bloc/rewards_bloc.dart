import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/offer_model.dart';
import 'package:smart_service_wallet/core/services/local_storage_service.dart';
import 'dart:async';

import 'package:smart_service_wallet/features/wallet/presentation/bloc/wallet_bloc.dart';

// Events
abstract class RewardsEvent extends Equatable {
  const RewardsEvent();
  @override
  List<Object?> get props => [];
}

class LoadRewards extends RewardsEvent {}

class ClaimOffer extends RewardsEvent {
  final String offerId;
  const ClaimOffer(this.offerId);
  @override
  List<Object?> get props => [offerId];
}

class RedeemOffer extends RewardsEvent {
  final String offerId;
  const RedeemOffer(this.offerId);
  @override
  List<Object?> get props => [offerId];
}

// States
abstract class RewardsState extends Equatable {
  const RewardsState();
  @override
  List<Object?> get props => [];
}

class RewardsInitial extends RewardsState {}

class RewardsLoading extends RewardsState {}

class RewardsLoaded extends RewardsState {
  final List<OfferModel> offers;
  final List<OfferModel> claimedOffers;

  const RewardsLoaded({required this.offers, required this.claimedOffers});

  @override
  List<Object?> get props => [offers, claimedOffers];
}

// Bloc
class RewardsBloc extends Bloc<RewardsEvent, RewardsState> {
  final LocalStorageService storage;
  final WalletBloc walletBloc;

  RewardsBloc({required this.storage, required this.walletBloc})
    : super(RewardsInitial()) {
    on<LoadRewards>(_onLoadRewards);
    on<ClaimOffer>(_onClaimOffer);
    on<RedeemOffer>(_onRedeemOffer);
  }

  void _onLoadRewards(LoadRewards event, Emitter<RewardsState> emit) async {
    emit(RewardsLoading());
    await Future.delayed(const Duration(milliseconds: 500));

    final claimed = storage.getClaimedOffers();
    final updatedOffers = _mockOffers.map((offer) {
      final claimedOffer = claimed.firstWhere(
        (c) => c.id == offer.id,
        orElse: () => offer,
      );
      return claimedOffer;
    }).toList();

    emit(RewardsLoaded(offers: updatedOffers, claimedOffers: claimed));
  }

  void _onClaimOffer(ClaimOffer event, Emitter<RewardsState> emit) async {
    if (state is RewardsLoaded) {
      final current = state as RewardsLoaded;
      final offerIndex = current.offers.indexWhere(
        (o) => o.id == event.offerId,
      );

      if (offerIndex != -1) {
        final offer = current.offers[offerIndex];

        // Determine if it's a campaign goal (grant GP) or reward (cost GP)
        // Campaigns start with 'c', Rewards/Offers with 'r', 'e', 'l'
        final isCampaign = offer.id.startsWith('c');

        // Check if user has enough GP if it's a reward
        if (!isCampaign && walletBloc.state is WalletLoaded) {
          final balance = (walletBloc.state as WalletLoaded).balance;
          if (balance.loyaltyTokens < offer.pointsRequired) {
            // In a real app we might emit an error state
            return;
          }
        }

        final updatedOffer = offer.copyWith(
          isClaimed: true,
          expiry: DateTime.now().add(const Duration(hours: 2)), // 2 hour timer
        );

        final updatedOffers = List<OfferModel>.from(current.offers);
        updatedOffers[offerIndex] = updatedOffer;

        final updatedClaimed = [...current.claimedOffers, updatedOffer];
        await storage.saveClaimedOffers(updatedClaimed);

        // Update Wallet Balance
        walletBloc.add(
          UpdateBalance(
            tokensDelta: isCampaign
                ? offer.pointsRequired
                : -offer.pointsRequired,
            description: isCampaign
                ? "Campaign Reward: ${offer.title}"
                : "Claimed Reward: ${offer.title}",
          ),
        );

        emit(
          RewardsLoaded(offers: updatedOffers, claimedOffers: updatedClaimed),
        );
      }
    }
  }

  void _onRedeemOffer(RedeemOffer event, Emitter<RewardsState> emit) async {
    if (state is RewardsLoaded) {
      final current = state as RewardsLoaded;
      final updatedClaimed = current.claimedOffers
          .where((o) => o.id != event.offerId)
          .toList();

      await storage.saveClaimedOffers(updatedClaimed);

      emit(
        RewardsLoaded(offers: current.offers, claimedOffers: updatedClaimed),
      );
    }
  }

  final List<OfferModel> _mockOffers = [
    // Campaigns
    const OfferModel(
      id: "c1",
      title: "Holiday Mega Goal",
      description: "Complete 10 bookings this month to win 500 GP.",
      imageUrl:
          "https://images.unsplash.com/photo-1766546718103-da6823613fb0?w=500&q=80",
      pointsRequired: 10,
    ),
    const OfferModel(
      id: "c2",
      title: "New User Welcome",
      description: "Claim your first RM10 voucher for any service.",
      imageUrl:
          "https://images.unsplash.com/photo-1579389083046-e3df9c2b3325?w=500&q=80",
      pointsRequired: 5,
    ),
    // Offers/Vouchers
    const OfferModel(
      id: "r1",
      title: "Free Valet Upgrade",
      description: "Get a free upgrade to VIP valet parking.",
      imageUrl:
          "https://images.unsplash.com/photo-1766425597345-629c0f803d4c?w=500&q=80",
      pointsRequired: 50,
    ),
    const OfferModel(
      id: "r2",
      title: "RM5 Off Car Wash",
      description: "Enjoy RM5 discount on your next full wash.",
      imageUrl:
          "https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?w=500&q=80",
      pointsRequired: 30,
    ),
    // Events
    const OfferModel(
      id: "e1",
      title: "Grand Opening Gala",
      description: "Invitation to our new bay launch event.",
      imageUrl:
          "https://images.unsplash.com/photo-1766145605687-fde866d32ae1?w=500&q=80",
      pointsRequired: 20,
    ),
    // Loyalty
    const OfferModel(
      id: "l1",
      title: "Gold Member Lounge",
      description: "Access to VIP waiting lounge for 1 hour.",
      imageUrl:
          "https://images.unsplash.com/photo-1766068472854-3184eda0d376?w=500&q=80",
      pointsRequired: 100,
    ),
  ];
}
