import 'package:store/core/utils/result.dart';
import 'package:store/features/platform/domain/entities/content_page_entity.dart';

abstract interface class ContentPageRepository {
  Future<Result<List<ContentPageEntity>>> getPages();
  Future<Result<ContentPageEntity>> getPage(String slug);
}
