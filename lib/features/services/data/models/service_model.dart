import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum ServiceStatus { available, busy, maintenance }

class ServiceModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final int tokenPrice;
  final IconData icon;
  final ServiceStatus status;

  final String? availabilityInfo;

  const ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.tokenPrice,
    required this.icon,
    this.status = ServiceStatus.available,
    this.availabilityInfo,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'tokenPrice': tokenPrice,
    'iconCodePoint': icon.codePoint,
    'status': status.name,
    'availabilityInfo': availabilityInfo,
  };

  factory ServiceModel.fromJson(Map<String, dynamic> json) => ServiceModel(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    price: (json['price'] as num).toDouble(),
    tokenPrice: json['tokenPrice'] as int,
    icon: IconData(json['iconCodePoint'], fontFamily: 'MaterialIcons'),
    status: ServiceStatus.values.byName(json['status']),
    availabilityInfo: json['availabilityInfo'],
  );

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    tokenPrice,
    icon,
    status,
    availabilityInfo,
  ];

  ServiceModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? tokenPrice,
    IconData? icon,
    ServiceStatus? status,
    String? availabilityInfo,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      tokenPrice: tokenPrice ?? this.tokenPrice,
      icon: icon ?? this.icon,
      status: status ?? this.status,
      availabilityInfo: availabilityInfo ?? this.availabilityInfo,
    );
  }
}
