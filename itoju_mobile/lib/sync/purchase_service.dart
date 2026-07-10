import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Paywalled cloud-sync purchase seam.
///
/// The full RevenueCat implementation (via `purchases_flutter`) lives on the
/// `feature/revenuecat` path: `configure()` -> Purchases.configure(apiKey,
/// appUserID: localAccountId); `bindTo(serverUserId)` -> Purchases.logIn(...);
/// `buySync()` -> getOfferings + purchasePackage, then refresh the server
/// entitlement and syncNow. It's decoupled here so the app builds without the
/// heavier IAP Android toolchain; entitlement GATING already runs server-side
/// (webhook -> /v1/user/entitlements), so this only handles the purchase UX.
///
/// While disabled, every method is a safe no-op and the app runs normally
/// (fully usable offline; cloud sync simply stays locked).
class PurchaseService {
  PurchaseService(this._ref);
  // ignore: unused_field
  final Ref _ref;

  bool get isEnabled => false;

  Future<void> configure() async {}

  Future<void> bindTo(String serverUserId) async {}

  Future<bool> buySync() async => false;

  Future<bool> restore() async => false;
}

final purchaseServiceProvider =
    Provider<PurchaseService>((ref) => PurchaseService(ref));
