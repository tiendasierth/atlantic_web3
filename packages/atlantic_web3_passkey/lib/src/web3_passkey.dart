
import 'dart:convert';
import 'dart:core';
import 'dart:typed_data';

import 'package:atlantic_web3/atlantic_web3.dart';
import 'package:atlantic_web3_passkey/atlantic_web3_passkey.dart';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/export.dart';

import 'bip39/keystore.dart';


class Web3Passkey implements IWeb3Passkey {
  // Instancia privada
  static Web3Passkey? _instance = null;

  static IWeb3Passkey instance() {
    if (_instance == null) {
      _instance = Web3Passkey._();
    }
    return _instance!;
  }
  late final EthBip39Generator _bip39;
  late final EthPassKeyStore _keyStore;
  String? _inMemoryPassPhrase;

  Web3Passkey._() {
    _bip39 = EthBip39Generator();
    _keyStore = EthPassKeyStore();
  }

  @override
  Boolean get isAuthenticate => _inMemoryPassPhrase != null;

  /// Permite generar frases mnemonic dependiendo el lenguaje y longitud, tambien
  /// debe tomar en cuenta el id del dispositivo para usarlo como una entropy inicial
  /// para que sea de manera unica y aleatoria. La longitud de la frases se de determina
  /// por la siguiente tabla:
  ///
  /// ---------------------------------
  /// | words length | entropy length |
  /// ---------------------------------
  /// | 12           | 128            |
  /// | 15           | 160            |
  /// | 18           | 192            |
  /// | 21           | 224            |
  /// | 24           | 256            |
  /// ---------------------------------
  /// mas informacion <a href="https://github.com/leonardocustodio/polkadart/blob/main/packages/substrate_bip39/lib/crypto_scheme.dart">aqui</a>
  ///
  @override
  Mnemonic generateMnemonic({int length = 12, Language language = Language.english}) {
    if ([12,15,18,21,24].contains(length) == false) {
      throw ArgumentError('The words length must be 12, 15, 18, 21 or 24', length as String?);
    }

    final List<String> words = _bip39.generateWordsRandomly(length, language);

    return Mnemonic.from(words);
  }

  @override
  EthPassKey createEthPassKey(IMnemonic mnemonic, String passPhrase) {

    // Semilla
    final Uint8List seed = Pbkdf2.createSeedFromMnemonicAndPassword(mnemonic, passPhrase);

    // BIP39: A checksum is generated by taking the first bits of its SHA256 hash.
    final sha256 = SHA256Digest();
    final key = sha256.process(seed);

    // Encapsular claves publica y privada
    final ECKeyPair keyPair = ECKeyPair.create(key);

    // Crear llave de accesos usando las claves
    return EthPassKey.fromKeyPair(keyPair);
  }

  @override
  EthBip32PassKey createDerivateEthPassKey(IMnemonic mnemonic, String passPhrase) {

    // Semilla
    final Uint8List seed = Pbkdf2.createSeedFromMnemonicAndPassword(mnemonic, passPhrase);

    // BIP39: A checksum is generated by taking the first bits of its SHA256 hash.
    final sha256 = SHA256Digest();
    final key = sha256.process(seed);

    // Encapsular claves publica y privada
    final ECKeyPair keyPair = ECKeyPair.create(key);

    // Crear derivador de llaves de accesos usando las claves
    return EthBip32PassKey.fromKeyPair(keyPair);
  }


  @override
  Future<Boolean> sing(String passPhrase) async {
    try {
      _inMemoryPassPhrase = passPhrase;
      //TODO: Falta la verificacion para evitar asignar una frase incorrecta
      return true;
    } catch(e) {
      _inMemoryPassPhrase = null;
      return false;
    }
  }

  @override
  Future<Void> signOut() async {
    _inMemoryPassPhrase = null;
  }

  @override
  Future<EthPassKey> saveEthPasskey(String documentId, String name, EthPassKey passKey) async {

    // se debe autenticar para escribir datos
    if (isAuthenticate == false) {
      throw Error();
    }

    final sha256 = SHA256Digest();
    final key = sha256.process(utf8.encode(_inMemoryPassPhrase!));

    final Encrypter algorithm = Encrypter(AES(Key(key)));

    final DeviceResult device = await DeviceHelper.getDevice();
    final IV iv = IV.fromUtf8(device.code.substring(0, 16));

    final Encrypted encName = algorithm.encrypt(name, iv: iv);
    final Encrypted encPrivateKey = algorithm.encrypt(passKey.keyPair.privateKey.toString(), iv: iv);
    final Encrypted encPublicKey = algorithm.encrypt(passKey.keyPair.publicKey.toString(), iv: iv);

    final model = EthPassKeyModel(
        documentId,
        true,
        DateTime.now(),
        DateTime.now(),
        encName.base64,
        encPrivateKey.base64,
        encPublicKey.base64,
        false,
        null);

    final EthPassKeyModel result = await _keyStore.create(model);

    final decName = algorithm.decrypt(Encrypted.fromBase64(result.name), iv: iv);
    final decPrivateKey = algorithm.decrypt(Encrypted.fromBase64(result.privateKey), iv: iv);
    final decPublicKey = algorithm.decrypt(Encrypted.fromBase64(result.publicKey), iv: iv);

    // Encapsular claves publica y privada
    final ECKeyPair keyPair = ECKeyPair.fromKeyPairInt(BigInt.parse(decPrivateKey), BigInt.parse(decPublicKey));

    // Crear derivador de llaves de accesos usando las claves
    return EthPassKey.fromKeyPairExtender(keyPair, documentId, decName, null);
  }

