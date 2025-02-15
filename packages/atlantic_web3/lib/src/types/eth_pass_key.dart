import 'dart:typed_data';

import 'package:atlantic_web3/atlantic_web3.dart';
import 'package:atlantic_web3/src/crypto/secp256k1.dart' as secp256k1;

/// Credenciales que pueden firmar cargas útiles con una clave privada de Ethereum.
final class EthPassKey extends PasskeyWithKnownAccount
    implements IEquatable<EthPassKey> {
  EthPassKey.fromInt(BigInt keyInt)
      : this.fromBytes(unsignedIntToBytes(keyInt));

  EthPassKey.fromHex(String hex) : this.fromBytes(hexToBytes(hex));

  EthPassKey.fromBytes(Uint8List bytes)
      : this.fromKeyPair(ECKeyPair.create(bytes));

  EthPassKey.fromKeyPair(this._keyPair);

  EthPassKey.fromKeyPairExtender(
      this._keyPair, this._documentID, this._name, this._photoURL);

  /// ECC's d private parameter.
  final ECKeyPair _keyPair;
  String? _documentID;
  String? _name;
  String? _photoURL;

  @override
  final bool isolateSafe = true;

  Boolean get isStorage => _documentID != null && _name != null;

  ECKeyPair get keyPair => _keyPair;

  String get documentID => _documentID!;

  String get displayName => _name!;

  String? get photoURL => _photoURL;

  @override
  EthAccount getEthAccount() {
    return EthAccount(
        publicKeyToAddress(privateKeyToPublic(_keyPair.privateKey)));
  }

  @override
  EthPublicKey getEthPublicKey() {
    return EthPublicKey(_keyPair.publicKey);
  }

  @override
  EthPrivateKey getEthPrivateKey() {
    return EthPrivateKey(_keyPair.privateKey);
  }

  @override
  String toHex() {
    return _keyPair.hex;
  }

  @override
  Uint8List toBytes() {
    return _keyPair.bytes;
  }

  @override
  MsgSignature signToEcSignature(
    Uint8List payload, {
    int? chainId,
    bool isEIP1559 = false,
  }) {
    final signature = secp256k1.sign(keccak256(payload), _keyPair.bytes);

    // https://github.com/ethereumjs/ethereumjs-util/blob/8ffe697fafb33cefc7b7ec01c11e3a7da787fe0e/src/signature.ts#L26
    // be aware that signature.v already is recovery + 27
    int chainIdV;
    if (isEIP1559) {
      chainIdV = signature.v - 27;
    } else {
      chainIdV = chainId != null
          ? (signature.v - 27 + (chainId * 2 + 35))
          : signature.v;
    }
    return MsgSignature(signature.r, signature.s, chainIdV);
  }

  @override
  Boolean equals(EthPassKey other) {
    return identical(this, other) ||
        runtimeType == other.runtimeType && _keyPair.equals(other.keyPair);
  }

  @override
  Boolean operator ==(Object other) => equals(other as EthPassKey);

  @override
  int get hashCode => _keyPair.bytes.hashCode;

  @override
  String toString() {
    return 'EthPassKey{'
        'keyPair: $_keyPair, '
        'documentID: $_documentID, '
        'name: $_name, '
        'photoURL: $_photoURL, '
        'isolateSafe: $isolateSafe}';
  }
}
