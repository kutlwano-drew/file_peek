import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppShortcuts {
  static const SingleActivator openFolder = SingleActivator(LogicalKeyboardKey.keyO, control: true);
  static const SingleActivator refreshFolder = SingleActivator(LogicalKeyboardKey.f5);
  static const SingleActivator refreshFolderCtrl = SingleActivator(LogicalKeyboardKey.keyR, control: true);
  static const SingleActivator search = SingleActivator(LogicalKeyboardKey.keyF, control: true);
  static const SingleActivator searchContents = SingleActivator(LogicalKeyboardKey.keyF, control: true, shift: true);
  static const SingleActivator copySelection = SingleActivator(LogicalKeyboardKey.keyC, control: true);
  static const SingleActivator copyTree = SingleActivator(LogicalKeyboardKey.keyC, control: true, shift: true);
  static const SingleActivator exportTree = SingleActivator(LogicalKeyboardKey.keyS, control: true);
  static const SingleActivator exportProject = SingleActivator(LogicalKeyboardKey.keyS, control: true, shift: true);
  static const SingleActivator clearSearch = SingleActivator(LogicalKeyboardKey.escape);
}
