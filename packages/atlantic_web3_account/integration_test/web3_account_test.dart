import 'package:atlantic_web3/atlantic_web3.dart';
import 'package:atlantic_web3_account/atlantic_web3_account.dart';
import 'package:atlantic_web3_gasfee/atlantic_web3_gasfee.dart';
import 'package:atlantic_web3_passkey/atlantic_web3_passkey.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web3_providers_http/web3_providers_http.dart';

import 'helpers/sample_keys.dart';

void main() {
  late IWeb3Account web3;
  late IWeb3GasFee web3GasFee;
  late IWeb3Passkey web3PassKey;

  setUp(() async {
    //Run Web3
    await Web3Client.initialize(
      name: 'Mi cliente',
      provider: HttpProvider('http://localhost:7545'),
    );

    //Run
    web3 = Web3Account.instance();
    web3GasFee = Web3GasFee.instance();
    web3PassKey = Web3Passkey.instance();

    //Authenticate
    await web3PassKey.sing(PASSWORD);

    //Set Default PassKey
    if (true) {
      final keypair = ECKeyPair.create(hexToBytes(
          '0x6ebd8ad6d4dca011cc43971d4b732137214595f42e3905b68bdc6d9e2d8a3405'));

      final passKey = EthPassKey.fromKeyPair(keypair);

      const documentId = '3c5b0a43-e0c0-40ea-a698-fe88762382ff';

      final EthPassKey passkey2 =
          await web3PassKey.saveEthPasskey(documentId, 'Mi Wallet', passKey);
    }
  });

  test('getBalance', () async {
    //final result = await web3.signOut();

    //print(result);

    print('Test passed !!!');
  });

  test('signTransaction', () async {
    //final result = await web3.signOut();

    //print(result);

    print('Test passed !!!');
  });

  test('sendTransaction', () async {
    //final result = await web3.signOut();

    //print(result);

    print('Test passed !!!');
  });

  test('sendRawTransaction', () async {
    //final result = await web3.signOut();

    //print(result);

    print('Test passed !!!');
  });

  test('sendRawTransaction', () async {
    //final result = await web3.signOut();

    //print(result);

    print('Test passed !!!');
  });
}
