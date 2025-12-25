import 'package:equatable/equatable.dart';

class OfferModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int pointsRequired;
  final DateTime? expiry;
  final bool isClaimed;

  const OfferModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.pointsRequired,
    this.expiry,
    this.isClaimed = false,
  });

  OfferModel copyWith({bool? isClaimed, DateTime? expiry}) {
    return OfferModel(
      id: id,
      title: title,
      description: description,
      imageUrl: imageUrl,
      pointsRequired: pointsRequired,
      expiry: expiry ?? this.expiry,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'imageUrl': imageUrl,
    'pointsRequired': pointsRequired,
    'expiry': expiry?.toIso8601String(),
    'isClaimed': isClaimed,
  };

  factory OfferModel.fromJson(Map<String, dynamic> json) => OfferModel(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    imageUrl: json['imageUrl'],
    pointsRequired: json['pointsRequired'],
    expiry: json['expiry'] != null ? DateTime.parse(json['expiry']) : null,
    isClaimed: json['isClaimed'],
  );

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    imageUrl,
    pointsRequired,
    expiry,
    isClaimed,
  ];
}
