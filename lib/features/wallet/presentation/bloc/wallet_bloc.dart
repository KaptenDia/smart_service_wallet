import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_service_wallet/core/models/wallet_balance.dart';
import 'package:smart_service_wallet/features/wallet/data/models/transaction_model.dart';
import 'package:smart_service_wallet/core/services/local_storage_service.dart';

// Events
abstract class WalletEvent extends Equatable {
  const WalletEvent();
  @override
  List<Object?> get props => [];
}

class LoadWallet extends WalletEvent {}

class DeductBalance extends WalletEvent {
  final double? amountRM;
  final int? amountTokens;
  final String description;

  const DeductBalance({
    this.amountRM,
    this.amountTokens,
    required this.description,
  });

  @override
  List<Object?> get props => [amountRM, amountTokens, description];
}

class TopUp extends WalletEvent {
  final double amount;
  const TopUp(this.amount);
  @override
  List<Object?> get props => [amount];
}

class UpdateBalance extends WalletEvent {
  final double? creditsDelta;
  final int? tokensDelta;
  final String description;

  const UpdateBalance({
    this.creditsDelta,
    this.tokensDelta,
    required this.description,
  });

  @override
  List<Object?> get props => [creditsDelta, tokensDelta, description];
}

// States
abstract class WalletState extends Equatable {
  const WalletState();
  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final WalletBalance balance;
  final List<TransactionModel> transactions;

  const WalletLoaded({required this.balance, required this.transactions});

  @override
  List<Object?> get props => [balance, transactions];
}

class WalletError extends WalletState {
  final String message;
  const WalletError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final LocalStorageService storage;

  WalletBloc({required this.storage}) : super(WalletInitial()) {
    on<LoadWallet>(_onLoadWallet);
    on<DeductBalance>(_onDeductBalance);
    on<TopUp>(_onTopUp);
    on<UpdateBalance>(_onUpdateBalance);
  }

  void _onLoadWallet(LoadWallet event, Emitter<WalletState> emit) async {
    emit(WalletLoading());
    // Simulate slight delay for initial "feel" but load real data
    await Future.delayed(const Duration(milliseconds: 300));

    final balance = storage.getWalletBalance() ?? WalletBalance.initial();
    final transactions = storage.getTransactions();

    if (storage.getWalletBalance() == null) {
      await storage.saveWalletBalance(balance);
    }

    emit(WalletLoaded(balance: balance, transactions: transactions));
  }

  void _onDeductBalance(DeductBalance event, Emitter<WalletState> emit) async {
    if (state is WalletLoaded) {
      final current = (state as WalletLoaded);
      final newBalance = current.balance.copyWith(
        credits: event.amountRM != null
            ? current.balance.credits - event.amountRM!
            : null,
        loyaltyTokens: event.amountTokens != null
            ? current.balance.loyaltyTokens - event.amountTokens!
            : null,
      );

      final newTransaction = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: event.description,
        description: event.description,
        amount: event.amountRM ?? event.amountTokens?.toDouble() ?? 0,
        currency: event.amountRM != null ? "RM" : "GP",
        date: DateTime.now(),
        type: TransactionType.debit,
      );

      final newTransactions = [newTransaction, ...current.transactions];

      await storage.saveWalletBalance(newBalance);
      await storage.saveTransactions(newTransactions);

      emit(WalletLoaded(balance: newBalance, transactions: newTransactions));
    }
  }

  void _onTopUp(TopUp event, Emitter<WalletState> emit) async {
    if (state is WalletLoaded) {
      final current = (state as WalletLoaded);
      final newBalance = current.balance.copyWith(
        credits: current.balance.credits + event.amount,
      );

      final newTransaction = TransactionModel(
        id: "topup_${DateTime.now().millisecondsSinceEpoch}",
        title: "Wallet Top Up",
        description: "Added funds to wallet",
        amount: event.amount,
        currency: "RM",
        date: DateTime.now(),
        type: TransactionType.credit,
      );

      final newTransactions = [newTransaction, ...current.transactions];

      await storage.saveWalletBalance(newBalance);
      await storage.saveTransactions(newTransactions);

      emit(WalletLoaded(balance: newBalance, transactions: newTransactions));
    }
  }

  void _onUpdateBalance(UpdateBalance event, Emitter<WalletState> emit) async {
    if (state is WalletLoaded) {
      final current = (state as WalletLoaded);
      final newBalance = current.balance.copyWith(
        credits: event.creditsDelta != null
            ? current.balance.credits + event.creditsDelta!
            : null,
        loyaltyTokens: event.tokensDelta != null
            ? current.balance.loyaltyTokens + event.tokensDelta!
            : null,
      );

      final isCredit =
          (event.creditsDelta ?? 0) >= 0 && (event.tokensDelta ?? 0) >= 0;

      final newTransaction = TransactionModel(
        id: "update_${DateTime.now().millisecondsSinceEpoch}",
        title: event.description,
        description: event.description,
        amount: (event.creditsDelta ?? event.tokensDelta?.toDouble() ?? 0)
            .abs(),
        currency: event.creditsDelta != null ? "RM" : "GP",
        date: DateTime.now(),
        type: isCredit ? TransactionType.credit : TransactionType.debit,
      );

      final newTransactions = [newTransaction, ...current.transactions];

      await storage.saveWalletBalance(newBalance);
      await storage.saveTransactions(newTransactions);

      emit(WalletLoaded(balance: newBalance, transactions: newTransactions));
    }
  }
}
