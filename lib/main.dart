import 'package:store/app/bootstrap.dart';
import 'package:store/app/config/env_config.dart';

/// Application entry point.
/// Delegates entire startup lifecycle to the deterministic bootstrapper.
Future<void> main() async {
  await bootstrap(
    envConfig: EnvConfig.development(),
  );
}
