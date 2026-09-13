import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences extends ChangeNotifier {
  static const _hiddenKey='include_hidden', _depthKey='max_depth', _fontKey='preview_font', _linesKey='preview_lines', _unicodeKey='unicode_tree', _shellKey='default_shell', _langKey='language', _themeKey='theme', _videoLimitKey='video_limit_mb';
  bool includeHidden=false, showLineNumbers=true, defaultUnicodeTree=true;
  int maxDepth=10, videoLimitMB=250;
  double previewFontSize=13;
  String defaultShell='bash', languageCode='en', themeMode='dark';

  Future<void> load() async { final p=await SharedPreferences.getInstance(); includeHidden=p.getBool(_hiddenKey)??false; maxDepth=p.getInt(_depthKey)??10; previewFontSize=p.getDouble(_fontKey)??13; showLineNumbers=p.getBool(_linesKey)??true; defaultUnicodeTree=p.getBool(_unicodeKey)??true; defaultShell=p.getString(_shellKey)??'bash'; languageCode=p.getString(_langKey)??'en'; themeMode=p.getString(_themeKey)??'dark'; videoLimitMB=p.getInt(_videoLimitKey)??250; notifyListeners(); }
  Future<void> setHidden(bool v) async {includeHidden=v; notifyListeners(); await _set(_hiddenKey,v);}
  Future<void> setDepth(int v) async {maxDepth=v; notifyListeners(); await _set(_depthKey,v);}
  Future<void> setFont(double v) async {previewFontSize=v; notifyListeners(); await _set(_fontKey,v);}
  Future<void> setLineNumbers(bool v) async {showLineNumbers=v; notifyListeners(); await _set(_linesKey,v);}
  Future<void> setUnicode(bool v) async {defaultUnicodeTree=v; notifyListeners(); await _set(_unicodeKey,v);}
  Future<void> setShell(String v) async {defaultShell=v; notifyListeners(); await _set(_shellKey,v);}
  Future<void> setLanguage(String v) async {languageCode=v; notifyListeners(); await _set(_langKey,v);}
  Future<void> setTheme(String v) async {themeMode=v; notifyListeners(); await _set(_themeKey,v);}
  Future<void> setVideoLimit(int v) async {videoLimitMB=v; notifyListeners(); await _set(_videoLimitKey,v);}
  Future<void> _set(String k,Object v) async {(await SharedPreferences.getInstance()).setString(k,v.toString()); if(v is bool) await (await SharedPreferences.getInstance()).setBool(k,v); if(v is int) await (await SharedPreferences.getInstance()).setInt(k,v); if(v is double) await (await SharedPreferences.getInstance()).setDouble(k,v);}
}
