import 'dart:convert';
import 'dart:typed_data';

import 'package:atlantic_web3/atlantic_web3.dart';
import 'package:pointycastle/export.dart';
import "package:unorm_dart/unorm_dart.dart";

final class Pbkdf2 {
  static const Integer BLOCK_LENGTH = 128;
  static const Integer SEED_ITERATIONS = 2048;
  static const Integer SEED_KEY_SIZE_IN_BYTES = 64;

  /// BIP39: To create a binary seed from the mnemonic, we use the PBKDF2 function with a mnemonic sentence
  /// (in UTF-8 NFKD) used as the password and the string "mnemonic" + passphrase (again in UTF-8 NFKD) used as the salt.
  ///
  /// The iteration count is set to 2048 and HMAC-SHA512 is used as the pseudo-random function.
  ///
  /// The length of the derived key is 512 bits (= 64 bytes).
  static Uint8List createSeedFromMnemonicAndPassword(
      IMnemonic nnemonic, String passphrase) {
    final buffer = nnemonic.getStringBuffer();

    // Create slat
    final slat = "mnemonic$passphrase";

    // Codificar a UTF8
    final Uint8List utf8Key = utf8.encode(nfkd(buffer.toString().trim()));
    final Uint8List utf8Slat = utf8.encode(nfkd(slat));

    // Encriptar en HMAC-sha512
    final PBKDF2KeyDerivator derivator =
        PBKDF2KeyDerivator(HMac(SHA512Digest(), BLOCK_LENGTH));
    derivator.reset();
    derivator.init(
        Pbkdf2Parameters(utf8Slat, SEED_ITERATIONS, SEED_KEY_SIZE_IN_BYTES));

    final Uint8List key = derivator.process(utf8Key);

    return key;
  }
}
