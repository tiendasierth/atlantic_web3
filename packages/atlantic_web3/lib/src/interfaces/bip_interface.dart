import 'package:atlantic_web3/atlantic_web3.dart';

abstract interface class IMnemonic {
  @override
  String toString();
  List<String> getWords();
  StringBuffer getStringBuffer();
}

abstract interface class IBIP39 {
  List<String> generateWordsRandomly(int length, Language language);
}

abstract interface class IBIP32 {
  String toHex();

  List<int> toBytes();

  EthPassKey toMainPassKey();
}

abstract interface class IBip39Wallet {}
