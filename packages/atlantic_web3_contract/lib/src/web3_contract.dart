import 'dart:typed_data';

import 'package:atlantic_web3/atlantic_web3.dart';

final class Web3Contract extends Sing implements IWeb3Contract {
  static const EthBlockNum _defaultBlock = EthBlockNum.current();

  // Instancia privada
  static Web3Contract? _instance;

  static IWeb3Contract instance(ContractAbi abi, EthAccount address) {
    if (_instance == null) {
      //provider
      final provider = Web3Client.instance.defaultProvider;

      //singleton
      _instance = Web3Contract._(provider, abi, address);
    }
    return _instance!;
  }

  // Principal
  late final BaseProvider _provider;

  /// The lower-level ABI of this contract used to encode data to send in
  /// transactions when calling this contract.
  late final ContractAbi _abi;

  /// The Ethereum address at which this contract is reachable.
  late final EthAccount _address;

  late final FilterEngine _filters;

  Web3Contract._(BaseProvider provider, ContractAbi abi, EthAccount address) {
    // Principal
    _provider = provider;
    _abi = abi;
    _address = address;
    _filters = FilterEngine(_provider);
  }

  String _getBlockParam(EthBlockNum? block) {
    return (block ?? _defaultBlock).toBlockParam();
  }

  @override
  BaseProvider get provider => _provider;

  @override
  ContractAbi get abi => _abi;

  @override
  EthAccount get address => _address;

  /// Finds the event defined by the contract that has the matching [name].
  ///
  /// If no, or more than one event matches that name, this method will throw.
  @override
  ContractEvent event(String name) =>
      _abi.events.singleWhere((e) => e.name == name);

  /// Finds the external or public function defined by the contract that has the
  /// provided [name].
  ///
  /// If no, or more than one function matches that description, this method
  /// will throw.
  @override
  ContractFunction function(String name) =>
      _abi.functions.singleWhere((f) => f.name == name);

  /// Finds all external or public functions defined by the contract that have
  /// the given name. As solidity supports function overloading, this will
  /// return a list as only a combination of name and types will uniquely find
  /// a function.
  @override
  Iterable<ContractFunction> findFunctionsByName(String name) =>
      _abi.functions.where((f) => f.name == name);

  /// Calls a [function] defined in the smart [contract] and returns it's
  /// result.
  ///
  /// The connected node must be able to calculate the result locally, which
  /// means that the call can't write any data to the blockchain. Doing that
  /// would require a transaction which can be sent via [sendTransaction].
  /// As no data will be written, you can use the [sender] to specify any
  /// Ethereum address that would call that function. To use the address of a
  /// credential, call [Passkey.address].
  ///
  /// This function allows specifying a custom block mined in the past to get
  /// historical data. By default, [BlockNum.current] will be used.
  @override
  Future<List<dynamic>> call(
    String name,
    List<dynamic> params, {
    EthBlockNum? atBlock,
  }) async {
    final ContractFunction fn = function(name);

    final encodedResult = await callRaw(
      to: _address,
      data: fn.encodeCall(params),
      atBlock: atBlock,
    );

    return fn.decodeReturnValues(encodedResult);
  }

  /// Sends a raw method call to a smart contract.
  ///
  /// The connected node must be able to calculate the result locally, which
  /// means that the call can't write any data to the blockchain. Doing that
  /// would require a transaction which can be sent via [sendTransaction].
  /// As no data will be written, you can use the [from] to specify any
  /// Ethereum address that would call that function. To use the address of a
  /// credential, call [Passkey.address].
  ///
  /// This function allows specifying a custom block mined in the past to get
  /// historical data. By default, [BlockNum.current] will be used.
  ///
  /// See also:
  /// - [call], which automatically encodes function parameters and parses a
  /// response.
  @override
  Future<String> callRaw({
    EthAccount? from,
    required EthAccount to,
    required Uint8List data,
    EthBlockNum? atBlock,
  }) {
    return _provider.request<String>(
      'eth_call',
      [
        {
          if (from != null) 'from': from.hex,
          'to': to.hex,
          'data': bytesToHex(data, include0x: true, padToEvenLength: true),
        },
        _getBlockParam(atBlock),
      ],
    );
  }

  /// Gets the code of a contract at the specified [address]
  ///
  /// This function allows specifying a custom block mined in the past to get
  /// historical data. By default, [BlockNum.current] will be used.
  @override
  Future<Uint8List> getCode(EthAccount address, {EthBlockNum? atBlock}) async {
    final blockParam = _getBlockParam(atBlock);
    final hex = await _provider.request<String>(
      'eth_getCode',
      [address.hex, blockParam],
    );
    return hexToBytes(hex);
  }

  @override
  Future<BigInt> estimateGas2(
      {EthAccount? from,
      EthAccount? to,
      EthAmount? value,
      BigInt? gas,
      EthAmount? gasPrice,
      EthAmount? maxPriorityFeePerGas,
      EthAmount? maxFeePerGas,
      Uint8List? data}) {
    // TODO: implement estimateGas2
    throw UnimplementedError();
  }

  @override
  BaseProvider getDefaultProvider() {
    // TODO: implement getDefaultProvider
    throw UnimplementedError();
  }

  @override
  Future<EthAmount> getGasPrice() {
    // TODO: implement getGasPrice
    throw UnimplementedError();
  }

  @override
  Future<int> getTransactionCount(EthAccount address, {EthBlockNum? atBlock}) {
    // TODO: implement getTransactionCount
    throw UnimplementedError();
  }
}
