import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_service_wallet/core/di/injection_container.dart' as di;
import 'package:smart_service_wallet/core/theme/app_theme.dart';
import 'package:smart_service_wallet/features/main/presentation/pages/main_page.dart';
import 'package:smart_service_wallet/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:smart_service_wallet/features/services/presentation/bloc/services_bloc.dart';
import 'package:smart_service_wallet/features/rewards/presentation/bloc/rewards_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.sl<WalletBloc>()..add(LoadWallet()),
        ),
        BlocProvider(
          create: (context) => di.sl<ServicesBloc>()..add(LoadServices()),
        ),
        BlocProvider(
          create: (context) => di.sl<RewardsBloc>()..add(LoadRewards()),
        ),
      ],
      child: MaterialApp(
        title: 'Smart Wallet',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainPage(),
      ),
    );
  }
}
