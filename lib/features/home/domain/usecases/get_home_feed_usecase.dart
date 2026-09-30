import 'package:store/core/utils/result.dart';
import 'package:store/core/utils/usecase.dart';
import 'package:store/features/home/domain/entities/home_feed_entity.dart';
import 'package:store/features/home/domain/repositories/home_repository.dart';

class GetHomeFeedUseCase implements UseCase<HomeFeedEntity, NoParams> {
  const GetHomeFeedUseCase(this._repository);

  final HomeRepository _repository;

  @override
  Future<Result<HomeFeedEntity>> call(NoParams params) {
    return _repository.getHomeFeed();
  }
}
