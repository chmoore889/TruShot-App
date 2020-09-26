import 'package:shared_preferences/shared_preferences.dart';

class Database {
  SharedPreferences prefs;
  static const String dataKey = 'photoKeys';

  Database() {
    setPrefsInstance();
  }

  /// Sets the SharedPreferences instance unless the
  /// instance is already non-null
  Future<void> setPrefsInstance() async {
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
    }
  }

  Future<void> addPhotoKey(String photoKey) async {
    await setPrefsInstance();

    List<String> photoKeys;
    try {
      photoKeys = prefs.getStringList(dataKey);
    } catch (e) {
      print(e);
    }

    photoKeys = photoKeys ?? List<String>()
      ..add(photoKey);

    await prefs.setStringList(dataKey, photoKeys);
  }

  Future<List<String>> getPhotoKeys() async {
    await setPrefsInstance();

    List<String> toReturn;
    try {
      toReturn = prefs.getStringList(dataKey);
    } catch (e) {
      toReturn = List();
      print(e);
    }
    return toReturn;
  }
  Future<void> deletePhoto(String key) async {
    await setPrefsInstance();

    List<String> photoKeys;
    try{
      photoKeys = prefs.getStringList(dataKey);
    }
    catch(e) {
      print(e);
    }

    photoKeys = photoKeys ?? List<String>();

    if(!photoKeys.remove(key)) {
      return;
    }

    await prefs.setStringList(dataKey, photoKeys);
  }
}
