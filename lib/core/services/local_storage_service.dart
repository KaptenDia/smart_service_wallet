import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_service_wallet/core/models/wallet_balance.dart';
import 'package:smart_service_wallet/features/wallet/data/models/transaction_model.dart';
import 'package:smart_service_wallet/features/services/data/models/booking_model.dart';
import 'package:smart_service_wallet/features/rewards/data/models/offer_model.dart';

class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static const _keyWalletBalance = 'wallet_balance';
  static const _keyTransactions = 'transactions';
  static const _keyBookings = 'bookings';
  static const _keyClaimedOffers = 'claimed_offers';

  // Wallet
  Future<void> saveWalletBalance(WalletBalance balance) async {
    final Map<String, dynamic> data = {
      'credits': balance.credits,
      'loyaltyTokens': balance.loyaltyTokens,
    };
    await _prefs.setString(_keyWalletBalance, jsonEncode(data));
  }

  WalletBalance? getWalletBalance() {
    final String? data = _prefs.getString(_keyWalletBalance);
    if (data == null) return null;
    final Map<String, dynamic> map = jsonDecode(data);
    return WalletBalance(
      credits: (map['credits'] as num).toDouble(),
      loyaltyTokens: map['loyaltyTokens'] as int,
    );
  }

  // Transactions
  Future<void> saveTransactions(List<TransactionModel> transactions) async {
    final List<String> data = transactions
        .map((tx) => jsonEncode(tx.toJson()))
        .toList();
    await _prefs.setStringList(_keyTransactions, data);
  }

  List<TransactionModel> getTransactions() {
    final List<String>? data = _prefs.getStringList(_keyTransactions);
    if (data == null) return [];
    return data
        .map((item) => TransactionModel.fromJson(jsonDecode(item)))
        .toList();
  }

  // Active Bookings
  Future<void> saveBookings(List<BookingModel> bookings) async {
    final List<String> data = bookings
        .map((b) => jsonEncode(b.toJson()))
        .toList();
    await _prefs.setStringList(_keyBookings, data);
  }

  List<BookingModel> getBookings() {
    final List<String>? data = _prefs.getStringList(_keyBookings);
    if (data == null) return [];
    return data.map((item) => BookingModel.fromJson(jsonDecode(item))).toList();
  }

  // Claimed Offers
  Future<void> saveClaimedOffers(List<OfferModel> offers) async {
    final List<String> data = offers
        .map((offer) => jsonEncode(offer.toJson()))
        .toList();
    await _prefs.setStringList(_keyClaimedOffers, data);
  }

  List<OfferModel> getClaimedOffers() {
    final List<String>? data = _prefs.getStringList(_keyClaimedOffers);
    if (data == null) return [];
    return data.map((item) => OfferModel.fromJson(jsonDecode(item))).toList();
  }
}
