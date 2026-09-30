import 'package:equatable/equatable.dart';

/// Draft registration payload kept until OTP verification succeeds.
class RegistrationDraft extends Equatable {
  const RegistrationDraft({
    required this.name,
    required this.cityId,
    required this.gender,
    required this.acceptedPolicies,
  });

  final String name;
  final int cityId;
  final String gender; // male | female
  final List<String> acceptedPolicies;

  Map<String, dynamic> toJson() => {
        'name': name,
        'city_id': cityId,
        'gender': gender,
        'accepted_policies': acceptedPolicies,
      };

  @override
  List<Object?> get props => [name, cityId, gender, acceptedPolicies];
}
