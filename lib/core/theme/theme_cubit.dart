import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:store/core/constants/storage_keys.dart';
import 'package:store/core/storage/local_storage_service.dart';
import 'package:store/core/theme/app_theme_mode.dart';
import 'package:store/core/theme/theme_state.dart';

/// Cubit managing theme mode state and persistence.
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit(this._storageService) : super(const ThemeState()) {
    _loadTheme();
  }

  final LocalStorageService _storageService;

  void _loadTheme() {
    final savedMode = _storageService.getString(StorageKeys.themeMode);
    if (savedMode != null) {
      emit(ThemeState(mode: AppThemeMode.fromString(savedMode)));
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    emit(ThemeState(mode: mode));
    await _storageService.setString(StorageKeys.themeMode, mode.name);
  }

  Future<void> toggleTheme() async {
    final nextMode = state.mode == AppThemeMode.dark ? AppThemeMode.light : AppThemeMode.dark;
    await setThemeMode(nextMode);
  }
}
