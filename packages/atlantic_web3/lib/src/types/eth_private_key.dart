import 'dart:typed_data';

import 'package:atlantic_web3/atlantic_web3.dart';

final class EthPrivateKey {
  final BigInt _privateKey;

  EthPrivateKey(this._privateKey);

  Uint8List get bytes => intToBytes(_privateKey);

  String get hex => bytesToHex(bytes);

  BigInt get privateKey => _privateKey;
}
