import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meta/meta.dart';

/// Used to store and retrieve the user email address and phone
class StorageProvider {
  StorageProvider({@required this.flutterSecureStorage})
      : assert(flutterSecureStorage != null);

  final FlutterSecureStorage flutterSecureStorage;

  static const String storageUserEmailKey = 'userEmailAddress';

  // email
  Future<void> setEmail(String email) async {
    await flutterSecureStorage.write(key: storageUserEmailKey, value: email);
  }

  Future<void> clearEmail() async {
    await flutterSecureStorage.delete(key: storageUserEmailKey);
  }

  Future<String> getEmail() async {
    return await flutterSecureStorage.read(key: storageUserEmailKey);
  }
}
