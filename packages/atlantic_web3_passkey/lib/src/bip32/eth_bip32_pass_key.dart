import 'package:atlantic_web3/atlantic_web3.dart';

class EthBip32PassKey implements IBIP32 {
  final ECKeyPair _keyPair;
  EthBip32PassKey.fromKeyPair(this._keyPair);

  @override
  String toHex() {
    return _keyPair.hex;
  }

  @override
  List<int> toBytes() {
    return _keyPair.bytes;
  }

  @override
  EthPassKey toMainPassKey() {
    return EthPassKey.fromHex(_keyPair.hex);
  }
}
