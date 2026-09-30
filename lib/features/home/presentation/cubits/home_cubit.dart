import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:store/core/utils/usecase.dart';
import 'package:store/features/home/domain/usecases/get_home_feed_usecase.dart';
import 'package:store/features/home/presentation/cubits/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required this.getHomeFeedUseCase}) : super(const HomeInitial());

  final GetHomeFeedUseCase getHomeFeedUseCase;

  Future<void> load() async {
    emit(const HomeLoading());
    final result = await getHomeFeedUseCase(const NoParams());
    result.fold(
      onSuccess: (feed) => emit(HomeLoaded(feed)),
      onFailure: (failure) => emit(HomeFailure(failure)),
    );
  }
}
