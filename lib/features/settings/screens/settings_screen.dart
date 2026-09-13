import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../core/services/app_preferences.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppPreferences>(
      builder: (context, preferences, _) {
        final localization = AppLocalizations.of(context);

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.arrow_back),
              tooltip: localization.t('back'),
            ),
            title: Text(localization.t('settings')),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 900,
              ),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _SettingsCard(
                    title: localization.t('language'),
                    icon: Icons.language,
                    child: _LanguageSelector(
                      preferences: preferences,
                    ),
                  ),

                  _SettingsCard(
                    title: localization.t('appearance'),
                    icon: Icons.palette_outlined,
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(localization.t('light')),
                      subtitle: Text(
                        'Use the light appearance throughout File Peek.',
                      ),
                      value: preferences.themeMode == 'light',
                      onChanged: (value) {
                        preferences.setTheme(
                          value ? 'light' : 'dark',
                        );
                      },
                    ),
                  ),

                  _SettingsCard(
                    title: localization.t('treeSettings'),
                    icon: Icons.account_tree_outlined,
                    child: Column(
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            localization.t('showHiddenFiles'),
                          ),
                          subtitle: const Text(
                            'Include dot-files and dot-folders when scanning.',
                          ),
                          value: preferences.includeHidden,
                          onChanged: preferences.setHidden,
                        ),
                        const SizedBox(height: 8),
                        _SliderSetting(
                          title: localization.t('maxDepth'),
                          value: preferences.maxDepth.toDouble(),
                          min: 1,
                          max: 50,
                          divisions: 49,
                          label: '${preferences.maxDepth}',
                          valueLabel: '${preferences.maxDepth}',
                          onChanged: (value) {
                            preferences.setDepth(value.round());
                          },
                        ),
                      ],
                    ),
                  ),

                  _SettingsCard(
                    title: localization.t('previewSettings'),
                    icon: Icons.visibility_outlined,
                    child: Column(
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            localization.t('showLineNumbersSetting'),
                          ),
                          subtitle: const Text(
                            'Display line numbers in source-code previews.',
                          ),
                          value: preferences.showLineNumbers,
                          onChanged: preferences.setLineNumbers,
                        ),
                        const SizedBox(height: 8),
                        _SliderSetting(
                          title: localization.t('previewFontSize'),
                          value: preferences.previewFontSize,
                          min: 10,
                          max: 22,
                          divisions: 12,
                          label: preferences.previewFontSize
                              .toStringAsFixed(0),
                          valueLabel:
                              '${preferences.previewFontSize.toStringAsFixed(0)} pt',
                          onChanged: preferences.setFont,
                        ),
                      ],
                    ),
                  ),

                  _SettingsCard(
                    title: localization.t('exportSettings'),
                    icon: Icons.file_upload_outlined,
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        localization.t('unicodeTree'),
                      ),
                      subtitle: const Text(
                        'Use Unicode box-drawing characters when exporting trees.',
                      ),
                      value: preferences.defaultUnicodeTree,
                      onChanged: preferences.setUnicode,
                    ),
                  ),

                  _SettingsCard(
                    title: 'Media preview',
                    icon: Icons.movie_outlined,
                    child: _SliderSetting(
                      title: localization.t('videoPreviewLimit'),
                      value: preferences.videoLimitMB.toDouble(),
                      min: 50,
                      max: 2000,
                      divisions: 39,
                      label: '${preferences.videoLimitMB} MB',
                      valueLabel: '${preferences.videoLimitMB} MB',
                      onChanged: (value) {
                        preferences.setVideoLimit(value.round());
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SettingsCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _SliderSetting extends StatelessWidget {
  final String title;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String label;
  final String valueLabel;
  final ValueChanged<double> onChanged;

  const _SliderSetting({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.label,
    required this.valueLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 150,
          child: Text(title),
        ),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            label: label,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 80,
          child: Text(
            valueLabel,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  final AppPreferences preferences;

  const _LanguageSelector({
    required this.preferences,
  });

  @override
  Widget build(BuildContext context) {
    const languages = [
      _LanguageOption(
        code: 'en',
        countryCode: 'US',
        name: 'English',
      ),
      _LanguageOption(
        code: 'tn',
        countryCode: 'BW',
        name: 'Setswana',
      ),
      _LanguageOption(
        code: 'hi',
        countryCode: 'IN',
        name: 'हिन्दी',
      ),
      _LanguageOption(
        code: 'ar',
        countryCode: 'SA',
        name: 'العربية',
      ),
      _LanguageOption(
        code: 'zh',
        countryCode: 'CN',
        name: '中文',
      ),
    ];

    final localization = AppLocalizations.of(context);

    return DropdownButtonFormField<String>(
      initialValue: preferences.languageCode,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: localization.t('language'),
      ),
      isExpanded: true,
      items: languages.map((language) {
        return DropdownMenuItem<String>(
          value: language.code,
          child: Row(
            children: [
              CountryFlag.fromCountryCode(
                language.countryCode,
                theme: const ImageTheme(
                  width: 30,
                  height: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(language.name),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          preferences.setLanguage(value);
        }
      },
    );
  }
}

class _LanguageOption {
  final String code;
  final String countryCode;
  final String name;

  const _LanguageOption({
    required this.code,
    required this.countryCode,
    required this.name,
  });
}
