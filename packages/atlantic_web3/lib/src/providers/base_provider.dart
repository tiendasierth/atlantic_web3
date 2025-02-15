import 'package:atlantic_web3/atlantic_web3.dart';
import 'package:json_rpc_2/json_rpc_2.dart' as rpc;
import 'package:stream_channel/stream_channel.dart';

/// Signature for a function that opens a socket on which json-rpc operations
/// can be performed.
///
/// Typically, this would be a websocket. The `web_socket_channel` package on
/// pub is suitable to create websockets. An implementation using that library
/// could look like this:
/// ```dart
/// import "package:web3dart/atlantic_web3.dart";
/// import "package:web_socket_channel/io.dart";
///
/// final client = Web3Client(rpcUrl, Client(), socketConnector: () {
///    return IOWebSocketChannel.connect(wsUrl).cast<String>();
/// });
/// ```
typedef SocketConnector = StreamChannel<String> Function();

abstract class BaseProvider {
  late final String _url;

  BaseProvider(this._url);

  String get url => _url;

  Future<T> request<T>(String function, [List<dynamic>? params]);

  rpc.Peer? connectWithPeer(FilterEngine filters);

  SocketConnector? getSocketConnector();

  Future? dispose();
}
