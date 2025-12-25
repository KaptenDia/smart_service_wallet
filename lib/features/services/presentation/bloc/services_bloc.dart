import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:smart_service_wallet/core/services/local_storage_service.dart';
import 'package:smart_service_wallet/features/wallet/presentation/bloc/wallet_bloc.dart';
import '../../data/models/service_model.dart';
import '../../data/models/booking_model.dart';

// Events
abstract class ServicesEvent extends Equatable {
  const ServicesEvent();
  @override
  List<Object?> get props => [];
}

class LoadServices extends ServicesEvent {}

class SyncServices extends ServicesEvent {
  final List<ServiceModel> updatedServices;
  const SyncServices(this.updatedServices);

  @override
  List<Object?> get props => [updatedServices];
}

class BookService extends ServicesEvent {
  final ServiceModel service;
  final bool useTokens;

  const BookService({required this.service, required this.useTokens});

  @override
  List<Object?> get props => [service, useTokens];
}

class ConfirmBooking extends ServicesEvent {
  final ServiceModel service;
  final bool useTokens;
  final DateTime dateTime;
  final String location;

  const ConfirmBooking({
    required this.service,
    required this.useTokens,
    required this.dateTime,
    required this.location,
  });

  @override
  List<Object?> get props => [service, useTokens, dateTime, location];
}

class UpdateBookingStatus extends ServicesEvent {
  final String bookingId;
  final BookingStatus status;

  const UpdateBookingStatus({required this.bookingId, required this.status});

  @override
  List<Object?> get props => [bookingId, status];
}

