import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/integration.dart';
import '../models/mock_integrations.dart';

/// State class for integrations.
class IntegrationsState {
  /// List of all integrations.
  final List<Integration> integrations;

  /// Whether data is currently loading.
  final bool isLoading;

  /// Error message if any.
  final String? error;

  const IntegrationsState({
    required this.integrations,
    this.isLoading = false,
    this.error,
  });

  IntegrationsState copyWith({
    List<Integration>? integrations,
    bool? isLoading,
    String? error,
  }) {
    return IntegrationsState(
      integrations: integrations ?? this.integrations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Get connected integrations.
  List<Integration> get connectedIntegrations =>
      integrations.where((i) => i.status == IntegrationStatus.connected).toList();

  /// Get available (disconnected) integrations.
  List<Integration> get availableIntegrations => integrations
      .where((i) =>
          i.status == IntegrationStatus.disconnected &&
          i.type != IntegrationType.local)
      .toList();

  /// Get local device integrations.
  List<Integration> get deviceIntegrations => integrations
      .where((i) =>
          i.type == IntegrationType.local &&
          i.status == IntegrationStatus.disconnected)
      .toList();

  /// Get connected local device integrations.
  List<Integration> get connectedDeviceIntegrations => integrations
      .where((i) =>
          i.type == IntegrationType.local && i.status == IntegrationStatus.connected)
      .toList();
}

/// Notifier for managing integrations state.
class IntegrationsNotifier extends Notifier<IntegrationsState> {
  @override
  IntegrationsState build() {
    return IntegrationsState(integrations: mockIntegrations);
  }

  /// Connect to an integration.
  Future<void> connectIntegration(String integrationId) async {
    // Set to connecting state
    final index =
        state.integrations.indexWhere((i) => i.id == integrationId);
    if (index == -1) return;

    final updatedIntegrations = List<Integration>.from(state.integrations);
    updatedIntegrations[index] = updatedIntegrations[index].copyWith(
      status: IntegrationStatus.connecting,
    );

    state = state.copyWith(integrations: updatedIntegrations);

    // Simulate connection delay
    await Future.delayed(const Duration(seconds: 2));

    // Update to connected state with mock account info
    final integration = state.integrations[index];
    final accountInfo = _getMockAccountInfo(integration);

    updatedIntegrations[index] = updatedIntegrations[index].copyWith(
      status: IntegrationStatus.connected,
      accountInfo: accountInfo,
    );

    state = state.copyWith(integrations: updatedIntegrations);
  }

  /// Disconnect from an integration.
  Future<void> disconnectIntegration(String integrationId) async {
    final index =
        state.integrations.indexWhere((i) => i.id == integrationId);
    if (index == -1) return;

    final updatedIntegrations = List<Integration>.from(state.integrations);
    updatedIntegrations[index] = updatedIntegrations[index].copyWith(
      status: IntegrationStatus.disconnected,
      accountInfo: null,
    );

    state = state.copyWith(integrations: updatedIntegrations);
  }

  String? _getMockAccountInfo(Integration integration) {
    switch (integration.type) {
      case IntegrationType.oauth:
        switch (integration.id) {
          case 'gmail':
            return 'john@gmail.com';
          case 'google_calendar':
            return 'john@gmail.com';
          case 'spotify':
            return 'john_music';
          case 'github':
            return 'johndev';
          case 'notion':
            return 'john@notion.so';
          default:
            return 'john@example.com';
        }
      case IntegrationType.local:
        return null; // Local integrations don't need account info
      case IntegrationType.apiKey:
        return 'API Key configured';
    }
  }
}

/// Provider for integrations controller.
final integrationsControllerProvider =
    NotifierProvider<IntegrationsNotifier, IntegrationsState>(() {
  return IntegrationsNotifier();
});
