import 'package:atlantic_web3/atlantic_web3.dart';

abstract interface class IKdfParams implements IEquatable<Object> {
  int getDklen();

  String getSalt();
}

final class Aes128CtrKdfParams implements IKdfParams {
  int dklen;
  int c;
  String prf;
  String salt;

  Aes128CtrKdfParams(this.dklen, this.c, this.prf, this.salt);

  @override
  int getDklen() {
    return dklen;
  }

  int getC() {
    return c;
  }

  String getPrf() {
    return prf;
  }

  @override
  String getSalt() {
    return salt;
  }

  @override
  Boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (o is! Aes128CtrKdfParams) {
      return false;
    }

    Aes128CtrKdfParams that = o;

    if (dklen != that.dklen) {
      return false;
    }
    if (c != that.c) {
      return false;
    }
    if (getPrf() != null
        ? !getPrf().equals(that.getPrf())
        : that.getPrf() != null) {
      return false;
    }
    return getSalt() != null
        ? getSalt().equals(that.getSalt())
        : that.getSalt() == null;
  }

  @override
  int get hashCode {
    int result = dklen;
    result = 31 * result + c;
    result = 31 * result + (getPrf() != null ? getPrf().hashCode : 0);
    result = 31 * result + (getSalt() != null ? getSalt().hashCode : 0);
    return result;
  }
}

final class ScryptKdfParams implements IKdfParams {
  int dklen;
  int n;
  int p;
  int r;
  String salt;

  ScryptKdfParams(this.dklen, this.n, this.p, this.r, this.salt);

  @override
  int getDklen() {
    return dklen;
  }

  int getN() {
    return n;
  }

  int getP() {
    return p;
  }

  int getR() {
    return r;
  }

  @override
  String getSalt() {
    return salt;
  }

  @override
  Boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (o is! ScryptKdfParams) {
      return false;
    }

    ScryptKdfParams that = o;

    if (dklen != that.dklen) {
      return false;
    }
    if (n != that.n) {
      return false;
    }
    if (p != that.p) {
      return false;
    }
    if (r != that.r) {
      return false;
    }
    return getSalt() != null
        ? getSalt().equals(that.getSalt())
        : that.getSalt() == null;
  }

  @override
  int get hashCode {
    int result = dklen;
    result = 31 * result + n;
    result = 31 * result + p;
    result = 31 * result + r;
    result = 31 * result + (getSalt() != null ? getSalt().hashCode : 0);
    return result;
  }
}
