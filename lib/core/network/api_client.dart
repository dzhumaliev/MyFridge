import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final http.Client client;
  final String baseUrl;

  ApiClient({
    required this.client,
    this.baseUrl = 'https://api.myfridge.com/v1', // Фейковый API
  });

  // GET запрос
  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    
    print('🌐 GET Request: $url');
    
    try {
      final response = await client.get(
        url,
        headers: _getHeaders(),
      );
      
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');
      
      return response;
    } catch (e) {
      print('❌ Request Error: $e');
      rethrow;
    }
  }

  // POST запрос
  Future<http.Response> post(String endpoint, {required Map<String, dynamic> body}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    
    print('🌐 POST Request: $url');
    print('📤 Request Body: ${json.encode(body)}');
    
    try {
      final response = await client.post(
        url,
        headers: _getHeaders(),
        body: json.encode(body),
      );
      
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');
      
      return response;
    } catch (e) {
      print('❌ Request Error: $e');
      rethrow;
    }
  }

  // DELETE запрос
  Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    
    print('🌐 DELETE Request: $url');
    
    try {
      final response = await client.delete(
        url,
        headers: _getHeaders(),
      );
      
      print('📥 Response Status: ${response.statusCode}');
      
      return response;
    } catch (e) {
      print('❌ Request Error: $e');
      rethrow;
    }
  }

  // PUT запрос
  Future<http.Response> put(String endpoint, {required Map<String, dynamic> body}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    
    print('🌐 PUT Request: $url');
    print('📤 Request Body: ${json.encode(body)}');
    
    try {
      final response = await client.put(
        url,
        headers: _getHeaders(),
        body: json.encode(body),
      );
      
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');
      
      return response;
    } catch (e) {
      print('❌ Request Error: $e');
      rethrow;
    }
  }

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer fake-token-12345',
    };
  }
}