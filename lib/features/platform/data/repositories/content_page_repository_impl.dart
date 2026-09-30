import 'package:store/core/errors/failures.dart';
import 'package:store/core/network/network_exceptions.dart';
import 'package:store/core/network/network_info.dart';
import 'package:store/core/utils/result.dart';
import 'package:store/features/platform/data/datasources/content_page_remote_data_source.dart';
import 'package:store/features/platform/domain/entities/content_page_entity.dart';
import 'package:store/features/platform/domain/repositories/content_page_repository.dart';

class ContentPageRepositoryImpl implements ContentPageRepository {
  const ContentPageRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final ContentPageRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Result<List<ContentPageEntity>>> getPages() async {
    if (!await networkInfo.isConnected) {
      return const Result.failure(NetworkFailure());
    }
    try {
      return Result.ok(await remoteDataSource.getPages());
    } catch (e) {
      return Result.failure(NetworkExceptions.handle(e));
    }
  }

  @override
  Future<Result<ContentPageEntity>> getPage(String slug) async {
    if (!await networkInfo.isConnected) {
      return const Result.failure(NetworkFailure());
    }
    try {
      return Result.ok(await remoteDataSource.getPage(slug));
    } catch (e) {
      return Result.failure(NetworkExceptions.handle(e));
    }
  }
}
