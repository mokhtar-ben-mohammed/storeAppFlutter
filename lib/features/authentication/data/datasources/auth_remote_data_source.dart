import 'package:store/core/network/api_client.dart';
import 'package:store/core/network/api_endpoints.dart';
import 'package:store/features/authentication/data/models/auth_session_model.dart';
import 'package:store/features/authentication/data/models/user_model.dart';

/// Contract for remote authentication API interactions.
abstract interface class AuthRemoteDataSource {
  Future<bool> sendOtp(String phone);
  Future<AuthSessionModel> verifyOtp({required String phone, required String otp});
  Future<void> logout();
  Future<UserModel> getProfile();
}

/// Concrete implementation of [AuthRemoteDataSource] using [ApiClient].
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<bool> sendOtp(String phone) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.sendOtp,
      data: {'phone': phone},
    );
    final data = response.data;
    if (data != null && data['success'] != null) {
      return data['success'] as bool;
    }
    return response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300;
  }

  @override
  Future<AuthSessionModel> verifyOtp({required String phone, required String otp}) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.verifyOtp,
      data: {'phone': phone, 'otp': otp},
    );
    final data = response.data;
    if (data == null) {
      throw Exception('Empty response from verify OTP service.');
    }
    return AuthSessionModel.fromJson(data);
  }

  @override
  Future<void> logout() async {
    await _apiClient.post<Map<String, dynamic>>(ApiEndpoints.logout);
  }

  @override
  Future<UserModel> getProfile() async {
    final response = await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.profile);
    final data = response.data;
    if (data == null) {
      throw Exception('Failed to load user profile.');
    }
    return UserModel.fromJson(data);
  }
}
