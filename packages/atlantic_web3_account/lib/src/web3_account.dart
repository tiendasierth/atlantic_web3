import 'dart:typed_data';

import 'package:atlantic_web3/atlantic_web3.dart';

final class Web3Account extends Sing implements IWeb3Account {
  static const EthBlockNum _defaultBlock = EthBlockNum.current();

  // Instancia privada
  static Web3Account? _instance;

  static IWeb3Account instance() {
    if (_instance == null) {
      //provider
      final provider = Web3Client.instance.defaultProvider;

      //singleton
      _instance = Web3Account._(provider);
    }
    return _instance!;
  }

  // Principal
  late final BaseProvider _provider;
  late final FilterEngine _filters;

  Web3Account._(BaseProvider provider) {
    // Principal
    _provider = provider;
    _filters = FilterEngine(_provider);
  }

  String _getBlockParam(EthBlockNum? block) {
    return (block ?? _defaultBlock).toBlockParam();
  }

  /// Gets the balance of the account with the specified address.
  ///
  /// This function allows specifying a custom block mined in the past to get
  /// historical data. By default, [BlockNum.current] will be used.
  @override
  Future<EthAmount> getBalance(EthAccount address,
      {EthBlockNum? atBlock}) async {
    final blockParam = _getBlockParam(atBlock);
    final data = await _provider.request<String>(
      'eth_getBalance',
      [address.hex, blockParam],
    );
    return EthAmount.fromBigInt(EthUnit.wei, hexToBigInt(data));
  }

  /// Signs the given transaction using the keys supplied in the [cred]
  /// object to upload it to the client so that it can be executed.
  ///
  /// Returns a hash of the transaction which, after the transaction has been
  /// included in a mined block, can be used to obtain detailed information
  /// about the transaction.
  @override
  Future<String> sendTransaction(
    Passkey cred,
    EthTransaction2 transaction, {
    int? chainId = 1,
    bool fetchChainIdFromNetworkId = false,
  }) async {
    if (cred is CustomTransactionSender) {
      return cred.sendTransaction(transaction);
    }
    var signed = await signTransaction(
      cred,
      transaction,
      chainId: chainId,
      fetchChainIdFromNetworkId: fetchChainIdFromNetworkId,
    );

    if (transaction.isEIP1559) {
      signed = Sing.prependTransactionType(0x02, signed);
    }

    return sendRawTransaction(signed);
  }

  /// Sends a raw, signed transaction.
  ///
  /// To obtain a transaction in a signed form, use [signTransaction].
  ///
  /// Returns a hash of the transaction which, after the transaction has been
  /// included in a mined block, can be used to obtain detailed information
  /// about the transaction.
  @override
  Future<String> sendRawTransaction(Uint8List signedTransaction) async {
    return _provider.request('eth_sendRawTransaction', [
      bytesToHex(signedTransaction, include0x: true, padToEvenLength: true)
    ]);
  }

  /// Estimate the amount of gas that would be necessary if the transaction was
  /// sent via [sendTransaction]. Note that the estimate may be significantly
  /// higher than the amount of gas actually used by the transaction.
  @override
  Future<BigInt> estimateGas(EthTransaction transaction) async {
    final amountHex = await _provider.request<String>(
      'eth_estimateGas',
      [
        {
          if (transaction.from != null) 'from': transaction.from!.hex,
          if (transaction.to != null) 'to': transaction.to!.hex,
          if (transaction.value != null)
            'value': '0x${transaction.value!.getInWei.toRadixString(16)}',
          if (transaction.gas != null)
            'gas': '0x${transaction.gas!.toRadixString(16)}',
          if (transaction.gasPrice != null)
            'gasPrice': '0x${transaction.gasPrice!.getInWei.toRadixString(16)}',
          if (transaction.input != null)
            'input':
                bytesToHex(transaction.input as List<int>, include0x: true),
        },
      ],
    );
    return hexToBigInt(amountHex);
  }

  @override
  @Deprecated('Deprecated estimateGas2() use estimateGas()')
  Future<BigInt> estimateGas2({
    EthAccount? from,
    EthAccount? to,
    EthAmount? value,
    BigInt? gas,
    EthAmount? gasPrice,
    EthAmount? maxPriorityFeePerGas,
    EthAmount? maxFeePerGas,
    Uint8List? data,
  }) async {
    final amountHex = await _provider.request<String>(
      'eth_estimateGas',
      [
        {
          if (from != null) 'from': from.hex,
          if (to != null) 'to': to.hex,
          if (value != null) 'value': '0x${value.getInWei.toRadixString(16)}',
          if (gas != null) 'gas': '0x${gas.toRadixString(16)}',
          if (gasPrice != null)
            'gasPrice': '0x${gasPrice.getInWei.toRadixString(16)}',
          if (maxPriorityFeePerGas != null)
            'maxPriorityFeePerGas':
                '0x${maxPriorityFeePerGas.getInWei.toRadixString(16)}',
          if (maxFeePerGas != null)
            'maxFeePerGas': '0x${maxFeePerGas.getInWei.toRadixString(16)}',
          if (data != null) 'data': bytesToHex(data, include0x: true),
        },
      ],
    );
    return hexToBigInt(amountHex);
  }

  /// Returns the amount of Ether typically needed to pay for one unit of gas.
  ///
  /// Although not strictly defined, this value will typically be a sensible
  /// amount to use.
  @override
  Future<EthAmount> getGasPrice() async {
    final data = await _provider.request<String>('eth_gasPrice');
    return EthAmount.fromBigInt(EthUnit.wei, hexToBigInt(data));
  }

  /// Gets the amount of transactions issued by the specified [address].
  ///
  /// This function allows specifying a custom block mined in the past to get
  /// historical data. By default, [BlockNum.current] will be used.
  @override
  Future<int> getTransactionCount(EthAccount address, {EthBlockNum? atBlock}) {
    final blockParam = _getBlockParam(atBlock);

    return _provider.request<String>(
      'eth_getTransactionCount',
      [address.hex, blockParam],
    ).then((hex) => hexToBigInt(hex).toInt());
  }

  @override
  BaseProvider getDefaultProvider() {
    return _provider;
  }
}
