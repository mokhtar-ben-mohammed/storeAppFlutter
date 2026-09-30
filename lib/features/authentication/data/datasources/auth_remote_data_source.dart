import 'package:store/core/network/api_client.dart';
import 'package:store/core/network/api_endpoints.dart';
import 'package:store/core/network/api_response_parser.dart';
import 'package:store/features/authentication/data/models/auth_session_model.dart';
import 'package:store/features/authentication/data/models/user_model.dart';

/// Contract for remote authentication API interactions.
abstract interface class AuthRemoteDataSource {
  Future<bool> sendOtp({required String countryCode, required String phone});
  Future<AuthSessionModel> verifyOtp({
    required String countryCode,
    required String phone,
    required String otp,
  });
  Future<void> logout();
  Future<UserModel> getProfile();
}

/// Concrete implementation of [AuthRemoteDataSource] using [ApiClient].
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<bool> sendOtp({required String countryCode, required String phone}) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.sendOtp,
      data: {
        'country_code': countryCode,
        'phone': phone,
      },
    );
    ApiResponseParser.requireSuccessData(response);
    return true;
  }

  @override
  Future<AuthSessionModel> verifyOtp({
    required String countryCode,
    required String phone,
    required String otp,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.verifyOtp,
      data: {
        'country_code': countryCode,
        'phone': phone,
        'otp': otp,
      },
    );
    final data = ApiResponseParser.requireDataMap(response);
    return AuthSessionModel.fromJson(data);
  }

  @override
  Future<void> logout() async {
    final response = await _apiClient.post<Map<String, dynamic>>(ApiEndpoints.logout);
    ApiResponseParser.requireSuccessData(response);
  }

  @override
  Future<UserModel> getProfile() async {
    final response = await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.profile);
    final data = ApiResponseParser.requireDataMap(response);
    return UserModel.fromJson(data);
  }
}