class DismissBooking extends ServicesEvent {
  final String bookingId;
  const DismissBooking(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

// States
abstract class ServicesState extends Equatable {
  const ServicesState();
  @override
  List<Object?> get props => [];
}

class ServicesInitial extends ServicesState {}

class ServicesLoading extends ServicesState {}

class ServicesLoaded extends ServicesState {
  final List<ServiceModel> services;
  final List<BookingModel> activeBookings;
  final String? bookingStatus;

  const ServicesLoaded({
    required this.services,
    this.activeBookings = const [],
    this.bookingStatus,
  });

  @override
  List<Object?> get props => [services, activeBookings, bookingStatus];
}

class ServiceBookingSuccess extends ServicesState {
  final String message;
  const ServiceBookingSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  final WalletBloc walletBloc;
  final LocalStorageService storage;
  final List<BookingModel> _activeBookings = [];
  Timer? _syncTimer;

  ServicesBloc({required this.walletBloc, required this.storage})
    : super(ServicesInitial()) {
    on<LoadServices>(_onLoadServices);
    on<SyncServices>(_onSyncServices);
    on<BookService>(_onBookService);
    on<ConfirmBooking>(_onConfirmBooking);
    on<UpdateBookingStatus>(_onUpdateBookingStatus);
    on<DismissBooking>(_onDismissBooking);
  }

  void _onLoadServices(LoadServices event, Emitter<ServicesState> emit) async {
    emit(ServicesLoading());
    await Future.delayed(const Duration(milliseconds: 300));

    final savedBookings = storage.getBookings();
    _activeBookings.clear();
    _activeBookings.addAll(savedBookings);

    emit(
      ServicesLoaded(services: _mockServices, activeBookings: _activeBookings),
    );

    _startSyncTimer();
  }

  void _onSyncServices(SyncServices event, Emitter<ServicesState> emit) {
    if (state is ServicesLoaded) {
      emit(
        ServicesLoaded(
          services: event.updatedServices,
          activeBookings: (state as ServicesLoaded).activeBookings,
          bookingStatus: (state as ServicesLoaded).bookingStatus,
        ),
      );
    }
  }

  void _startSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final updatedServices = _mockServices.map((service) {
        // Slightly randomize price +/- 5%
        final priceChange = (DateTime.now().second % 10 - 5) / 100.0;
        final newPrice = service.price * (1 + priceChange);

        // Randomly update availability info and status
        String? newAvailability = service.availabilityInfo;
        ServiceStatus newStatus = service.status;

        final minute = DateTime.now().minute;
        if (minute % 5 == 0) {
          newStatus = ServiceStatus.busy;
          newAvailability = "Available in 15 mins";
        } else if (minute % 3 == 0) {
          newStatus = ServiceStatus.available;
          newAvailability = "High demand now";
        } else {
          newStatus = ServiceStatus.available;
          newAvailability = "Available now";
        }

        return service.copyWith(
          price: double.parse(newPrice.toStringAsFixed(2)),
          availabilityInfo: newAvailability,
          status: newStatus,
        );
      }).toList();

      add(SyncServices(updatedServices));
    });
  }

  @override
  Future<void> close() {
    _syncTimer?.cancel();
    return super.close();
  }

  void _onBookService(BookService event, Emitter<ServicesState> emit) async {
    // This is handled via Navigation to selection page now,
    // but keeping it for legacy or direct quick booking
  }

  void _onConfirmBooking(
    ConfirmBooking event,
    Emitter<ServicesState> emit,
  ) async {
    final booking = BookingModel(
      id: "b_${DateTime.now().millisecondsSinceEpoch}",
      service: event.service,
      dateTime: event.dateTime,
      location: event.location,
      status: BookingStatus.confirmed,
      useTokens: event.useTokens,
      priceRM: event.useTokens ? null : event.service.price,
      priceTokens: event.useTokens ? event.service.tokenPrice : null,
    );

    _activeBookings.insert(0, booking);
    await storage.saveBookings(_activeBookings);

    walletBloc.add(
      DeductBalance(
        amountRM: event.useTokens ? null : event.service.price,
        amountTokens: event.useTokens ? event.service.tokenPrice : null,
        description: "${event.service.name} Booking",
      ),
    );

    emit(
      const ServiceBookingSuccess(
        "Booking confirmed! We're preparing your service.",
      ),
    );

    // Simulation of live updates
    _simulateLiveUpdates(booking.id);

    // Reset to loaded state after short delay
    await Future.delayed(const Duration(seconds: 1));
    emit(
      ServicesLoaded(
        services: state is ServicesLoaded
            ? (state as ServicesLoaded).services
            : _mockServices,
        activeBookings: List.from(_activeBookings),
      ),
    );
  }

  void _onUpdateBookingStatus(
    UpdateBookingStatus event,
    Emitter<ServicesState> emit,
  ) async {
    final index = _activeBookings.indexWhere((b) => b.id == event.bookingId);
    if (index != -1) {
      _activeBookings[index] = _activeBookings[index].copyWith(
        status: event.status,
      );
      await storage.saveBookings(_activeBookings);

      if (state is ServicesLoaded) {
        emit(
          ServicesLoaded(
            services: (state as ServicesLoaded).services,
            activeBookings: List.from(_activeBookings),
          ),
        );
      }
    }
  }

  void _onDismissBooking(
    DismissBooking event,
    Emitter<ServicesState> emit,
  ) async {
    _activeBookings.removeWhere((b) => b.id == event.bookingId);
    await storage.saveBookings(_activeBookings);

    if (state is ServicesLoaded) {
      emit(
        ServicesLoaded(
          services: (state as ServicesLoaded).services,
          activeBookings: List.from(_activeBookings),
        ),
      );
    }
  }

  void _simulateLiveUpdates(String bookingId) async {
    await Future.delayed(const Duration(seconds: 10));
    add(
      UpdateBookingStatus(
        bookingId: bookingId,
        status: BookingStatus.inProgress,
      ),
    );

    await Future.delayed(const Duration(seconds: 15));
    add(
      UpdateBookingStatus(
        bookingId: bookingId,
        status: BookingStatus.completed,
      ),
    );
  }

  final List<ServiceModel> _mockServices = [
    const ServiceModel(
      id: "v1",
      name: "Valet Parking",
      description: "Premium valet parking at Main Entrance",
      price: 15.0,
      tokenPrice: 150,
      icon: Icons.local_parking,
      availabilityInfo: "Available now",
    ),
    const ServiceModel(
      id: "w1",
      name: "Car Wash",
      description: "Full interior and exterior wash",
      price: 25.0,
      tokenPrice: 200,
      icon: Icons.local_car_wash,
      availabilityInfo: "Available now",
    ),
    const ServiceModel(
      id: "b1",
      name: "Bay Reservation",
      description: "Reserve a charging/parking bay",
      price: 10.0,
      tokenPrice: 100,
      icon: Icons.ev_station,
      status: ServiceStatus.busy,
      availabilityInfo: "Available in 15 mins",
    ),
  ];
}
