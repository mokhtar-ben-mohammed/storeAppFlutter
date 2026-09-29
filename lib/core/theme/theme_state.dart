import 'package:equatable/equatable.dart';
import 'package:store/core/theme/app_theme_mode.dart';

/// State representing the active theme selection.
class ThemeState extends Equatable {
  const ThemeState({this.mode = AppThemeMode.system});

  final AppThemeMode mode;

  ThemeState copyWith({AppThemeMode? mode}) {
    return ThemeState(mode: mode ?? this.mode);
  }

  @override
  List<Object?> get props => [mode];
}
