# Smart Service Wallet

A modern Flutter application for managing services, wallet balance, and rewards.

## 1. Setup Instructions

### Prerequisites
- **Flutter SDK**: `^3.10.4`
- **Dart SDK**: `^3.0.0`
- **Operating System**: Windows, macOS, or Linux

### Installation Steps
1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/smart_service_wallet.git
   cd smart_service_wallet
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the application**:
   ```bash
   flutter run
   ```

## 2. Project Structure & State Management

### Project Structure
The project follows a Clean Architecture approach within the `lib` folder:
- **core/**: Shared models, constants, and utilities.
- **features/**: Functional modules of the application.
  - **home/**: Dashboard and user greeting.
  - **services/**: Service listings and booking flow.
  - **wallet/**: Transaction history and balance management.
  - **rewards/**: Loyalty tokens and voucher management.

### State Management
We use **flutter_bloc** for state management to ensure a predictable and testable flow of data across the application. **GetIt** is used for dependency injection.

## 3. Feature Summary
- **Wallet Management**: Track credits and GP loyalty tokens.
- **Service Booking**: Browse and book services (e.g., Valet Parking, Car Wash) with real-time availability.
- **Rewards System**: Claim vouchers using loyalty tokens and manage claimed offers.
- **Transaction History**: Detailed view of past service bookings and wallet activity.
- **Premium UI**: Glassmorphism effects, smooth animations, and high-quality typography.

## 4. Automated Testing
The project includes unit and widget tests to ensure stability.

### Sample Widget Test
```dart
testWidgets('Home Page displays user balance correctly', (WidgetTester tester) async {
  await tester.pumpWidget(createWidgetUnderTest());
  await tester.pump();

  // Verify balance card content
  expect(find.text('Total Balance'), findsOneWidget);
  expect(find.text('RM 500.00'), findsOneWidget);
  expect(find.text('1000 GP'), findsOneWidget);
});
```

## 5. Screenshots
![Home Screen](screenshots/WhatsApp%20Image%202025-12-25%20at%2022.30.22_29e46f9a.jpg)
![Wallet Details](screenshots/WhatsApp%20Image%202025-12-25%20at%2022.30.22_7a3e7ec8.jpg)
![Services List](screenshots/WhatsApp%20Image%202025-12-25%20at%2022.30.22_cb52c233.jpg)
![Booking Flow](screenshots/WhatsApp%20Image%202025-12-25%20at%2022.30.23_1781b7df.jpg)
![Rewards Page](screenshots/WhatsApp%20Image%202025-12-25%20at%2022.30.23_28a28919.jpg)
![Voucher Details](screenshots/WhatsApp%20Image%202025-12-25%20at%2022.30.23_6c5a003c.jpg)
![Transaction History](screenshots/WhatsApp%20Image%202025-12-25%20at%2022.30.23_ee5e0ae8.jpg)
![Settings](screenshots/WhatsApp%20Image%202025-12-25%20at%2022.30.24_056843d7.jpg)
![Profile](screenshots/WhatsApp%20Image%202025-12-25%20at%2022.30.24_7dec90bf.jpg)
![Login](screenshots/WhatsApp%20Image%202025-12-25%20at%2022.30.24_a473e3d9.jpg)
![Onboarding](screenshots/WhatsApp%20Image%202025-12-25%20at%2022.30.25_44aa94ed.jpg)
![Notifications](screenshots/WhatsApp%20Image%202025-12-25%20at%2022.30.25_61f73dfc.jpg)
![Analytics](screenshots/WhatsApp%20Image%202025-12-25%20at%2022.30.25_c6afc5d9.jpg)
![Support](screenshots/WhatsApp%20Image%202025-12-25%20at%2022.30.26_391d9613.jpg)
![FAQ](screenshots/WhatsApp%20Image%202025-12-25%20at%2022.30.26_6dd89a1a.jpg)
