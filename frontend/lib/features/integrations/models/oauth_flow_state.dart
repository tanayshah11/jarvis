/// Represents the state of an OAuth authentication flow.
enum OAuthFlowState {
  /// Initial state before launching browser.
  idle,

  /// Browser is being launched.
  launching,

  /// Waiting for user to complete authentication in browser.
  waitingForAuth,

  /// Exchanging authorization code for tokens.
  exchangingCode,

  /// Successfully connected.
  success,

  /// Authentication failed with an error.
  error,

  /// User cancelled the flow.
  cancelled,
}

/// Extension to provide display text for OAuth flow states.
extension OAuthFlowStateExtension on OAuthFlowState {
  /// Get the display message for this state.
  String get message {
    switch (this) {
      case OAuthFlowState.idle:
        return 'Ready to connect';
      case OAuthFlowState.launching:
        return 'Opening browser...';
      case OAuthFlowState.waitingForAuth:
        return 'Complete sign-in in your browser';
      case OAuthFlowState.exchangingCode:
        return 'Connecting...';
      case OAuthFlowState.success:
        return 'Connected!';
      case OAuthFlowState.error:
        return 'Connection failed';
      case OAuthFlowState.cancelled:
        return 'Cancelled';
    }
  }

  /// Whether this state is a terminal state.
  bool get isTerminal {
    return this == OAuthFlowState.success ||
        this == OAuthFlowState.error ||
        this == OAuthFlowState.cancelled;
  }

  /// Whether this state is loading/processing.
  bool get isLoading {
    return this == OAuthFlowState.launching ||
        this == OAuthFlowState.waitingForAuth ||
        this == OAuthFlowState.exchangingCode;
  }
}
