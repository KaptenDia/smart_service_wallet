import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_service_wallet/core/models/wallet_balance.dart';
import 'package:smart_service_wallet/features/home/presentation/pages/home_page.dart';
import 'package:smart_service_wallet/features/services/presentation/bloc/services_bloc.dart';
import 'package:smart_service_wallet/features/wallet/presentation/bloc/wallet_bloc.dart';

class MockWalletBloc extends Mock implements WalletBloc {}

class MockServicesBloc extends Mock implements ServicesBloc {}

void main() {
  late MockWalletBloc mockWalletBloc;
  late MockServicesBloc mockServicesBloc;

  setUp(() {
    mockWalletBloc = MockWalletBloc();
    mockServicesBloc = MockServicesBloc();

    // Mock WalletBloc state
    when(() => mockWalletBloc.state).thenReturn(
      const WalletLoaded(
        balance: WalletBalance(credits: 500.0, loyaltyTokens: 1000),
        transactions: [],
      ),
    );
    when(() => mockWalletBloc.stream).thenAnswer((_) => const Stream.empty());

    // Mock ServicesBloc state
    when(
      () => mockServicesBloc.state,
    ).thenReturn(const ServicesLoaded(services: [], activeBookings: []));
    when(() => mockServicesBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<WalletBloc>.value(value: mockWalletBloc),
          BlocProvider<ServicesBloc>.value(value: mockServicesBloc),
        ],
        child: const HomePage(),
      ),
    );
  }

  testWidgets('Home Page displays user balance correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    // Verify balance card content
    expect(find.text('Total Balance'), findsOneWidget);
    expect(find.text('RM 500.00'), findsOneWidget);
    expect(find.text('1000 GP'), findsOneWidget);
  });

  testWidgets('Home Page displays greeting and user name', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.text('John Doe'), findsOneWidget);
    expect(find.textContaining('Good'), findsOneWidget);
  });
}
