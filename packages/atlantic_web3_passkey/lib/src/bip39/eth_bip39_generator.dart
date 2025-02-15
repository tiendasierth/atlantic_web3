import 'dart:math';
import 'dart:typed_data';

import 'package:atlantic_web3/atlantic_web3.dart';
import 'package:atlantic_web3_passkey/src/bip39/words/word_list_en.dart';
import 'package:atlantic_web3_passkey/src/bip39/words/word_list_es.dart';
import 'package:crypto/crypto.dart';

final class EthBip39Generator implements IBIP39 {
  /// Formula
  /// ENT = 128
  /// CS = ENT / 32
  /// MS = (ENT + CS) / 11
  @override
  List<String> generateWordsRandomly(int length, Language language) {
    if (length % 3 != 0 && length >= 12 && length <= 32) {
      throw ArgumentError.value('The length must be 12, 15, 18, 21 or 24');
    }

    final int entropySize = length ~/ 3 * 32 ~/ 8; // In bit then in byte

    final random = Random.secure();
    var entropy = Uint8List(entropySize);

    for (var i = 0; i < entropySize; i++) {
      entropy[i] = random.nextInt(255);
    }

    List<String> binary = (entropy.toBinary() +
            _calculateBinaryChecksum(entropy) // add checksum at the end
        )
        .split(''); // Make it a list

    final wordIndexes = Uint8List(length);
    for (var i = 0; i < length; i++) {
      wordIndexes[i] =
          int.parse(binary.sublist(0 + i * 11, 11 + i * 11).join(''), radix: 2);
    }

    final wordList = switch (language) {
      Language.english => WordListEn.word,
      Language.spanish => WordListEs.word
    };

    final mnemonic = wordIndexes.map((index) => wordList[index]).toList();

    return mnemonic;
  }

  String _calculateBinaryChecksum(Uint8List data) {
    final checksum = data.length ~/ 4; // 32 / 8 = 4 bits
    final List<int> hash = sha512.convert(data).bytes;
    return hash.toBinary().substring(0, checksum);
  }
}
