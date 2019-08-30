import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:passwordless_demo/src/storage_provider.dart';

class StorageRepository {
  final _store =
      StorageProvider(flutterSecureStorage: new FlutterSecureStorage());

  Future<void> setEmail(String email) => _store.setEmail(email);

  Future<void> clearEmail() => _store.clearEmail();

  Future<String> getEmail() => _store.getEmail();
}
