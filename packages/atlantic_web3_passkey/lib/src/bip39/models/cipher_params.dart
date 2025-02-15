import 'package:atlantic_web3/atlantic_web3.dart';

class CipherParams implements IEquatable<Object> {
  String iv;

  CipherParams(this.iv);

  String getIv() {
    return iv;
  }

  @override
  Boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (o is! CipherParams) {
      return false;
    }

    CipherParams that = o;

    return getIv() != null
        ? getIv().equals(that.getIv())
        : that.getIv() == null;
  }

  @override
  int get hashCode {
    int result = getIv() != null ? getIv().hashCode : 0;
    return result;
  }
}
