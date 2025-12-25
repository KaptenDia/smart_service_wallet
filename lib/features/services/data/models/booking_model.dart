import 'package:equatable/equatable.dart';
import 'service_model.dart';

enum BookingStatus { pending, confirmed, inProgress, completed, cancelled }

class BookingModel extends Equatable {
  final String id;
  final ServiceModel service;
  final DateTime dateTime;
  final String location;
  final BookingStatus status;
  final bool useTokens;
  final double? priceRM;
  final int? priceTokens;

  const BookingModel({
    required this.id,
    required this.service,
    required this.dateTime,
    required this.location,
    required this.status,
    required this.useTokens,
    this.priceRM,
    this.priceTokens,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'service': service.toJson(),
    'dateTime': dateTime.toIso8601String(),
    'location': location,
    'status': status.name,
    'useTokens': useTokens,
    'priceRM': priceRM,
    'priceTokens': priceTokens,
  };

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
    id: json['id'],
    service: ServiceModel.fromJson(json['service']),
    dateTime: DateTime.parse(json['dateTime']),
    location: json['location'],
    status: BookingStatus.values.byName(json['status']),
    useTokens: json['useTokens'],
    priceRM: json['priceRM'],
    priceTokens: json['priceTokens'],
  );

  BookingModel copyWith({
    String? id,
    ServiceModel? service,
    DateTime? dateTime,
    String? location,
    BookingStatus? status,
    bool? useTokens,
    double? priceRM,
    int? priceTokens,
  }) {
    return BookingModel(
      id: id ?? this.id,
      service: service ?? this.service,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      status: status ?? this.status,
      useTokens: useTokens ?? this.useTokens,
      priceRM: priceRM ?? this.priceRM,
      priceTokens: priceTokens ?? this.priceTokens,
    );
  }

  @override
  List<Object?> get props => [
    id,
    service,
    dateTime,
    location,
    status,
    useTokens,
    priceRM,
    priceTokens,
  ];
}
