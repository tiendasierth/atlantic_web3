import 'dart:typed_data';

import 'package:atlantic_web3/atlantic_web3.dart';

final class EthPublicKey {
  final BigInt _publicKey;

  EthPublicKey(this._publicKey);

  Uint8List get bytes => intToBytes(_publicKey);

  String get hex => '0x${bytesToHex(bytes)}';

  BigInt get publicKey => _publicKey;
}
