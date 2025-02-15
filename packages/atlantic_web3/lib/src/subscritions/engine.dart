import 'dart:async';

import 'package:atlantic_web3/atlantic_web3.dart';
import 'package:json_rpc_2/json_rpc_2.dart' as rpc;

class FilterEngine {
  // Variables
  Timer? _ticker;
  bool _isRefreshing = false;
  bool _clearingBecauseSocketClosed = false;

  // Constantes
  final BaseProvider _provider;
  final List<_InstantiatedFilter> _filters = [];
  final List<Future> _pendingUnsubcriptions = [];

  FilterEngine(this._provider);

  Stream<T> addFilter<T>(Filter<T> filter) {
    final pubSubAvailable = _provider.getSocketConnector() != null;

    late _InstantiatedFilter<T> instantiated;

    // parametros
    final myFilter = filter;
    final myIsPubSub = filter.supportsPubSub && pubSubAvailable;
    myCallBack() {
      _pendingUnsubcriptions.add(uninstall(instantiated));
    }

    // crear instancia
    instantiated = _InstantiatedFilter(myFilter, myIsPubSub, myCallBack);

    instantiated._controller.onListen = () {
      _filters.add(instantiated);

      if (instantiated.isPubSub) {
        _registerToPubSub(instantiated, filter.createPubSub());
      } else {
        _registerToAPI(instantiated);
        _startTicking();
      }
    };

    return instantiated._controller.stream;
  }

  Future<void> _registerToAPI(_InstantiatedFilter filter) async {
    final request = filter.filter.create();

    try {
      final response = await _provider.request(request.method, request.params);

      filter.id = response.result as String;
    } on RPCError catch (e, s) {
      filter._controller.addError(e, s);
      await filter._controller.close();
      _filters.remove(filter);
    }
  }

  Future<void> _registerToPubSub(
    _InstantiatedFilter filter,
    PubSubCreationParams params,
  ) async {
    final peer = _provider.connectWithPeer(this);

    try {
      final response = await peer?.sendRequest('eth_subscribe', params.params);

      filter.id = response as String;
    } on rpc.RpcException catch (e, s) {
      filter._controller.addError(e, s);
      await filter._controller.close();
      _filters.remove(filter);
    }
  }

  void _startTicking() {
    _ticker ??= Timer.periodic(_pingDuration, (_) => _refreshFilters());
  }

  Future<void> _refreshFilters() async {
    if (_isRefreshing) return;
    _isRefreshing = true;

    try {
      final filterSnapshot = List.of(_filters);

      for (final filter in filterSnapshot) {
        final updatedData =
            await _provider.request('eth_getFilterChanges', [filter.id]);

        for (final payload in updatedData.result) {
          if (!filter._controller.isClosed) {
            _parseAndAdd(filter, payload);
          }
        }
      }
    } finally {
      _isRefreshing = false;
    }
  }

  void handlePubSubNotification(rpc.Parameters params) {
    final id = params['subscription'].asString;
    final result = params['result'].value;

    final filter = _filters.singleWhere((f) => f.isPubSub && f.id == id);
    // orElse: () => null);
    _parseAndAdd(filter, result);
  }

  void handleConnectionClosed() {
    try {
      _clearingBecauseSocketClosed = true;
      final pubSubFilters = _filters.where((f) => f.isPubSub).toList();

      pubSubFilters.forEach(uninstall);
    } finally {
      _clearingBecauseSocketClosed = false;
    }
  }

  void _parseAndAdd(_InstantiatedFilter filter, dynamic payload) {
    final parsed = filter.filter.parseChanges(payload);
    filter._controller.add(parsed);
  }

  Future uninstall(_InstantiatedFilter filter) async {
    await filter._controller.close();
    _filters.remove(filter);

    if (filter.isPubSub && !_clearingBecauseSocketClosed) {
      final connection = _provider.connectWithPeer(this);
      await connection?.sendRequest('eth_unsubscribe', [filter.id]);
    } else {
      await _provider.request('eth_uninstallFilter', [filter.id]);
    }
  }

  Future dispose() async {
    _ticker?.cancel();
    final remainingFilters = List.of(_filters);

    await Future.forEach(remainingFilters, uninstall);
    await Future.wait(_pendingUnsubcriptions);

    _pendingUnsubcriptions.clear();
  }
}

const _pingDuration = Duration(seconds: 2);

class _InstantiatedFilter<T> {
  _InstantiatedFilter(this.filter, this.isPubSub, Function() onCancel)
      : _controller = StreamController(onCancel: onCancel);

  /// The id of this filter. This value will be obtained from the API after the
  /// filter has been set up and is `null` before that.
  String? id;
  final Filter<T> filter;

  /// Whether the filter is listening on a websocket connection.
  final bool isPubSub;

  final StreamController<T> _controller;
}
