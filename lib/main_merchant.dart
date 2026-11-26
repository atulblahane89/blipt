import 'package:flutter/material.dart';
import 'state/app_state.dart';
import 'screens/merchant/merchant_hub_screen.dart';

void main() {
  runApp(const BliptoMerchantApp());
}

class BliptoMerchantApp extends StatelessWidget {
  const BliptoMerchantApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    appState.switchRole(AppRole.merchant);

    return MaterialApp(
      title: 'Blipto Partner — Kirana Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF00B074),
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00B074),
          primary: const Color(0xFF00B074),
          secondary: const Color(0xFF0F172A),
        ),
      ),
      home: MerchantHubScreen(state: appState),
    );
  }
}
