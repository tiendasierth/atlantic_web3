import 'package:atlantic_web3/atlantic_web3.dart';
import 'package:http/http.dart';
import 'package:json_rpc_2/json_rpc_2.dart' as rpc;

import 'json_rpc.dart';

class HttpProvider extends BaseProvider {
  late final bool _printErrors;
  late final RpcService _jsonRpc;

  /// Some ethereum nodes support an event channel over websockets. Web3dart
  /// will use the [StreamChannel] returned by this function as a socket to send
  /// event requests and parse responses. Can be null, in which case a polling
  /// implementation for events will be used.
  late final SocketConnector? _socketConnector;

  rpc.Peer? _streamRpcPeer;

  HttpProvider(
    String url, {
    bool printErrors = false,
    SocketConnector? socketConnector,
  }) : super(url) {
    _printErrors = printErrors;
    _socketConnector = socketConnector;

    final httpClient = Client();
    _jsonRpc = JsonRPC(url, httpClient);
  }

  @override
  Future<T> request<T>(String function, [List<dynamic>? params]) async {
    try {
      final data = await _jsonRpc.call(function, params);
      // ignore: only_throw_errors
      if (data is Error || data is Exception) throw data;

      return data.result as T;
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      if (_printErrors) print(e);

      rethrow;
    }
  }

  @override
  rpc.Peer? connectWithPeer(FilterEngine filters) {
    if (_streamRpcPeer != null && !_streamRpcPeer!.isClosed) {
      return _streamRpcPeer;
    }
    if (_socketConnector == null) return null;

    final socket = _socketConnector();
    _streamRpcPeer = rpc.Peer(socket)
      ..registerMethod('eth_subscription', filters.handlePubSubNotification);

    _streamRpcPeer?.listen().then((dynamic _) {
      // .listen() will complete when the socket is closed, so reset client
      _streamRpcPeer = null;
      filters.handleConnectionClosed();
    });

    return _streamRpcPeer;
  }

  @override
  SocketConnector? getSocketConnector() => _socketConnector;

  @override
  Future? dispose() {
    return _streamRpcPeer?.close();
  }
}
