abstract class BaseWeb3Error extends Error implements Exception {
  final String _msg;

  BaseWeb3Error(this._msg);

  Map<String, dynamic> toJSON() {
    return {};
  }
}

abstract class InvalidValueError extends BaseWeb3Error {
  InvalidValueError(super.msg);
}
