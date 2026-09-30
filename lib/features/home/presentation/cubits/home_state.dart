import 'package:equatable/equatable.dart';
import 'package:store/core/errors/failures.dart';
import 'package:store/features/home/domain/entities/home_feed_entity.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

final class HomeInitial extends HomeState {
  const HomeInitial();
}

final class HomeLoading extends HomeState {
  const HomeLoading();
}

final class HomeLoaded extends HomeState {
  const HomeLoaded(this.feed);

  final HomeFeedEntity feed;

  @override
  List<Object?> get props => [feed];
}

final class HomeFailure extends HomeState {
  const HomeFailure(this.failure);

  final Failure failure;

  String get message => failure.message;

  @override
  List<Object?> get props => [failure];
}
