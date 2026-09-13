import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  const AppLocalizations(this.locale);

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('tn'),
    Locale('hi'),
    Locale('ar'),
    Locale('zh'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final result =
        Localizations.of<AppLocalizations>(context, AppLocalizations);

    if (result == null) {
      return const AppLocalizations(Locale('en'));
    }

    return result;
  }

  bool get isRtl => locale.languageCode == 'ar';

  static const Map<String, Map<String, String>> _translations = {
    'en': {
      'app': 'File Peek',

      // Menus
      'file': 'File',
      'view': 'View',
      'tools': 'Tools',
      'settings': 'Settings',
      'help': 'Help',
      'developer': 'Developer',

      // File menu
      'selectFolder': 'Select Folder',
      'refresh': 'Refresh',
      'exportTree': 'Export Tree',
      'exportProject': 'Export Project',
      'importStructure': 'Import Structure',
      'createDesktopEntry': 'Create Desktop Entry',
      'exit': 'Exit',

      // View
      'preview': 'Preview',
      'lineNumbers': 'Line Numbers',
      'showLineNumbers': 'Show Line Numbers',
      'hideLineNumbers': 'Hide Line Numbers',
      'showHiddenFiles': 'Show Hidden Files',
      'hideHiddenFiles': 'Hide Hidden Files',

      // Explorer
      'search': 'Search',
      'searchFiles': 'Search files...',
      'noFile': 'No file selected',
      'selectFile': 'Select a file from the directory tree to inspect its contents.',
      'loading': 'Loading...',
      'loadingFilePreview': 'Loading file preview...',
      'path': 'Path',
      'size': 'Size',
      'modified': 'Modified',
      'lines': 'Lines',
      'words': 'Words',
      'characters': 'Characters',

      // Preview
      'filePreview': 'File Preview',
      'sourceCode': 'Source Code',
      'text': 'Text',
      'binaryFile': 'Binary File',
      'binaryPreviewNotSupported': 'Binary file preview is not supported.',
      'largeFile': 'Large File',
      'fileTooLarge': 'This file exceeds the maximum preview size.',
      'emptyFile': 'This file is empty.',
      'errorReadingFile': 'Error reading file',

      // Settings
      'applicationSettings': 'Application Settings',
      'language': 'Language',
      'appearance': 'Appearance',
      'theme': 'Theme',
      'light': 'Light',
      'dark': 'Dark',
      'system': 'System',
      'previewSettings': 'Preview Settings',
      'treeSettings': 'Tree Settings',
      'exportSettings': 'Export Settings',
      'terminalSettings': 'Terminal Settings',
      'previewFontSize': 'Preview Font Size',
      'previewLimit': 'Preview Size Limit',
      'videoPreviewLimit': 'Video Preview Limit',
      'showLineNumbersSetting': 'Show Line Numbers',
      'includeHiddenFiles': 'Include Hidden Files',
      'maxDepth': 'Maximum Tree Depth',
      'unicodeTree': 'Unicode Tree',
      'defaultShell': 'Default Shell',
      'save': 'Save',
      'reset': 'Reset',
      'cancel': 'Cancel',
      'close': 'Close',

      // Dialogs
      'choose': 'Choose an option',
      'confirm': 'Confirm',
      'ok': 'OK',
      'yes': 'Yes',
      'no': 'No',
      'continue': 'Continue',
      'back': 'Back',
      'delete': 'Delete',

      // Exit
      'exitApplication': 'Exit Application',
      'exitConfirmation':
          'Are you sure you want to exit File Peek?',
      'exitCountdown':
          'The application will close shortly.',
      'stay': 'Stay',

      // Errors
      'error': 'Error',
      'warning': 'Warning',
      'success': 'Success',
      'operationFailed': 'Operation failed.',
      'invalidPath': 'The selected path is invalid.',
      'accessDenied': 'Access denied.',
      'fileNotFound': 'File not found.',
      'folderNotFound': 'Folder not found.',
      'unableToReadFile': 'Unable to read this file.',

      // About
      'about': 'About',
      'aboutFilePeek': 'About File Peek',
      'aboutDescription':
          'File Peek is a desktop file and project inspection tool.',

      // Desktop entry
      'desktopEntry': 'Desktop Entry',
      'desktopEntryCreated': 'Desktop entry created successfully.',
      'desktopEntryFailed': 'Unable to create desktop entry.',
    },

    'tn': {
      'app': 'File Peek',

      'file': 'Faele',
      'view': 'Lebelela',
      'tools': 'Didirisiwa',
      'settings': 'Dithulaganyo',
      'help': 'Thuso',
      'developer': 'Mothami',

      'selectFolder': 'Tlhopha Foldara',
      'refresh': 'Ntšhafatsa',
      'exportTree': 'Romela Setlhare',
      'exportProject': 'Romela Porojeke',
      'importStructure': 'Tsaya Sebopego',
      'createDesktopEntry': 'Dira Desktop Entry',
      'exit': 'Tswa',

      'preview': 'Lebelela',
      'lineNumbers': 'Dipalo tsa mela',
      'showLineNumbers': 'Bontsha dipalo tsa mela',
      'hideLineNumbers': 'Fitlha dipalo tsa mela',
      'showHiddenFiles': 'Bontsha difaele tse di fitlhilweng',
      'hideHiddenFiles': 'Fitlha difaele tse di fitlhilweng',

      'search': 'Batla',
      'searchFiles': 'Batla difaele...',
      'noFile': 'Ga go faele e e tlhophilweng',
      'selectFile':
          'Tlhopha faele mo setlhareng sa difaele go bona diteng tsa yone.',
      'loading': 'E a laisa...',
      'loadingFilePreview': 'E laisa ponelopele ya faele...',
      'path': 'Tsela',
      'size': 'Bogolo',
      'modified': 'E fetotswe',
      'lines': 'Mela',
      'words': 'Mafoko',
      'characters': 'Ditlhaka',

      'filePreview': 'Ponelopele ya Faele',
      'sourceCode': 'Khoutu ya Motswedi',
      'text': 'Mokwalo',
      'binaryFile': 'Faele ya Binary',
      'binaryPreviewNotSupported':
          'Ponelopele ya faele ya binary ga e tshegediwe.',
      'largeFile': 'Faele e Kgolo',
      'fileTooLarge':
          'Faele eno e feta bogolo jo bo letleletsweng jwa ponelopele.',
      'emptyFile': 'Faele eno ga e na sepe.',
      'errorReadingFile': 'Phoso fa go balwa faele',

      'applicationSettings': 'Dithulaganyo tsa App',
      'language': 'Puo',
      'appearance': 'Ponalo',
      'theme': 'Setlhogo',
      'light': 'Lesedi',
      'dark': 'Lefifi',
      'system': 'Tsamaiso',
      'previewSettings': 'Dithulaganyo tsa Ponelopele',
      'treeSettings': 'Dithulaganyo tsa Setlhare',
      'exportSettings': 'Dithulaganyo tsa Thomelo',
      'terminalSettings': 'Dithulaganyo tsa Terminal',
      'previewFontSize': 'Bogolo jwa Mokwalo wa Ponelopele',
      'previewLimit': 'Molelwane wa Bogolo jwa Ponelopele',
      'videoPreviewLimit': 'Molelwane wa Ponelopele ya Video',
      'showLineNumbersSetting': 'Bontsha Dipalo tsa Mela',
      'includeHiddenFiles': 'Akaretsa Difaele tse di Fitlhilweng',
      'maxDepth': 'Boteng jo Bogolo jwa Setlhare',
      'unicodeTree': 'Setlhare sa Unicode',
      'defaultShell': 'Shell ya Tlwaelo',
      'save': 'Boloka',
      'reset': 'Busetsa',
      'cancel': 'Khansela',
      'close': 'Tswala',

      'choose': 'Tlhopha sengwe',
      'confirm': 'Netefatsa',
      'ok': 'Go siame',
      'yes': 'Ee',
      'no': 'Nnyaa',
      'continue': 'Tswelela',
      'back': 'Morago',
      'delete': 'Phimola',

      'exitApplication': 'Tswa mo App',
      'exitConfirmation':
          'A o tlhomamisegile gore o batla go tswa mo File Peek?',
      'exitCountdown': 'App e tla tswalwa mo nakong e khutshwane.',
      'stay': 'Nna',

      'error': 'Phoso',
      'warning': 'Tlhagiso',
      'success': 'Go atlegile',
      'operationFailed': 'Tiro e paletswe.',
      'invalidPath': 'Tsela e e tlhophilweng ga e a siama.',
      'accessDenied': 'Phitlhelelo e ganetswe.',
      'fileNotFound': 'Faele ga e bonwe.',
      'folderNotFound': 'Foldara ga e bonwe.',
      'unableToReadFile': 'Ga go kgonege go bala faele eno.',

      'about': 'Ka ga',
      'aboutFilePeek': 'Ka ga File Peek',
      'aboutDescription':
          'File Peek ke sedirisiwa sa desktop sa go tlhatlhoba difaele le diporojeke.',

      'desktopEntry': 'Desktop Entry',
      'desktopEntryCreated': 'Desktop entry e dirilwe ka katlego.',
      'desktopEntryFailed': 'Ga go kgonege go dira desktop entry.',
    },

    'hi': {
      'app': 'File Peek',

      'file': 'फ़ाइल',
      'view': 'दृश्य',
      'tools': 'उपकरण',
      'settings': 'सेटिंग्स',
      'help': 'मदद',
      'developer': 'डेवलपर',

      'selectFolder': 'फ़ोल्डर चुनें',
      'refresh': 'रिफ़्रेश',
      'exportTree': 'ट्री निर्यात करें',
      'exportProject': 'प्रोजेक्ट निर्यात करें',
      'importStructure': 'स्ट्रक्चर आयात करें',
      'createDesktopEntry': 'डेस्कटॉप एंट्री बनाएँ',
      'exit': 'बाहर निकलें',

      'preview': 'पूर्वावलोकन',
      'lineNumbers': 'लाइन नंबर',
      'showLineNumbers': 'लाइन नंबर दिखाएँ',
      'hideLineNumbers': 'लाइन नंबर छिपाएँ',
      'showHiddenFiles': 'छिपी फ़ाइलें दिखाएँ',
      'hideHiddenFiles': 'छिपी फ़ाइलें छिपाएँ',

      'search': 'खोजें',
      'searchFiles': 'फ़ाइलें खोजें...',
      'noFile': 'कोई फ़ाइल चयनित नहीं',
      'selectFile':
          'फ़ाइल की सामग्री देखने के लिए डायरेक्टरी ट्री से फ़ाइल चुनें।',
      'loading': 'लोड हो रहा है...',
      'loadingFilePreview': 'फ़ाइल पूर्वावलोकन लोड हो रहा है...',
      'path': 'पथ',
      'size': 'आकार',
      'modified': 'संशोधित',
      'lines': 'लाइनें',
      'words': 'शब्द',
      'characters': 'अक्षर',

      'filePreview': 'फ़ाइल पूर्वावलोकन',
      'sourceCode': 'सोर्स कोड',
      'text': 'टेक्स्ट',
      'binaryFile': 'बाइनरी फ़ाइल',
      'binaryPreviewNotSupported':
          'बाइनरी फ़ाइल का पूर्वावलोकन समर्थित नहीं है।',
      'largeFile': 'बड़ी फ़ाइल',
      'fileTooLarge':
          'यह फ़ाइल अधिकतम पूर्वावलोकन सीमा से बड़ी है।',
      'emptyFile': 'यह फ़ाइल खाली है।',
      'errorReadingFile': 'फ़ाइल पढ़ने में त्रुटि',

      'applicationSettings': 'एप्लिकेशन सेटिंग्स',
      'language': 'भाषा',
      'appearance': 'दिखावट',
      'theme': 'थीम',
      'light': 'लाइट',
      'dark': 'डार्क',
      'system': 'सिस्टम',
      'previewSettings': 'पूर्वावलोकन सेटिंग्स',
      'treeSettings': 'ट्री सेटिंग्स',
      'exportSettings': 'निर्यात सेटिंग्स',
      'terminalSettings': 'टर्मिनल सेटिंग्स',
      'previewFontSize': 'पूर्वावलोकन फ़ॉन्ट आकार',
      'previewLimit': 'पूर्वावलोकन आकार सीमा',
      'videoPreviewLimit': 'वीडियो पूर्वावलोकन सीमा',
      'showLineNumbersSetting': 'लाइन नंबर दिखाएँ',
      'includeHiddenFiles': 'छिपी फ़ाइलें शामिल करें',
      'maxDepth': 'अधिकतम ट्री गहराई',
      'unicodeTree': 'Unicode ट्री',
      'defaultShell': 'डिफ़ॉल्ट Shell',
      'save': 'सहेजें',
      'reset': 'रीसेट',
      'cancel': 'रद्द करें',
      'close': 'बंद करें',

      'choose': 'एक विकल्प चुनें',
      'confirm': 'पुष्टि करें',
      'ok': 'ठीक है',
      'yes': 'हाँ',
      'no': 'नहीं',
      'continue': 'जारी रखें',
      'back': 'वापस',
      'delete': 'हटाएँ',

      'exitApplication': 'एप्लिकेशन से बाहर निकलें',
      'exitConfirmation':
          'क्या आप वाकई File Peek से बाहर निकलना चाहते हैं?',
      'exitCountdown': 'एप्लिकेशन जल्द बंद हो जाएगा।',
      'stay': 'रुकें',

      'error': 'त्रुटि',
      'warning': 'चेतावनी',
      'success': 'सफल',
      'operationFailed': 'ऑपरेशन विफल हुआ।',
      'invalidPath': 'चयनित पथ अमान्य है।',
      'accessDenied': 'पहुँच अस्वीकृत है।',
      'fileNotFound': 'फ़ाइल नहीं मिली।',
      'folderNotFound': 'फ़ोल्डर नहीं मिला।',
      'unableToReadFile': 'यह फ़ाइल पढ़ी नहीं जा सकती।',

      'about': 'जानकारी',
      'aboutFilePeek': 'File Peek के बारे में',
      'aboutDescription':
          'File Peek डेस्कटॉप फ़ाइल और प्रोजेक्ट निरीक्षण उपकरण है।',

      'desktopEntry': 'डेस्कटॉप एंट्री',
      'desktopEntryCreated': 'डेस्कटॉप एंट्री सफलतापूर्वक बनाई गई।',
      'desktopEntryFailed': 'डेस्कटॉप एंट्री नहीं बनाई जा सकी।',
    },

    'ar': {
      'app': 'File Peek',

      'file': 'ملف',
      'view': 'عرض',
      'tools': 'أدوات',
      'settings': 'الإعدادات',
      'help': 'مساعدة',
      'developer': 'المطور',

      'selectFolder': 'اختيار مجلد',
      'refresh': 'تحديث',
      'exportTree': 'تصدير الشجرة',
      'exportProject': 'تصدير المشروع',
      'importStructure': 'استيراد البنية',
      'createDesktopEntry': 'إنشاء إدخال سطح المكتب',
      'exit': 'خروج',

      'preview': 'معاينة',
      'lineNumbers': 'أرقام الأسطر',
      'showLineNumbers': 'إظهار أرقام الأسطر',
      'hideLineNumbers': 'إخفاء أرقام الأسطر',
      'showHiddenFiles': 'إظهار الملفات المخفية',
      'hideHiddenFiles': 'إخفاء الملفات المخفية',

      'search': 'بحث',
      'searchFiles': 'البحث عن الملفات...',
      'noFile': 'لم يتم اختيار ملف',
      'selectFile': 'اختر ملفًا من شجرة المجلدات لعرض محتواه.',
      'loading': 'جارٍ التحميل...',
      'loadingFilePreview': 'جارٍ تحميل معاينة الملف...',
      'path': 'المسار',
      'size': 'الحجم',
      'modified': 'تم التعديل',
      'lines': 'الأسطر',
      'words': 'الكلمات',
      'characters': 'الأحرف',

      'filePreview': 'معاينة الملف',
      'sourceCode': 'الكود المصدري',
      'text': 'نص',
      'binaryFile': 'ملف ثنائي',
      'binaryPreviewNotSupported':
          'معاينة الملفات الثنائية غير مدعومة.',
      'largeFile': 'ملف كبير',
      'fileTooLarge': 'يتجاوز هذا الملف الحد الأقصى للمعاينة.',
      'emptyFile': 'هذا الملف فارغ.',
      'errorReadingFile': 'خطأ في قراءة الملف',

      'applicationSettings': 'إعدادات التطبيق',
      'language': 'اللغة',
      'appearance': 'المظهر',
      'theme': 'السمة',
      'light': 'فاتح',
      'dark': 'داكن',
      'system': 'النظام',
      'previewSettings': 'إعدادات المعاينة',
      'treeSettings': 'إعدادات الشجرة',
      'exportSettings': 'إعدادات التصدير',
      'terminalSettings': 'إعدادات الطرفية',
      'previewFontSize': 'حجم خط المعاينة',
      'previewLimit': 'حد حجم المعاينة',
      'videoPreviewLimit': 'حد معاينة الفيديو',
      'showLineNumbersSetting': 'إظهار أرقام الأسطر',
      'includeHiddenFiles': 'تضمين الملفات المخفية',
      'maxDepth': 'أقصى عمق للشجرة',
      'unicodeTree': 'شجرة Unicode',
      'defaultShell': 'الصدفة الافتراضية',
      'save': 'حفظ',
      'reset': 'إعادة ضبط',
      'cancel': 'إلغاء',
      'close': 'إغلاق',

      'choose': 'اختر خيارًا',
      'confirm': 'تأكيد',
      'ok': 'موافق',
      'yes': 'نعم',
      'no': 'لا',
      'continue': 'متابعة',
      'back': 'رجوع',
      'delete': 'حذف',

      'exitApplication': 'الخروج من التطبيق',
      'exitConfirmation':
          'هل أنت متأكد أنك تريد الخروج من File Peek؟',
      'exitCountdown': 'سيتم إغلاق التطبيق قريبًا.',
      'stay': 'البقاء',

      'error': 'خطأ',
      'warning': 'تحذير',
      'success': 'نجاح',
      'operationFailed': 'فشلت العملية.',
      'invalidPath': 'المسار المحدد غير صالح.',
      'accessDenied': 'تم رفض الوصول.',
      'fileNotFound': 'لم يتم العثور على الملف.',
      'folderNotFound': 'لم يتم العثور على المجلد.',
      'unableToReadFile': 'تعذر قراءة هذا الملف.',

      'about': 'حول',
      'aboutFilePeek': 'حول File Peek',
      'aboutDescription':
          'File Peek أداة سطح مكتب لفحص الملفات والمشاريع.',

      'desktopEntry': 'إدخال سطح المكتب',
      'desktopEntryCreated':
          'تم إنشاء إدخال سطح المكتب بنجاح.',
      'desktopEntryFailed':
          'تعذر إنشاء إدخال سطح المكتب.',
    },

    'zh': {
      'app': 'File Peek',

      'file': '文件',
      'view': '查看',
      'tools': '工具',
      'settings': '设置',
      'help': '帮助',
      'developer': '开发者',

      'selectFolder': '选择文件夹',
      'refresh': '刷新',
      'exportTree': '导出目录树',
      'exportProject': '导出项目',
      'importStructure': '导入结构',
      'createDesktopEntry': '创建桌面快捷方式',
      'exit': '退出',

      'preview': '预览',
      'lineNumbers': '行号',
      'showLineNumbers': '显示行号',
      'hideLineNumbers': '隐藏行号',
      'showHiddenFiles': '显示隐藏文件',
      'hideHiddenFiles': '隐藏文件',

      'search': '搜索',
      'searchFiles': '搜索文件...',
      'noFile': '未选择文件',
      'selectFile': '从目录树中选择文件以查看其内容。',
      'loading': '正在加载...',
      'loadingFilePreview': '正在加载文件预览...',
      'path': '路径',
      'size': '大小',
      'modified': '修改时间',
      'lines': '行',
      'words': '单词',
      'characters': '字符',

      'filePreview': '文件预览',
      'sourceCode': '源代码',
      'text': '文本',
      'binaryFile': '二进制文件',
      'binaryPreviewNotSupported': '不支持预览二进制文件。',
      'largeFile': '大文件',
      'fileTooLarge': '此文件超过了最大预览大小。',
      'emptyFile': '此文件为空。',
      'errorReadingFile': '读取文件时出错',

      'applicationSettings': '应用程序设置',
      'language': '语言',
      'appearance': '外观',
      'theme': '主题',
      'light': '浅色',
      'dark': '深色',
      'system': '系统',
      'previewSettings': '预览设置',
      'treeSettings': '目录树设置',
      'exportSettings': '导出设置',
      'terminalSettings': '终端设置',
      'previewFontSize': '预览字体大小',
      'previewLimit': '预览大小限制',
      'videoPreviewLimit': '视频预览限制',
      'showLineNumbersSetting': '显示行号',
      'includeHiddenFiles': '包含隐藏文件',
      'maxDepth': '最大目录树深度',
      'unicodeTree': 'Unicode 目录树',
      'defaultShell': '默认 Shell',
      'save': '保存',
      'reset': '重置',
      'cancel': '取消',
      'close': '关闭',

      'choose': '请选择',
      'confirm': '确认',
      'ok': '确定',
      'yes': '是',
      'no': '否',
      'continue': '继续',
      'back': '返回',
      'delete': '删除',

      'exitApplication': '退出应用',
      'exitConfirmation': '确定要退出 File Peek 吗？',
      'exitCountdown': '应用即将关闭。',
      'stay': '留下',

      'error': '错误',
      'warning': '警告',
      'success': '成功',
      'operationFailed': '操作失败。',
      'invalidPath': '所选路径无效。',
      'accessDenied': '访问被拒绝。',
      'fileNotFound': '未找到文件。',
      'folderNotFound': '未找到文件夹。',
      'unableToReadFile': '无法读取此文件。',

      'about': '关于',
      'aboutFilePeek': '关于 File Peek',
      'aboutDescription': 'File Peek 是一个桌面文件和项目检查工具。',

      'desktopEntry': '桌面快捷方式',
      'desktopEntryCreated': '桌面快捷方式创建成功。',
      'desktopEntryFailed': '无法创建桌面快捷方式。',
    },
  };

  String t(String key) {
    return _translations[locale.languageCode]?[key] ??
        _translations['en']![key] ??
        key;
  }
}

class AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supported) =>
          supported.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(
    covariant LocalizationsDelegate<AppLocalizations> old,
  ) {
    return false;
  }
}