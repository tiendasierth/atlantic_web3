import 'package:atlantic_web3/atlantic_web3.dart';

import 'cipher_params.dart';
import 'kdf_params.dart';

final class Crypto implements IEquatable<Object> {
  String cipher;
  String ciphertext;
  CipherParams cipherparams;

  String kdf;
  IKdfParams kdfparams;

  String mac;

  Crypto(this.cipher, this.ciphertext, this.cipherparams, this.kdf,
      this.kdfparams, this.mac);

  String getCipher() {
    return cipher;
  }

  String getCiphertext() {
    return ciphertext;
  }

  CipherParams getCipherparams() {
    return cipherparams;
  }

  String getKdf() {
    return kdf;
  }

  void setKdf(String kdf) {
    this.kdf = kdf;
  }

  IKdfParams getKdfparams() {
    return kdfparams;
  }

  // @JsonTypeInfo(
  //     use = JsonTypeInfo.Id.NAME,
  //     include = JsonTypeInfo.As.EXTERNAL_PROPERTY,
  //     property = "kdf")
  // @JsonSubTypes({
  // @JsonSubTypes.Type(value = Aes128CtrKdfParams.class, name = Wallet.AES_128_CTR),
  // @JsonSubTypes.Type(value = ScryptKdfParams.class, name = Wallet.SCRYPT)
  // })
  // To support my Ether Wallet keys uncomment this annotation & comment out the above
  //  @JsonDeserialize(using = KdfParamsDeserialiser.class)
  // Also add the following to the ObjectMapperFactory
  // objectMapper.configure(MapperFeature.ACCEPT_CASE_INSENSITIVE_PROPERTIES, true);
  // void setKdfparams(KdfParams kdfparams) {
  //   this.kdfparams = kdfparams;
  // }

  String getMac() {
    return mac;
  }

  void setMac(String mac) {
    this.mac = mac;
  }

  @override
  Boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (o is! Crypto) {
      return false;
    }

    Crypto that = o;

    if (getCipher() != null
        ? !getCipher().equals(that.getCipher())
        : that.getCipher() != null) {
      return false;
    }
    if (getCiphertext() != null
        ? !getCiphertext().equals(that.getCiphertext())
        : that.getCiphertext() != null) {
      return false;
    }
    if (getCipherparams() != null
        ? !getCipherparams().equals(that.getCipherparams())
        : that.getCipherparams() != null) {
      return false;
    }
    if (getKdf() != null
        ? !getKdf().equals(that.getKdf())
        : that.getKdf() != null) {
      return false;
    }
    if (getKdfparams() != null
        ? !getKdfparams().equals(that.getKdfparams())
        : that.getKdfparams() != null) {
      return false;
    }
    return getMac() != null
        ? getMac().equals(that.getMac())
        : that.getMac() == null;
  }

  @override
  int get hashCode {
    int result = getCipher() != null ? getCipher().hashCode : 0;
    result =
        31 * result + (getCiphertext() != null ? getCiphertext().hashCode : 0);
    result = 31 * result +
        (getCipherparams() != null ? getCipherparams().hashCode : 0);
    result = 31 * result + (getKdf() != null ? getKdf().hashCode : 0);
    result =
        31 * result + (getKdfparams() != null ? getKdfparams().hashCode : 0);
    result = 31 * result + (getMac() != null ? getMac().hashCode : 0);
    return result;
  }
}
