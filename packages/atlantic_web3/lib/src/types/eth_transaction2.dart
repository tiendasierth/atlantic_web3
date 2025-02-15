import 'dart:typed_data';

import 'package:atlantic_web3/atlantic_web3.dart';

class EthTransaction2 {
  /// The address of the sender of this transaction.
  ///
  /// This can be set to null, in which case the client will use the address
  /// belonging to the credentials used to this transaction.
  final EthAccount? from;

  /// The recipient of this transaction, or null for transactions that create a
  /// contract.
  final EthAccount? to;

  /// How much ether to send to [to]. This can be null, as some transactions
  /// that call a contracts method won't have to send ether.
  final EthAmount? value;

  /// The maximum amount of gas to spend.
  ///
  /// If [gas] is `null`, this library will ask the rpc node to estimate a
  /// reasonable spending via [Web3Client.estimateGas2].
  ///
  /// Gas that is not used but included in [gas] will be returned.
  final int? gas;

  /// How much ether to spend on a single unit of gas. Can be null, in which
  /// case the rpc server will choose this value.
  final EthAmount? gasPrice;

  /// For transactions that call a contract function or create a contract,
  /// contains the hashed function name and the encoded parameters or the
  /// compiled contract code, respectively.
  final Uint8List? data;

  /// The nonce of this transaction. A nonce is incremented per sender and
  /// transaction to make sure the same transaction can't be sent more than
  /// once.
  ///
  /// If null, it will be determined by checking how many transactions
  /// have already been sent by [from].
  final int? nonce;

  final EthAmount? maxPriorityFeePerGas;
  final EthAmount? maxFeePerGas;

  EthTransaction2({
    this.from,
    this.to,
    this.gas,
    this.gasPrice,
    this.value,
    this.data,
    this.nonce,
    this.maxFeePerGas,
    this.maxPriorityFeePerGas,
  });

  /// Constructs a transaction that can be used to call a contract function.
  EthTransaction2.callContract({
    required DeployedContract contract,
    required ContractFunction function,
    required List<dynamic> parameters,
    this.from,
    this.gas,
    this.gasPrice,
    this.value,
    this.nonce,
    this.maxFeePerGas,
    this.maxPriorityFeePerGas,
  })  : to = contract.address,
        data = function.encodeCall(parameters);

  EthTransaction2 copyWith({
    EthAccount? from,
    EthAccount? to,
    int? maxGas,
    EthAmount? gasPrice,
    EthAmount? value,
    Uint8List? data,
    int? nonce,
    EthAmount? maxPriorityFeePerGas,
    EthAmount? maxFeePerGas,
  }) {
    return EthTransaction2(
      from: from ?? this.from,
      to: to ?? this.to,
      gas: maxGas ?? gas,
      gasPrice: gasPrice ?? this.gasPrice,
      value: value ?? this.value,
      data: data ?? this.data,
      nonce: nonce ?? this.nonce,
      maxFeePerGas: maxFeePerGas ?? this.maxFeePerGas,
      maxPriorityFeePerGas: maxPriorityFeePerGas ?? this.maxPriorityFeePerGas,
    );
  }

  bool get isEIP1559 => maxFeePerGas != null && maxPriorityFeePerGas != null;
}
