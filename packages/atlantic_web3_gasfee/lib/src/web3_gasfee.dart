import 'package:atlantic_web3/atlantic_web3.dart';

final class Web3GasFee implements IWeb3GasFee {
  // Instancia privada
  static Web3GasFee? _instance;

  static IWeb3GasFee instance() {
    if (_instance == null) {
      //provider
      final provider = Web3Client.instance.defaultProvider;

      //singleton
      _instance = Web3GasFee._(provider);
    }
    return _instance!;
  }

  // Principal
  late final BaseProvider _provider;
  late final FilterEngine _filters;

  Web3GasFee._(BaseProvider provider) {
    // Principal
    _provider = provider;
    _filters = FilterEngine(_provider);
  }
}
