import 'dart:typed_data';

import '../../atlantic_web3.dart';

abstract interface class IWeb3Blockchain {
  // IWeb3Contract contract(
  //     BaseProvider provider, ContractAbi abi, EthAddress address);

  Future<EthPassKey> credentialsFromPrivateKey(String privateKey);

  Future<BigInt> estimateGas(EthTransaction transaction);

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

  Future<List<dynamic>> getAccounts();

  Future<EthAmount> getBalance(EthAccount address, {EthBlockNum? atBlock});

  Future<EthBlock> getBlock({
    EthBlockNum atBlock = const EthBlockNum.current(),
    Boolean isContainFullObj = true,
  });

  Future<int> getBlockNumber();

  Future<int> getBlockTransactionCount(
      {EthBlockNum atBlock = const EthBlockNum.current()});

  Future<int> getBlockUncleCount(
      {EthBlockNum atBlock = const EthBlockNum.current()});

  Future<BigInt> getChainId();

  Future<String> getClientVersion();

  Future<EthAccount> getCoinbase();

  Future<EthAmount> getGasPrice();

  Future<int> getHashRate();

  Future<int> getProtocolVersion();

  Future<EthSyncInformation?> getSyncStatus();

  Future<EthTransaction?> getTransaction(String txHash);

  Future<int> getTransactionCount(EthAccount address, {EthBlockNum? atBlock});

  Future<EthTransaction?> getTransactionFromBlock(
      EthBlockNum? atBlock, int index);

  Future<TransactionReceipt?> getTransactionReceipt(String txHash);

  dynamic getUncleFromBlock(EthBlockNum? atBlock, int index);

  Future<List<dynamic>> getWork();

  Future<bool> isMining();

  Future<bool> isSyncing();

  /*
   Metodos para eventos
   */

  Stream<FilterEvent> events(FilterOptions options);

  Stream<FilterEvent> eventsLogs();

  Stream<String> eventsNewHeads();

  Stream<String> eventsNewPendingTransactions();

  Future<void> cleanEvent();

  Stream<String> getPendingTransactions();

  Future<String> sendTransaction(
    Passkey cred,
    EthTransaction2 transaction, {
    int? chainId = 1,
    bool fetchChainIdFromNetworkId = false,
  });

  Future<Uint8List> signTransaction(
    Passkey cred,
    EthTransaction2 transaction, {
    int? chainId = 1,
    bool fetchChainIdFromNetworkId = false,
  });

  Future<String> sendRawTransaction(Uint8List signedTransaction);

  BaseProvider getDefaultProvider();
}
