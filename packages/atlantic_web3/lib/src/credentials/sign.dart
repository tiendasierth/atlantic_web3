import 'dart:typed_data';

import 'package:atlantic_web3/atlantic_web3.dart' as rlp;
import 'package:atlantic_web3/atlantic_web3.dart';

abstract class Sing {
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

  Future<EthAmount> getGasPrice();

  BaseProvider getDefaultProvider();

  Future<int> getTransactionCount(EthAccount address, {EthBlockNum? atBlock});

  /// Signs the [transaction] with the credentials [cred]. The transaction will
  /// not be sent.
  ///
  /// See also:
  ///  - [bytesToHex], which can be used to get the more common hexadecimal
  /// representation of the transaction.
  Future<Uint8List> signTransaction(
    Passkey cred,
    EthTransaction2 transaction, {
    int? chainId = 1,
    bool fetchChainIdFromNetworkId = false,
  }) async {
    final signingInput = await _fillMissingData(
      credentials: cred as PasskeyWithKnownAccount,
      transaction: transaction,
      chainId: chainId,
      loadChainIdFromNetwork: fetchChainIdFromNetworkId,
      client: this,
    );

    return _signTransaction(
      signingInput.transaction,
      signingInput.credentials,
      signingInput.chainId,
    );
  }

  Future<_SigningInput> _fillMissingData({
    required PasskeyWithKnownAccount credentials,
    required EthTransaction2 transaction,
    int? chainId,
    bool loadChainIdFromNetwork = false,
    Sing? client,
  }) async {
    if (loadChainIdFromNetwork && chainId != null) {
      throw ArgumentError(
        "You can't specify loadChainIdFromNetwork and specify a custom chain id!",
      );
    }

    final sender = transaction.from ?? credentials.getEthAccount();
    var gasPrice = transaction.gasPrice;

    if (client == null &&
        (transaction.nonce == null ||
            transaction.gas == null ||
            loadChainIdFromNetwork ||
            (!transaction.isEIP1559 && gasPrice == null))) {
      throw ArgumentError('Client is required to perform network actions');
    }

    if (!transaction.isEIP1559 && gasPrice == null) {
      gasPrice = await client!.getGasPrice();
    }

    final nonce = transaction.nonce ??
        await client!
            .getTransactionCount(sender, atBlock: const EthBlockNum.pending());

    final maxGas = transaction.gas ??
        await client!
            .estimateGas2(
              from: sender,
              to: transaction.to,
              data: transaction.data,
              value: transaction.value,
              gasPrice: gasPrice,
              maxPriorityFeePerGas: transaction.maxPriorityFeePerGas,
              maxFeePerGas: transaction.maxFeePerGas,
            )
            .then((bigInt) => bigInt.toInt());

    // apply default values to null fields
    final modifiedTransaction = transaction.copyWith(
      value: transaction.value ?? EthAmount.zero(),
      maxGas: maxGas,
      from: sender,
      data: transaction.data ?? Uint8List(0),
      gasPrice: gasPrice,
      nonce: nonce,
    );

    int resolvedChainId;
    if (!loadChainIdFromNetwork) {
      resolvedChainId = chainId!;
    } else {
      final provider2 = client!.getDefaultProvider();
      resolvedChainId =
          await provider2.request<String>('net_version').then(int.parse);
    }

    return _SigningInput(
      transaction: modifiedTransaction,
      credentials: credentials,
      chainId: resolvedChainId,
    );
  }

  Uint8List _signTransaction(
    EthTransaction2 transaction,
    Passkey c,
    int? chainId,
  ) {
    if (transaction.isEIP1559 && chainId != null) {
      final encodedTx = LengthTrackingByteSink();
      encodedTx.addByte(0x02);
      encodedTx.add(
        rlp.encode(
            _encodeEIP1559ToRlp(transaction, null, BigInt.from(chainId))),
      );

      encodedTx.close();
      final signature = c.signToEcSignature(
        encodedTx.asBytes(),
        chainId: chainId,
        isEIP1559: transaction.isEIP1559,
      );

      return uint8ListFromList(
        rlp.encode(
          _encodeEIP1559ToRlp(transaction, signature, BigInt.from(chainId)),
        ),
      );
    }
    final innerSignature = chainId == null
        ? null
        : MsgSignature(BigInt.zero, BigInt.zero, chainId);

    final encoded = uint8ListFromList(
        rlp.encode(_encodeToRlp(transaction, innerSignature)));
    final signature = c.signToEcSignature(encoded, chainId: chainId);

    return uint8ListFromList(rlp.encode(_encodeToRlp(transaction, signature)));
  }

  List<dynamic> _encodeEIP1559ToRlp(
    EthTransaction2 transaction,
    MsgSignature? signature,
    BigInt chainId,
  ) {
    final list = [
      chainId,
      transaction.nonce,
      transaction.maxPriorityFeePerGas!.getInWei,
      transaction.maxFeePerGas!.getInWei,
      transaction.gas,
    ];

    if (transaction.to != null) {
      list.add(transaction.to!.addressBytes);
    } else {
      list.add('');
    }

    list
      ..add(transaction.value?.getInWei)
      ..add(transaction.data);

    list.add([]); // access list

    if (signature != null) {
      list
        ..add(signature.v)
        ..add(signature.r)
        ..add(signature.s);
    }

    return list;
  }

  List<dynamic> _encodeToRlp(
      EthTransaction2 transaction, MsgSignature? signature) {
    final list = [
      transaction.nonce,
      transaction.gasPrice?.getInWei,
      transaction.gas,
    ];

    if (transaction.to != null) {
      list.add(transaction.to!.addressBytes);
    } else {
      list.add('');
    }

    list
      ..add(transaction.value?.getInWei)
      ..add(transaction.data);

    if (signature != null) {
      list
        ..add(signature.v)
        ..add(signature.r)
        ..add(signature.s);
    }

    return list;
  }

  static Uint8List prependTransactionType(int type, Uint8List transaction) {
    return Uint8List(transaction.length + 1)
      ..[0] = type
      ..setAll(1, transaction);
  }
}

class _SigningInput {
  _SigningInput({
    required this.transaction,
    required this.credentials,
    this.chainId,
  });

  final EthTransaction2 transaction;
  final Passkey credentials;
  final int? chainId;
}
