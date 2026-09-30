import 'package:store/core/utils/result.dart';
import 'package:store/core/utils/usecase.dart';
import 'package:store/features/platform/domain/entities/content_page_entity.dart';
import 'package:store/features/platform/domain/repositories/content_page_repository.dart';

class GetContentPagesUseCase implements UseCase<List<ContentPageEntity>, NoParams> {
  const GetContentPagesUseCase(this._repository);

  final ContentPageRepository _repository;

  @override
  Future<Result<List<ContentPageEntity>>> call(NoParams params) {
    return _repository.getPages();
  }
}
