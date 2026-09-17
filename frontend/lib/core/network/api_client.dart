import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../errors/app_exception.dart';
import '../storage/secure_storage_service.dart';

class ApiClient {
  final http.Client _client;
  final SecureStorageService _storageService;
  String? _authToken;

  ApiClient({http.Client? client, SecureStorageService? storageService})
      : _client = client ?? http.Client(),
        _storageService = storageService ?? SecureStorageService();

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  Future<Map<String, String>> _buildHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    // Check in-memory token first, fallback to secure storage
    final token = _authToken ?? await _storageService.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final uri = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
      final headers = await _buildHeaders();
      final response = await _client.get(uri, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Connection failed: Unable to reach backend server ($e)');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
      final headers = await _buildHeaders();
      final response = await _client.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Connection failed: Unable to reach backend server ($e)');
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
      final headers = await _buildHeaders();
      final response = await _client.put(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Connection failed: Unable to reach backend server ($e)');
    }
  }

  Future<dynamic> patch(String endpoint, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
      final headers = await _buildHeaders();
      final response = await _client.patch(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Connection failed: Unable to reach backend server ($e)');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final uri = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
      final headers = await _buildHeaders();
      final response = await _client.delete(uri, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Connection failed: Unable to reach backend server ($e)');
    }
  }

  dynamic _handleResponse(http.Response response) {
    dynamic responseBody;
    if (response.body.isNotEmpty) {
      try {
        responseBody = jsonDecode(response.body);
      } catch (_) {
        responseBody = response.body;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    } else {
      String message = 'Request failed with status: ${response.statusCode}';
      Map<String, String>? validationErrors;

      if (responseBody is Map<String, dynamic>) {
        if (responseBody.containsKey('message') && responseBody['message'] != null) {
          message = responseBody['message'].toString();
        }
        if (responseBody.containsKey('validationErrors') &&
            responseBody['validationErrors'] is Map) {
          validationErrors = (responseBody['validationErrors'] as Map).map(
            (k, v) => MapEntry(k.toString(), v.toString()),
          );
        }
      }

      throw AppException(
        message: message,
        statusCode: response.statusCode,
        validationErrors: validationErrors,
      );
    }
  }
}
