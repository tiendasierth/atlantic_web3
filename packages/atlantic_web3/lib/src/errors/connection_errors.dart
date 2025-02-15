import '../../atlantic_web3.dart';

class ConnectionError extends BaseWeb3Error {
  int code = ERR_CONN;
  int? errorCode;
  String? errorReason;

  ConnectionError(super.message, ConnectionEvent? event, int code) {
    this.code = code;
    errorCode = event?.code;
    errorReason = event?.reason;
  }

  @override
  toJSON() {
    return {
      ...super.toJSON(),
      "errorCode": errorCode,
      "errorReason": errorReason
    };
  }
}

class InvalidConnectionError extends ConnectionError {
  String host;

  InvalidConnectionError(this.host, ConnectionEvent event)
      : super("CONNECTION ERROR: Couldn't connect to node $host.", event,
            ERR_CONN_INVALID);

  @override
  toJSON() {
    return {...super.toJSON(), host: host};
  }
}

class ConnectionTimeoutError extends ConnectionError {
  int duration;

  ConnectionTimeoutError(this.duration)
      : super("CONNECTION TIMEOUT: timeout of ${duration}ms achieved", null,
            ERR_CONN_TIMEOUT);

  @override
  toJSON() {
    return {...super.toJSON(), "duration": duration};
  }
}

class ConnectionNotOpenError extends ConnectionError {
  ConnectionNotOpenError(ConnectionEvent event)
      : super('Connection not open', event, ERR_CONN_NOT_OPEN);
}

class ConnectionCloseError extends ConnectionError {
  ConnectionCloseError(ConnectionEvent event)
      : super(
            "CONNECTION ERROR: The connection got closed with the close code ${event.code ?? ''} and the following reason string ${event.reason ?? ''}",
            event,
            ERR_CONN_CLOSE);
}

class MaxAttemptsReachedOnReconnectingError extends ConnectionError {
  MaxAttemptsReachedOnReconnectingError(int numberOfAttempts)
      : super(
            "Maximum number of reconnect attempts reached! ($numberOfAttempts)",
            null,
            ERR_CONN_MAX_ATTEMPTS);
}

class PendingRequestsOnReconnectingError extends ConnectionError {
  PendingRequestsOnReconnectingError()
      : super(
            'CONNECTION ERROR: Provider started to reconnect before the response got received!',
            null,
            ERR_CONN_PENDING_REQUESTS);
}

class RequestAlreadySentError extends ConnectionError {
  RequestAlreadySentError(int id)
      : super("Request already sent with following id: $id", null,
            ERR_REQ_ALREADY_SENT);
}

/// Exception thrown when an the server returns an error code to an rpc request.
class RPCError implements Exception {
  /// Constructor.
  const RPCError(this.errorCode, this.message, this.data);

  /// Error code.
  final int errorCode;

  /// Message.
  final String message;

  /// Data.
  final dynamic data;

  @override
  String toString() {
    return 'RPCError: got code $errorCode with msg "$message".';
  }
}
