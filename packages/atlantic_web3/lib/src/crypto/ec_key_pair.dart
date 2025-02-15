import 'dart:typed_data';

import 'package:atlantic_web3/atlantic_web3.dart';

class ECKeyPair implements IEquatable<ECKeyPair> {
  late Uint8List _seed;
  late BigInteger _privateKey;
  late BigInteger _publicKey;

  ECKeyPair.create(Uint8List privateKeyBytes) {
    _seed = privateKeyBytes;
    _privateKey = _privateKeyFromSeed(privateKeyBytes);
    _publicKey = _publicKeyFromSeed(privateKeyBytes);
  }

  ECKeyPair.fromKeyPairString(String privateKey, String publicKey) {
    _seed = hexToBytes(privateKey);
    _privateKey = bytesToUnsignedInt(hexToBytes(privateKey));
    _publicKey = bytesToUnsignedInt(hexToBytes(publicKey));
  }

  ECKeyPair.fromKeyPairInt(BigInteger privateKey, BigInteger publicKey) {
    _seed = intToBytes(privateKey);
    _privateKey = privateKey;
    _publicKey = publicKey;
  }

  BigInteger get publicKey => _publicKey;

  BigInteger get privateKey => _privateKey;

  Uint8List get bytes => _seed;

  String get hex => bytesToHex(_seed);

  @override
  Boolean equals(ECKeyPair param) {
    return publicKey == param.publicKey && privateKey == param.privateKey;
  }

  @override
  Boolean operator ==(Object other) => equals(other as ECKeyPair);

  @override
  int get hashCode => _seed.hashCode;

  @override
  String toString() {
    return 'ECKeyPair{'
        'privateKey: $_privateKey, '
        'publicKey: $_publicKey'
        '}';
  }

  BigInteger _publicKeyFromSeed(Uint8List bytes) {
    final BigInteger privateKeyInt = bytesToUnsignedInt(bytes);

    final Uint8List encoder = privateKeyToPublic(privateKeyInt);

    return bytesToUnsignedInt(encoder);
  }

  BigInteger _privateKeyFromSeed(Uint8List bytes) {
    return bytesToUnsignedInt(bytes);
  }
}
