/// Maps raw exceptions to user-friendly error messages.
/// Prevents internal exception details from leaking to the UI.
class ErrorMapper {
  static String toUserMessage(Object error) {
    final msg = error.toString().toLowerCase();

    if (msg.contains('permission-denied') || msg.contains('permission denied')) {
      return 'Access denied. Please sign out and sign in again.';
    }
    if (msg.contains('unavailable') || msg.contains('network-request-failed')) {
      return 'No internet connection. Please check your network.';
    }
    if (msg.contains('not-found')) {
      return 'Data not found. It may have been deleted.';
    }
    if (msg.contains('already-exists')) {
      return 'This item already exists.';
    }
    if (msg.contains('cancelled') || msg.contains('canceled')) {
      return 'Operation was cancelled.';
    }
    if (msg.contains('unauthenticated') || msg.contains('sign_in_canceled')) {
      return 'Please sign in to continue.';
    }
    if (msg.contains('quota-exceeded') || msg.contains('resource-exhausted')) {
      return 'Service limit reached. Please try again later.';
    }

    return 'Something went wrong. Please try again.';
  }
}
