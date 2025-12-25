import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/offer_model.dart';
import 'package:smart_service_wallet/core/services/local_storage_service.dart';
import 'dart:async';

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

  RewardsBloc({required this.storage}) : super(RewardsInitial()) {
    on<LoadRewards>(_onLoadRewards);
    on<ClaimOffer>(_onClaimOffer);
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
        final updatedOffer = offer.copyWith(
          isClaimed: true,
          expiry: DateTime.now().add(const Duration(hours: 2)), // 2 hour timer
        );

        final updatedOffers = List<OfferModel>.from(current.offers);
        updatedOffers[offerIndex] = updatedOffer;

        final updatedClaimed = [...current.claimedOffers, updatedOffer];
        await storage.saveClaimedOffers(updatedClaimed);

        emit(
          RewardsLoaded(offers: updatedOffers, claimedOffers: updatedClaimed),
        );
      }
    }
  }

  final List<OfferModel> _mockOffers = [
    // Campaigns
    const OfferModel(
      id: "c1",
      title: "Holiday Mega Goal",
      description: "Complete 10 bookings this month to win 500 GP.",
      imageUrl:
          "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=500&q=80",
      pointsRequired: 0,
    ),
    const OfferModel(
      id: "c2",
      title: "New User Welcome",
      description: "Claim your first RM10 voucher for any service.",
      imageUrl:
          "https://images.unsplash.com/photo-1556742044-3c52d6e88c62?w=500&q=80",
      pointsRequired: 0,
    ),
    // Offers/Vouchers
    const OfferModel(
      id: "r1",
      title: "Free Valet Upgrade",
      description: "Get a free upgrade to VIP valet parking.",
      imageUrl:
          "https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=500&q=80",
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
          "https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=500&q=80",
      pointsRequired: 0,
    ),
    // Loyalty
    const OfferModel(
      id: "l1",
      title: "Gold Member Lounge",
      description: "Access to VIP waiting lounge for 1 hour.",
      imageUrl:
          "https://images.unsplash.com/photo-1560624056-44c13861bd61?w=500&q=80",
      pointsRequired: 100,
    ),
  ];
}
