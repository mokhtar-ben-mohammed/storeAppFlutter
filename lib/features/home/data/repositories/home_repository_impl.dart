import 'package:store/core/errors/failures.dart';
import 'package:store/core/network/network_exceptions.dart';
import 'package:store/core/network/network_info.dart';
import 'package:store/core/utils/result.dart';
import 'package:store/features/home/data/datasources/home_remote_data_source.dart';
import 'package:store/features/home/domain/entities/home_feed_entity.dart';
import 'package:store/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final HomeRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Result<HomeFeedEntity>> getHomeFeed() async {
    if (!await networkInfo.isConnected) {
      return const Result.failure(NetworkFailure());
    }

    try {
      final feed = await remoteDataSource.getHomeFeed();
      return Result.ok(feed);
    } catch (e) {
      return Result.failure(NetworkExceptions.handle(e));
    }
  }
}
