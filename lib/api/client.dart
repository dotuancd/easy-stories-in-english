
import 'package:http/http.dart' as http;

class Client {
  final http.Client httpClient;

  final String baseUrl;

  Client(this.httpClient, this.baseUrl);

  Client.byDefault(String baseUrl) : this(http.Client(), _removeEndSlash(baseUrl));

  static String _removeEndSlash(String value) {
    return value.replaceFirst(new RegExp(r'(\/+$)'), '');
  }

  static String _removeStartSlash(String value) {
    return value.replaceFirst(RegExp(r'(^/+)'), '');
  }

  String _applyBaseUrl(String path) {
    return baseUrl + '/' + _removeStartSlash(path);
  }

}
