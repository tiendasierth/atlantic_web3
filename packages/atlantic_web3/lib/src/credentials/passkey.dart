import 'dart:convert';
import 'dart:typed_data';

import 'package:atlantic_web3/atlantic_web3.dart';

/// Anything that can sign payloads with a private key.
abstract class Passkey {
  static const _messagePrefix = '\u0019Ethereum Signed Message:\n';

  /// Whether these [Passkey] are safe to be copied to another isolate and
  /// can operate there.
  /// If this getter returns true, the client might chose to perform the
  /// expensive signing operations on another isolate.
  bool get isolateSafe => false;

  /// Signs the [payload] with a private key and returns the obtained
  /// signature.
  MsgSignature signToEcSignature(Uint8List payload, {
    int? chainId,
    bool isEIP1559 = false,
  });

  /// Signs the [payload] with a private key. The output will be like the
  /// bytes representation of the [eth_sign RPC method](https://github.com/ethereum/wiki/wiki/JSON-RPC#eth_sign),
  /// but without the "Ethereum signed message" prefix.
  /// The [payload] parameter contains the raw data, not a hash.
  Uint8List signToUint8List(
    Uint8List payload, {
    int? chainId,
    bool isEIP1559 = false,
  }) {
    final signature =
        signToEcSignature(payload, chainId: chainId, isEIP1559: isEIP1559);

    final r = padUint8ListTo32(unsignedIntToBytes(signature.r));
    final s = padUint8ListTo32(unsignedIntToBytes(signature.s));
    final v = unsignedIntToBytes(BigInt.from(signature.v));

    // https://github.com/ethereumjs/ethereumjs-util/blob/8ffe697fafb33cefc7b7ec01c11e3a7da787fe0e/src/signature.ts#L63
    return uint8ListFromList(r + s + v);
  }

  /// Signs an Ethereum specific signature. This method is equivalent to
  /// [signToUint8List], but with a special prefix so that this method can't be used to
  /// sign, for instance, transactions.
  Uint8List signPersonalMessageToUint8List(Uint8List payload, {int? chainId}) {
    final prefix = _messagePrefix + payload.length.toString();
    final prefixBytes = ascii.encode(prefix);

    // will be a Uint8List, see the documentation of Uint8List.+
    final concat = uint8ListFromList(prefixBytes + payload);

    return signToUint8List(concat, chainId: chainId);
  }
}

/// Credentials where the [address] is known synchronously.
abstract class PasskeyWithKnownAccount extends Passkey {
  EthAccount getEthAccount();

  EthPublicKey getEthPublicKey();

  EthPrivateKey getEthPrivateKey();

  String toHex();

  Uint8List toBytes();
}

/// Interface for [Passkey] that don't sign transactions locally, for
/// instance because the private key is not known to this library.
abstract class CustomTransactionSender extends Passkey {
  Future<String> sendTransaction(EthTransaction2 transaction);
}
