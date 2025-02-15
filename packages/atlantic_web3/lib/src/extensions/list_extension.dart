import 'package:atlantic_web3/atlantic_web3.dart';

extension ListExtension on List {
  Boolean equals<T>(List<T> param) {
    final List<T> left = this as List<T>;
    final List<T> right = param;

    if (identical(left, right)) {
      return true;
    }

    if (left.length != right.length) {
      return false;
    }

    for (int i = 0; i < left.length; i++) {
      if (left[i] != right[i]) {
        return false;
      }
    }

    return true;
  }
}
