import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/auth_response.dart';
import '../models/auth_user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final SecureStorageService _storageService;

  AuthRepository({
    ApiClient? apiClient,
    SecureStorageService? storageService,
  })  : _apiClient = apiClient ?? ApiClient(),
        _storageService = storageService ?? SecureStorageService();

  Future<AuthResponse> login(String email, String password) async {
    final response = await _apiClient.post(
      AppConstants.loginEndpoint,
      {
        'email': email,
        'password': password,
      },
    );

    final authResponse = AuthResponse.fromJson(response as Map<String, dynamic>);
    _apiClient.setAuthToken(authResponse.accessToken);
    await _storageService.saveToken(authResponse.accessToken);
    await _storageService.saveUser(authResponse.user);
    return authResponse;
  }

  Future<AuthUserModel?> getCurrentUser() async {
    return await _storageService.getUser();
  }

  Future<String?> getToken() async {
    return await _storageService.getToken();
  }

  Future<void> logout() async {
    _apiClient.clearAuthToken();
    await _storageService.clearAll();
  }
}
