import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_service_wallet/core/models/wallet_balance.dart';
import 'package:smart_service_wallet/core/services/local_storage_service.dart';
import 'package:smart_service_wallet/features/wallet/data/models/transaction_model.dart';
import 'package:smart_service_wallet/features/wallet/presentation/bloc/wallet_bloc.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}

class FakeWalletBalance extends Fake implements WalletBalance {}

class FakeTransactionModel extends Fake implements TransactionModel {}

void main() {
  late WalletBloc walletBloc;
  late MockLocalStorageService mockLocalStorageService;

  setUpAll(() {
    registerFallbackValue(FakeWalletBalance());
    registerFallbackValue(<TransactionModel>[]);
  });

  setUp(() {
    mockLocalStorageService = MockLocalStorageService();
    walletBloc = WalletBloc(storage: mockLocalStorageService);
  });

  tearDown(() {
    walletBloc.close();
  });

  test('initial state should be WalletInitial', () {
    expect(walletBloc.state, WalletInitial());
  });

  group('LoadWallet', () {
    final tBalance = WalletBalance.initial();

    blocTest<WalletBloc, WalletState>(
      'emits [WalletLoading, WalletLoaded] when LoadWallet is added',
      build: () {
        when(
          () => mockLocalStorageService.getWalletBalance(),
        ).thenReturn(tBalance);
        when(() => mockLocalStorageService.getTransactions()).thenReturn([]);
        return walletBloc;
      },
      act: (bloc) => bloc.add(LoadWallet()),
      wait: const Duration(milliseconds: 500),
      expect: () => [
        WalletLoading(),
        WalletLoaded(balance: tBalance, transactions: const []),
      ],
    );
  });

  group('TopUp', () {
    final tInitialBalance = WalletBalance.initial();
    const tAmount = 100.0;
    final tNewBalance = tInitialBalance.copyWith(
      credits: tInitialBalance.credits + tAmount,
    );

    blocTest<WalletBloc, WalletState>(
      'emits WalletLoaded with increased credits when TopUp is added',
      build: () {
        when(
          () => mockLocalStorageService.saveWalletBalance(any()),
        ).thenAnswer((_) async => {});
        when(
          () => mockLocalStorageService.saveTransactions(any()),
        ).thenAnswer((_) async => {});
        return walletBloc;
      },
      seed: () =>
          WalletLoaded(balance: tInitialBalance, transactions: const []),
      act: (bloc) => bloc.add(const TopUp(tAmount)),
      expect: () => [
        isA<WalletLoaded>().having(
          (s) => s.balance.credits,
          'credits',
          tNewBalance.credits,
        ),
      ],
    );
  });

  group('DeductBalance', () {
    final tInitialBalance = WalletBalance.initial();
    const tAmount = 50.0;
    final tNewBalance = tInitialBalance.copyWith(
      credits: tInitialBalance.credits - tAmount,
    );

    blocTest<WalletBloc, WalletState>(
      'emits WalletLoaded with decreased credits when DeductBalance is added',
      build: () {
        when(
          () => mockLocalStorageService.saveWalletBalance(any()),
        ).thenAnswer((_) async => {});
        when(
          () => mockLocalStorageService.saveTransactions(any()),
        ).thenAnswer((_) async => {});
        return walletBloc;
      },
      seed: () =>
          WalletLoaded(balance: tInitialBalance, transactions: const []),
      act: (bloc) => bloc.add(
        const DeductBalance(amountRM: tAmount, description: 'Test Deduction'),
      ),
      expect: () => [
        isA<WalletLoaded>().having(
          (s) => s.balance.credits,
          'credits',
          tNewBalance.credits,
        ),
      ],
    );
  });
}