  @override
  Future<EthPassKey> setCurrentEthPasskey(String passkeyID) async {

    // se debe autenticar para escribir datos
    if (isAuthenticate == false) {
      throw Error();
    }

    final Integer exist = await _keyStore.exist(passkeyID);

    if (exist == 0) {
      throw Exception('No exist passkey');
    } else {

      // //set passphrase in memory
      // _inMemoryPassPhrase = passPhrase;

      final List<EthPassKeyModel> list = await _keyStore.find();

      for (final element in list) {
        if (element.passkeyID == passkeyID) {
          element.isDefault = true;
        } else {
          element.isDefault = false;
        }
        await _keyStore.update(element);
      }

    }

    // Reusar
    return getCurrentEthPassKey();
  }

  @override
  Future<Void> deleteAllEthPasskey() async {

    // se debe autenticar para obtener los datos
    // if (isAuthenticate == false) {
    //   throw Error();
    // }

    return _keyStore.deleteAll();
  }

  @override
  Future<Boolean> isEmpty() async {

    // se debe autenticar para obtener los datos
    // if (isAuthenticate == false) {
    //   throw Error();
    // }

    final List<EthPassKeyModel> result =
        await _keyStore.find();

    return result.isEmpty;
  }

  @override
  Future<EthPassKey> getCurrentEthPassKey() async {

    // se debe autenticar para obtener los datos
    if (isAuthenticate == false) {
      throw Error();
    }

    final sha256 = SHA256Digest();
    final key = sha256.process(utf8.encode(_inMemoryPassPhrase!));

    final Encrypter algorithm = Encrypter(AES(Key(key)));

    final DeviceResult device = await DeviceHelper.getDevice();
    final IV iv = IV.fromUtf8(device.code.substring(0, 16));

    final EthPassKeyModel result = await _keyStore.findDefault();

    final decName = algorithm.decrypt(Encrypted.fromBase64(result.name), iv: iv);
    final decPrivateKey = algorithm.decrypt(Encrypted.fromBase64(result.privateKey), iv: iv);
    final decPublicKey = algorithm.decrypt(Encrypted.fromBase64(result.publicKey), iv: iv);

    // Encapsular claves publica y privada
    final ECKeyPair keyPair = ECKeyPair.fromKeyPairInt(BigInt.parse(decPrivateKey), BigInt.parse(decPublicKey));

    // Crear derivador de llaves de accesos usando las claves
    return EthPassKey.fromKeyPairExtender(keyPair, result.passkeyID, decName, null);
  }

  @override
  Future<EthPassKey> getEthPasskey(String passkeyID) async {

    // se debe autenticar para obtener los datos
    if (isAuthenticate == false) {
      throw Error();
    }

    final sha256 = SHA256Digest();
    final key = sha256.process(utf8.encode(_inMemoryPassPhrase!));

    final Encrypter algorithm = Encrypter(AES(Key(key)));

    final DeviceResult device = await DeviceHelper.getDevice();
    final IV iv = IV.fromUtf8(device.code.substring(0, 16));

    final EthPassKeyModel result = await _keyStore.findOne(passkeyID);

    final decName = algorithm.decrypt(Encrypted.fromBase64(result.name), iv: iv);
    final decPrivateKey = algorithm.decrypt(Encrypted.fromBase64(result.privateKey), iv: iv);
    final decPublicKey = algorithm.decrypt(Encrypted.fromBase64(result.publicKey), iv: iv);

    // Encapsular claves publica y privada
    final ECKeyPair keyPair = ECKeyPair.fromKeyPairInt(BigInt.parse(decPrivateKey), BigInt.parse(decPublicKey));

    // Crear derivador de llaves de accesos usando las claves
    return EthPassKey.fromKeyPairExtender(keyPair, result.passkeyID, decName, null);
  }

  @override
  Future<List<EthPassKey>> getAllEthPasskey() async {

    // se debe autenticar para obtener los datos
    if (isAuthenticate == false) {
      throw Error();
    }

    final sha256 = SHA256Digest();
    final key = sha256.process(utf8.encode(_inMemoryPassPhrase!));

    final Encrypter algorithm = Encrypter(AES(Key(key)));

    final DeviceResult device = await DeviceHelper.getDevice();
    final IV iv = IV.fromUtf8(device.code.substring(0, 16));

    final List<EthPassKeyModel> result = await _keyStore.find();

    final List<EthPassKey> list = result.map((element) {

      final decName = algorithm.decrypt(Encrypted.fromBase64(element.name), iv: iv);
      final decPrivateKey = algorithm.decrypt(Encrypted.fromBase64(element.privateKey), iv: iv);
      final decPublicKey = algorithm.decrypt(Encrypted.fromBase64(element.publicKey), iv: iv);

      // Encapsular claves publica y privada
      final ECKeyPair keyPair = ECKeyPair.fromKeyPairInt(BigInt.parse(decPrivateKey), BigInt.parse(decPublicKey));

      // Crear derivador de llaves de accesos usando las claves
      return EthPassKey.fromKeyPairExtender(keyPair, element.passkeyID, decName, null);
    }).toList();

    return list;
  }
}
