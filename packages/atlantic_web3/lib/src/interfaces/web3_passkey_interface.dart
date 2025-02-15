import 'package:atlantic_web3/atlantic_web3.dart';

abstract interface class IWeb3Passkey {
  Boolean get isAuthenticate;

  IMnemonic generateMnemonic({int length, Language language});

  EthPassKey createEthPassKey(IMnemonic mnemonic, String passPhrase);
  IBIP32 createDerivateEthPassKey(IMnemonic mnemonic, String passPhrase);

  // manejar el acceso a los datos
  Future<Boolean> sing(String passPhrase);
  Future<Void> signOut();

  // se debe autenticar para escribir datos
  Future<EthPassKey> saveEthPasskey(
      String documentId, String name, EthPassKey passKey);
  Future<EthPassKey> setCurrentEthPasskey(String passKeyID);
  Future<Void> deleteAllEthPasskey();
  Future<Boolean> isEmpty();

  // se debe autenticar para obtener los datos
  Future<EthPassKey> getCurrentEthPassKey();
  Future<EthPassKey> getEthPasskey(String passKeyID);
  Future<List<EthPassKey>> getAllEthPasskey();
}
