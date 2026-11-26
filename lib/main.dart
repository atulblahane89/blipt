import 'package:flutter/material.dart';
import 'state/app_state.dart';
import 'screens/role_switcher_bar.dart';
import 'screens/consumer/consumer_home_screen.dart';
import 'screens/merchant/merchant_hub_screen.dart';
import 'screens/delivery/delivery_task_screen.dart';

void main() {
  runApp(const BliptoApp());
}

class BliptoApp extends StatefulWidget {
  const BliptoApp({Key? key}) : super(key: key);

  @override
  State<BliptoApp> createState() => _BliptoAppState();
}

class _BliptoAppState extends State<BliptoApp> {
  final AppState _appState = AppState();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blipto',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF00B074),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00B074),
          primary: const Color(0xFF00B074),
          secondary: const Color(0xFF0F172A),
        ),
        fontFamily: 'Roboto',
      ),
      home: BliptoMainShell(state: _appState),
    );
  }
}

class BliptoMainShell extends StatelessWidget {
  final AppState state;

  const BliptoMainShell({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        return Scaffold(
          body: Column(
            children: [
              // Sticky Unified Role Switcher Bar (Consumer | Merchant Hub | Delivery)
              RoleSwitcherBar(state: state),
              // Body dynamically switches according to active role
              Expanded(
                child: _buildRoleScreen(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoleScreen() {
    switch (state.currentRole) {
      case AppRole.consumer:
        return ConsumerHomeScreen(state: state);
      case AppRole.merchant:
        return MerchantHubScreen(state: state);
      case AppRole.deliveryStaff:
        return DeliveryTaskScreen(state: state);
    }
  }
}
