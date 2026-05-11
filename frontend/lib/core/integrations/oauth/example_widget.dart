// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'oauth.dart';

/// Example widget showing how to use OAuth service
///
/// This is a complete example that can be used as a reference
/// for implementing OAuth in your UI.
///
/// DO NOT use this file directly - copy the patterns to your own widgets.
class _OAuthExampleWidget extends ConsumerStatefulWidget {
  const _OAuthExampleWidget();

  @override
  ConsumerState<_OAuthExampleWidget> createState() =>
      _OAuthExampleWidgetState();
}

class _OAuthExampleWidgetState extends ConsumerState<_OAuthExampleWidget> {
  // OAuth configurations (in real app, get from environment)
  late final OAuthConfig spotifyConfig;
  late final OAuthConfig githubConfig;
  late final OAuthConfig googleConfig;

  @override
  void initState() {
    super.initState();

    // Initialize configurations
    spotifyConfig = OAuthConfig.spotify(
      clientId: const String.fromEnvironment('SPOTIFY_CLIENT_ID'),
      scopes: [
        'user-read-playback-state',
        'user-modify-playback-state',
        'playlist-read-private',
      ],
    );

    githubConfig = OAuthConfig.github(
      clientId: const String.fromEnvironment('GITHUB_CLIENT_ID'),
      clientSecret: const String.fromEnvironment('GITHUB_CLIENT_SECRET'),
      scopes: ['repo', 'user', 'gist'],
    );

    googleConfig = OAuthConfig.google(
      clientId: const String.fromEnvironment('GOOGLE_CLIENT_ID'),
      scopes: [
        'https://www.googleapis.com/auth/gmail.readonly',
        'https://www.googleapis.com/auth/calendar.events',
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch OAuth flow state
    final flowStatus = ref.watch(oauthFlowNotifierProvider);

    // Listen for flow completion
    ref.listen(oauthFlowNotifierProvider, (previous, next) {
      if (previous == null) return;

      if (next.isSuccess) {
        _showSuccess(next.tokens!.service);
      } else if (next.hasError) {
        _showError(next.errorMessage ?? 'Unknown error');
      } else if (next.wasCancelled) {
        _showMessage('Authentication cancelled');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('OAuth Example'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // OAuth flow status indicator
          _buildStatusCard(flowStatus),

          const SizedBox(height: 24),

          // Spotify integration
          _buildProviderCard(
            title: 'Spotify',
            icon: Icons.music_note,
            color: Colors.green,
            providerId: 'spotify',
            config: spotifyConfig,
          ),

          const SizedBox(height: 16),

          // GitHub integration
          _buildProviderCard(
            title: 'GitHub',
            icon: Icons.code,
            color: Colors.black,
            providerId: 'github',
            config: githubConfig,
          ),

          const SizedBox(height: 16),

          // Google integration
          _buildProviderCard(
            title: 'Google',
            icon: Icons.email,
            color: Colors.red,
            providerId: 'google',
            config: googleConfig,
          ),

          const SizedBox(height: 24),

          // Debug section
          _buildDebugSection(),
        ],
      ),
    );
  }

  /// Build status indicator card
  Widget _buildStatusCard(OAuthFlowStatus status) {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    switch (status.state) {
      case OAuthFlowState.idle:
        statusText = 'Ready';
        statusColor = Colors.grey;
        statusIcon = Icons.check_circle_outline;
        break;
      case OAuthFlowState.launching:
        statusText = 'Opening browser...';
        statusColor = Colors.blue;
        statusIcon = Icons.open_in_browser;
        break;
      case OAuthFlowState.waitingForAuth:
        statusText = 'Waiting for authentication...';
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
      case OAuthFlowState.exchangingCode:
        statusText = 'Exchanging code for tokens...';
        statusColor = Colors.purple;
        statusIcon = Icons.sync;
        break;
      case OAuthFlowState.success:
        statusText = 'Success!';
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case OAuthFlowState.error:
        statusText = 'Error: ${status.errorMessage}';
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      case OAuthFlowState.cancelled:
        statusText = 'Cancelled';
        statusColor = Colors.grey;
        statusIcon = Icons.cancel;
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OAuth Status',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: TextStyle(color: statusColor),
                  ),
                ],
              ),
            ),
            if (status.isInProgress) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  /// Build provider card with connect/disconnect button
  Widget _buildProviderCard({
    required String title,
    required IconData icon,
    required Color color,
    required String providerId,
    required OAuthConfig config,
  }) {
    final isAuthenticatedAsync = ref.watch(
      isAuthenticatedProvider((providerId: providerId, config: config)),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  isAuthenticatedAsync.when(
                    data: (isAuthenticated) => Text(
                      isAuthenticated ? 'Connected' : 'Not connected',
                      style: TextStyle(
                        color: isAuthenticated ? Colors.green : Colors.grey,
                      ),
                    ),
                    loading: () => const Text('Checking...'),
                    error: (error, stackTrace) => const Text('Error checking status'),
                  ),
                ],
              ),
            ),
            isAuthenticatedAsync.when(
              data: (isAuthenticated) => isAuthenticated
                  ? _buildDisconnectButton(providerId, config)
                  : _buildConnectButton(providerId, config),
              loading: () => const CircularProgressIndicator(),
              error: (error, stackTrace) => const Icon(Icons.error, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  /// Build connect button
  Widget _buildConnectButton(String providerId, OAuthConfig config) {
    final flowStatus = ref.watch(oauthFlowNotifierProvider);
    final isCurrentlyAuthenticating =
        flowStatus.isInProgress && flowStatus.providerId == providerId;

    return ElevatedButton(
      onPressed: isCurrentlyAuthenticating
          ? null
          : () => _handleConnect(config),
      child: isCurrentlyAuthenticating
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Connect'),
    );
  }

  /// Build disconnect button
  Widget _buildDisconnectButton(String providerId, OAuthConfig config) {
    return OutlinedButton(
      onPressed: () => _handleDisconnect(providerId, config),
      child: const Text('Disconnect'),
    );
  }

  /// Build debug section
  Widget _buildDebugSection() {
    final authenticatedProvidersAsync = ref.watch(
      authenticatedProvidersProvider,
    );

    return ExpansionTile(
      title: const Text('Debug Info'),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Authenticated Providers:'),
              const SizedBox(height: 8),
              authenticatedProvidersAsync.when(
                data: (providers) => providers.isEmpty
                    ? const Text('None')
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: providers
                            .map((p) => Text('• $p'))
                            .toList(),
                      ),
                loading: () => const CircularProgressIndicator(),
                error: (error, stackTrace) => const Text('Error loading providers'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _handleClearAll,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Clear All Tokens'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Handle connect button press
  Future<void> _handleConnect(OAuthConfig config) async {
    final flowNotifier = ref.read(oauthFlowNotifierProvider.notifier);
    await flowNotifier.startFlow(config);

    // State is handled by listener in build()
  }

  /// Handle disconnect button press
  Future<void> _handleDisconnect(String providerId, OAuthConfig config) async {
    final confirmed = await _showConfirmDialog(
      'Disconnect from ${config.providerId}?',
    );

    if (confirmed == true) {
      final flowNotifier = ref.read(oauthFlowNotifierProvider.notifier);
      await flowNotifier.logout(providerId, config: config);

      // Refresh authentication status
      ref.invalidate(
        isAuthenticatedProvider((providerId: providerId, config: config)),
      );

      _showMessage('Disconnected from ${config.providerId}');
    }
  }

  /// Handle clear all tokens
  Future<void> _handleClearAll() async {
    final confirmed = await _showConfirmDialog(
      'Clear all OAuth tokens?',
    );

    if (confirmed == true) {
      final oauthService = ref.read(oauthServiceProvider);
      await oauthService.clearAllTokens();

      // Refresh all authentication statuses
      ref.invalidate(isAuthenticatedProvider);
      ref.invalidate(authenticatedProvidersProvider);

      _showMessage('All tokens cleared');
    }
  }

  /// Show confirmation dialog
  Future<bool?> _showConfirmDialog(String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  /// Show success message
  void _showSuccess(String provider) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully connected to $provider'),
        backgroundColor: Colors.green,
      ),
    );

    // Reset flow state
    ref.read(oauthFlowNotifierProvider.notifier).reset();

    // Refresh authentication status
    ref.invalidate(isAuthenticatedProvider);
    ref.invalidate(authenticatedProvidersProvider);
  }

  /// Show error message
  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $message'),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ref.read(oauthFlowNotifierProvider.notifier).reset();
          },
        ),
      ),
    );
  }

  /// Show general message
  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );

    // Reset flow state
    ref.read(oauthFlowNotifierProvider.notifier).reset();
  }
}

/// Simple example showing minimal OAuth usage
class _MinimalOAuthExample extends ConsumerWidget {
  const _MinimalOAuthExample();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flowNotifier = ref.watch(oauthFlowNotifierProvider.notifier);
    final flowStatus = ref.watch(oauthFlowNotifierProvider);

    return ElevatedButton(
      onPressed: flowStatus.isInProgress
          ? null
          : () async {
              final config = OAuthConfig.spotify(
                clientId: 'your-client-id',
                scopes: ['user-read-playback-state'],
              );

              final success = await flowNotifier.startFlow(config);

              if (success) {
                // Success! Token: ${flowStatus.tokens?.accessToken}
              }
            },
      child: flowStatus.isInProgress
          ? const CircularProgressIndicator()
          : const Text('Connect Spotify'),
    );
  }
}
