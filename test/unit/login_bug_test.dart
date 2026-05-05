import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:eduphin/services/api_service.dart';

// Mock HttpOverrides to intercept network calls without a mocking library
class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return MockHttpClient();
  }
}

class MockHttpClient extends Fake implements HttpClient {
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async => MockHttpClientRequest();
  
  @override
  Future<HttpClientRequest> postUrl(Uri url) async => MockHttpClientRequest();
  
  @override
  set autoUncompress(bool _autoUncompress) {}

  @override
  void close({bool force = false}) {}
}

class MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  HttpHeaders get headers => MockHttpHeaders();
  
  @override
  set contentLength(int length) {}
  
  @override
  set encoding(Encoding encoding) {}

  @override
  set followRedirects(bool _followRedirects) {}

  @override
  set maxRedirects(int _maxRedirects) {}

  @override
  set persistentConnection(bool _persistentConnection) {}

  @override
  void add(List<int> data) {}

  @override
  Future addStream(Stream<List<int>> stream) async => stream.listen((_) {}).asFuture();

  @override
  Future<HttpClientResponse> close() async => MockHttpClientResponse();
}

class MockHttpHeaders extends Fake implements HttpHeaders {
  final Map<String, List<String>> _headers = {};

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    _headers[name] = [value.toString()];
  }
  
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {
    _headers.putIfAbsent(name, () => []).add(value.toString());
  }

  @override
  void removeAll(String name) {
    _headers.remove(name);
  }

  @override
  void forEach(void Function(String name, List<String> values) f) {
    _headers.forEach(f);
  }
}

class MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    final response = jsonEncode({
      'success': true,
      'token': 'mock_token',
      'user': {'name': 'Test User'} 
    });
    return Stream.value(utf8.encode(response)).listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  HttpHeaders get headers => MockHttpHeaders();

  @override
  int get contentLength => -1;

  @override
  HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;

  @override
  bool get isRedirect => false;

  @override
  bool get persistentConnection => true;

  @override
  String get reasonPhrase => 'OK';

  @override
  List<RedirectInfo> get redirects => [];

  @override
  List<Cookie> get cookies => [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MockHttpOverrides();

  group('Login Bug Validation', () {
    test('ApiService.login should throw a specific error when role_id is missing', () async {
      try {
        await ApiService.login('test@example.com', 'password');
        fail('Should have thrown an exception because role_id is missing in mock response');
      } catch (e) {
        // Validation of the bug: Catching the reported generic exception.
        expect(e.toString(), contains('Missing token or invalid role'));
      }
    });
  });
}
