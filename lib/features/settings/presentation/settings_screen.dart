import 'package:flutter/material.dart';
import 'package:frontend_poc_arrow/core/localization/l10n/app_localizations.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../game/presentation/game_ui_keys.dart';
import '../../progress/infrastructure/local_progress_dependencies.dart';
import '../infrastructure/settings_dependencies.dart';
import 'settings_screen_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({this.controller, super.key});

  final SettingsScreenController? controller;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  SettingsScreenController? _controller;

  @override
  void initState() {
    super.initState();
    final providedController = widget.controller;
    if (providedController != null) {
      _controller = providedController..load();
      return;
    }
    _createController();
  }

  Future<void> _createController() async {
    final controller = SettingsScreenController(
      getPlayerSettings:
          await SettingsDependencies.createGetPlayerSettingsUseCase(),
      savePlayerSettings:
          await SettingsDependencies.createSavePlayerSettingsUseCase(),
      resetLocalProgress:
          await LocalProgressDependencies.createResetLocalProgressUseCase(),
    );
    if (!mounted) {
      controller.dispose();
      return;
    }
    setState(() {
      _controller = controller;
    });
    await controller.load();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final controller = _controller;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.settings)),
      body: SafeArea(
        child: controller == null
            ? _LoadingState(message: localizations.loadingSettings)
            : AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  return switch (controller.loadState) {
                    SettingsScreenLoadState.loading => _LoadingState(
                      message: localizations.loadingSettings,
                    ),
                    SettingsScreenLoadState.failed => _SettingsError(
                      onRetry: controller.load,
                    ),
                    SettingsScreenLoadState.ready => _SettingsContent(
                      controller: controller,
                    ),
                  };
                },
              ),
      ),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent({required this.controller});

  final SettingsScreenController controller;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final settings = controller.settings;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: SwitchListTile(
            key: GameUiKeys.soundSwitch,
            value: settings.soundEnabled,
            onChanged: controller.setSoundEnabled,
            title: Text(localizations.soundEnabled),
            subtitle: Text(localizations.soundFoundationDescription),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: SwitchListTile(
            key: GameUiKeys.musicSwitch,
            value: settings.musicEnabled,
            onChanged: controller.setMusicEnabled,
            title: Text(localizations.musicEnabled),
            subtitle: Text(localizations.musicFutureDescription),
          ),
        ),
        const SizedBox(height: 12),
        _ReadOnlyInfoCard(
          title: localizations.language,
          value: localizations.languageDisplayValue,
        ),
        const SizedBox(height: 12),
        _ReadOnlyInfoCard(
          title: localizations.backendUrlLabel,
          value: AppConfig.apiBaseUrl,
        ),
        const SizedBox(height: 20),
        FilledButton.tonalIcon(
          key: GameUiKeys.resetProgressButton,
          onPressed: () => _confirmResetProgress(context),
          icon: const Icon(Icons.restart_alt_rounded),
          label: Text(localizations.resetProgress),
        ),
      ],
    );
  }

  Future<void> _confirmResetProgress(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(localizations.resetProgress),
          content: Text(localizations.resetProgressConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(localizations.cancel),
            ),
            FilledButton(
              key: GameUiKeys.confirmResetProgressButton,
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(localizations.resetProgress),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    await controller.resetProgress();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(localizations.progressReset)));
  }
}

class _ReadOnlyInfoCard extends StatelessWidget {
  const _ReadOnlyInfoCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.softText,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(value),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(message));
  }
}

class _SettingsError extends StatelessWidget {
  const _SettingsError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Center(
      child: FilledButton(onPressed: onRetry, child: Text(localizations.retry)),
    );
  }
}
