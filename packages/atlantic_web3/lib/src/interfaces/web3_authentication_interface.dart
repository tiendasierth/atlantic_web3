import 'dart:typed_data';

import 'package:atlantic_web3/atlantic_web3.dart';

abstract interface class IWeb3Account {
  Future<EthAmount> getBalance(EthAccount address, {EthBlockNum? atBlock});

  Future<String> sendTransaction(
    Passkey cred,
    EthTransaction2 transaction, {
    int? chainId = 1,
    bool fetchChainIdFromNetworkId = false,
  });

  Future<String> sendRawTransaction(Uint8List signedTransaction);

  Future<EthAmount> getGasPrice();

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
  });

  Future<int> getTransactionCount(EthAccount address, {EthBlockNum? atBlock});

  BaseProvider getDefaultProvider();
}
