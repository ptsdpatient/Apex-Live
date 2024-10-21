import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();

Future<void> saveToken(String token) async {
  await storage.write(key: 'token', value: token);
}

Future<void> saveName(String name) async {
  await storage.write(key: 'username', value: name);
}


Future<String?> getToken() async {
  return await storage.read(key: 'token');
}

Future<void> removeToken() async {
  await storage.delete(key: 'token');
}
