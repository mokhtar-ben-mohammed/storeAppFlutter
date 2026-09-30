import 'package:store/core/utils/result.dart';
import 'package:store/features/home/domain/entities/home_feed_entity.dart';

abstract interface class HomeRepository {
  Future<Result<HomeFeedEntity>> getHomeFeed();
}
