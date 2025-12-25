import 'package:equatable/equatable.dart';

class WalletBalance extends Equatable {
  final double credits; // RM
  final int loyaltyTokens; // GP Coins

  const WalletBalance({required this.credits, required this.loyaltyTokens});

  factory WalletBalance.initial() =>
      const WalletBalance(credits: 500.0, loyaltyTokens: 1000);

  WalletBalance copyWith({double? credits, int? loyaltyTokens}) {
    return WalletBalance(
      credits: credits ?? this.credits,
      loyaltyTokens: loyaltyTokens ?? this.loyaltyTokens,
    );
  }

  Map<String, dynamic> toJson() => {
    'credits': credits,
    'loyaltyTokens': loyaltyTokens,
  };

  factory WalletBalance.fromJson(Map<String, dynamic> json) => WalletBalance(
    credits: (json['credits'] as num).toDouble(),
    loyaltyTokens: json['loyaltyTokens'] as int,
  );

  @override
  List<Object?> get props => [credits, loyaltyTokens];
}
