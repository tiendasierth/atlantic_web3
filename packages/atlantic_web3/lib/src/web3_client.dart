import 'package:atlantic_web3/atlantic_web3.dart';

class Web3Client implements IWeb3Client {
  // Principal
  late final String _name;
  late final String _version;
  BaseProvider? _provider;

  // Modules
  late final IWeb3Blockchain _eth;

  // Instancia privada
  static Web3Client? _instance;

  static IWeb3Client get instance {
    if (_instance == null) {
      throw AssertionError(
          'You must initialize the Web3Client instance before calling Web3Client.instance');
    }
    return _instance!;
  }

  static Future<IWeb3Client> initialize({
    required String name,
    required BaseProvider provider,
  }) async {
    if (_instance == null) {
      _instance = Web3Client._(name, provider);
    } else {
      throw AssertionError('This instance is already initialized');
    }
    return _instance!;
  }

  // ignore: sort_constructors_first
  Web3Client._(String name, BaseProvider provider) {
    // Principal
    _name = name;
    _version = 'v0.0.1';
    _provider = provider;
    // Modules
    //this._eth = Web3Eth(_provider!);
  }

  @override
  IWeb3Blockchain get eth => _eth;

  @override
  String get name => _name;

  @override
  String get version => _version;

  @override
  BaseProvider get defaultProvider => _provider!;
}
