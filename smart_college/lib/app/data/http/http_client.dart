import 'package:http/http.dart' as http;

abstract class IHttpClient {
  Future<http.Response> get({required String url, Map<String, String>? headers});
  Future<http.Response> put({required String url, Map<String, String>? headers, Object? body});
  Future<http.Response> post({required String url, Object? body, Map<String, String>? headers});
  Future<http.Response> delete({required String url, Map<String, String>? headers});
}

class HttpClient implements IHttpClient {
  final http.Client client = http.Client();

  @override
  Future<http.Response> get({required String url, Map<String, String>? headers}) async {
    return await client.get(Uri.parse(url), headers: headers);
  }

  @override
  Future<http.Response> put({required String url, Map<String, String>? headers, Object? body}) async {
    return await client.put(Uri.parse(url), headers: headers, body: body);
  }

  @override
  Future<http.Response> post({required String url, Object? body, Map<String, String>? headers}) async {
    return await client.post(Uri.parse(url), headers: headers, body: body);
  }

  @override
  Future<http.Response> delete({required String url, Map<String, String>? headers}) async {
    return await client.delete(Uri.parse(url), headers: headers);
  }
}
