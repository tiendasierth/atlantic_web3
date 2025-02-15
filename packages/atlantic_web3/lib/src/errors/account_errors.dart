import '../../atlantic_web3.dart';

class PrivateKeyLengthError extends BaseWeb3Error {
  final int code = ERR_PRIVATE_KEY_LENGTH;

  PrivateKeyLengthError() : super('Private key must be 32 bytes.');
}

class InvalidPrivateKeyError extends BaseWeb3Error {
  final int code = ERR_INVALID_PRIVATE_KEY;

  InvalidPrivateKeyError()
      : super('Invalid Private Key, Not a valid string or buffer');
}

class InvalidSignatureError extends BaseWeb3Error {
  final int code = ERR_INVALID_SIGNATURE;

  InvalidSignatureError(super.errorDetails);
}

class InvalidKdfError extends BaseWeb3Error {
  final int code = ERR_UNSUPPORTED_KDF;

  InvalidKdfError() : super('Invalid key derivation function');
}

class KeyDerivationError extends BaseWeb3Error {
  final int code = ERR_KEY_DERIVATION_FAIL;

  KeyDerivationError()
      : super('Key derivation failed - possibly wrong password');
}

class KeyStoreVersionError extends BaseWeb3Error {
  final int code = ERR_KEY_VERSION_UNSUPPORTED;

  KeyStoreVersionError() : super('Unsupported key store version');
}

class InvalidPasswordError extends BaseWeb3Error {
  final int code = ERR_INVALID_PASSWORD;

  InvalidPasswordError() : super('Password cannot be empty');
}

class IVLengthError extends BaseWeb3Error {
  final int code = ERR_IV_LENGTH;

  IVLengthError() : super('Initialization vector must be 16 bytes');
}

class PBKDF2IterationsError extends BaseWeb3Error {
  final int code = ERR_PBKDF2_ITERATIONS;

  PBKDF2IterationsError()
      : super('c > 1000, pbkdf2 is less secure with less iterations');
}
