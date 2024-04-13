import 'package:http/http.dart' as http;

abstract class IHttpClient {
  Future<dynamic> get({required String url});
  Future<dynamic> put({required String url, required String body});
  Future<dynamic> post({required String url, required String body});
  Future<dynamic> delete({required String url});
}

class HttpClient implements IHttpClient {
  final http.Client client = http.Client();

  @override
  Future<dynamic> get({required String url}) async {
    return await client.get(Uri.parse(url));
  }

  @override
  Future<dynamic> put({required String url, required String body}) async {
    return await client.put(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );
  }

  @override
  Future<dynamic> post({required String url, required String body}) async {
    return await client.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );
  }

  @override
  Future<dynamic> delete({required String url}) async {
    return await client.delete(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
  }
}
