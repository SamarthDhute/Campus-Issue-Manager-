import 'package:smart_campus_issue_manager/core/constants/app_constants.dart';
import 'package:smart_campus_issue_manager/core/network/api_client.dart';
import 'package:smart_campus_issue_manager/core/storage/secure_storage_service.dart';
import 'package:smart_campus_issue_manager/features/auth/data/models/auth_user_model.dart';

class ProfileRepository {
  final ApiClient _apiClient;
  final SecureStorageService _storageService;

  ProfileRepository({
    ApiClient? apiClient,
    SecureStorageService? storageService,
  })  : _apiClient = apiClient ?? ApiClient(),
        _storageService = storageService ?? SecureStorageService();

  Future<AuthUserModel> fetchProfile() async {
    final response = await _apiClient.get(AppConstants.userProfileEndpoint);
    final user = AuthUserModel.fromJson(response as Map<String, dynamic>);
    await _storageService.saveUser(user);
    return user;
  }

  Future<AuthUserModel> updateProfile(String displayName) async {
    final response = await _apiClient.put(
      AppConstants.userProfileEndpoint,
      {'displayName': displayName.trim()},
    );
    final user = AuthUserModel.fromJson(response as Map<String, dynamic>);
    await _storageService.saveUser(user);
    return user;
  }
}
