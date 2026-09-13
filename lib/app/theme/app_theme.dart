import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData _base(Brightness b) { final dark=b==Brightness.dark; return ThemeData(useMaterial3:true,brightness:b,scaffoldBackgroundColor:dark?const Color(0xFF0D1017):const Color(0xFFF6F8FC), colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF),brightness:b),fontFamily:AppTypography.fontFamily,cardTheme:CardThemeData(elevation:0,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(16),side:BorderSide(color:dark?Colors.white12:Colors.black12))),appBarTheme:AppBarTheme(centerTitle:false,elevation:0,backgroundColor:dark?const Color(0xCC10141D):const Color(0xFFF6F8FC)),inputDecorationTheme:const InputDecorationTheme(border:OutlineInputBorder(),filled:true),snackBarTheme:const SnackBarThemeData(behavior:SnackBarBehavior.floating)); }
  static ThemeData get darkTheme=>_base(Brightness.dark); static ThemeData get lightTheme=>_base(Brightness.light);
}
