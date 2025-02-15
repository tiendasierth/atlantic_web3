import 'dart:convert';
import 'dart:io';

import 'package:atlantic_web3/atlantic_web3.dart';
import 'package:atlantic_web3_passkey/atlantic_web3_passkey.dart';
import 'package:atlantic_web3_passkey/src/bip39/models/wallet.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/example_keystores.dart' as data;

void main() {
  late IWeb3Passkey web3;
  late File tempDir;
  late Map wallets;

  setUp(() {
    web3 = Web3Passkey.instance();
    tempDir = File('');
    wallets = json.decode(data.content) as Map;
  });

  wallets.forEach((dynamic testName, dynamic content) {
    test(
      'unlocks wallet $testName',
      () {
        final password = content['password'] as String;
        final privateKey = content['priv'] as String;
        final walletData = content['json'] as Map;

        final wallet = Wallet.fromJson(json.encode(walletData), password);
        expect(wallet.passkey.toHex(), privateKey);

        final encodedWallet = json.decode(wallet.toJson()) as Map;

        expect(
          encodedWallet['crypto']['ciphertext'],
          walletData['crypto']['ciphertext'],
        );
      },
      tags: 'expensive',
    );
  });
}
