import 'package:store/core/network/api_client.dart';
import 'package:store/core/network/api_endpoints.dart';
import 'package:store/core/network/api_response_parser.dart';
import 'package:store/features/authentication/data/models/auth_session_model.dart';
import 'package:store/features/authentication/data/models/user_model.dart';
import 'package:store/features/authentication/domain/entities/registration_draft.dart';

/// Contract for remote authentication API interactions.
abstract interface class AuthRemoteDataSource {
  Future<bool> sendOtp({
    required String countryCode,
    required String phone,
    required String intent,
  });

  Future<AuthSessionModel> verifyOtp({
    required String countryCode,
    required String phone,
    required String otp,
    RegistrationDraft? registration,
  });

  Future<void> logout();
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile({
    String? name,
    int? cityId,
    int? currencyId,
    String? gender,
  });
  Future<void> deleteAccount();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<bool> sendOtp({
    required String countryCode,
    required String phone,
    required String intent,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.sendOtp,
      data: {
        'country_code': countryCode,
        'phone': phone,
        'intent': intent,
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
    RegistrationDraft? registration,
  }) async {
    final body = <String, dynamic>{
      'country_code': countryCode,
      'phone': phone,
      'otp': otp,
    };
    if (registration != null) {
      body.addAll(registration.toJson());
    }

    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.verifyOtp,
      data: body,
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

  @override
  Future<UserModel> updateProfile({
    String? name,
    int? cityId,
    int? currencyId,
    String? gender,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (cityId != null) body['city_id'] = cityId;
    if (currencyId != null) body['currency_id'] = currencyId;
    if (gender != null) body['gender'] = gender;

    final response = await _apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.profile,
      data: body,
    );
    final data = ApiResponseParser.requireDataMap(response);
    return UserModel.fromJson(data);
  }

  @override
  Future<void> deleteAccount() async {
    final response = await _apiClient.delete<Map<String, dynamic>>(
      ApiEndpoints.deleteAccount,
    );
    ApiResponseParser.requireSuccessData(response);
  }
}
