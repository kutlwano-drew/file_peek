import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../core/services/app_preferences.dart';
import '../../../core/widgets/app_dialogs.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../controllers/explorer_controller.dart';
import '../widgets/app_bar.dart';
import '../widgets/file_preview_panel.dart';
import '../widgets/search_bar.dart';
import '../widgets/split_view.dart';
import '../widgets/status_bar.dart';
import '../widgets/toolbar.dart';
import '../widgets/tree_panel.dart';

class ExplorerScreen extends StatelessWidget {
  const ExplorerScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExplorerController(),
      child: Consumer2<ExplorerController, AppPreferences>(
        builder: (
          context,
          controller,
          preferences,
          _,
        ) {
          final hasFolder = controller.rootNode != null;
          final l = AppLocalizations.of(context);

          return Scaffold(
            // KEEP THE EXISTING APP BAR.
            appBar: FilePeekAppBar(
              canRefresh: hasFolder,
              hasActiveFolder: hasFolder,

              onSelectFolder: () {
                controller.pickAndScanDirectory(context);
              },

              onRefresh: () {
                controller.refreshCurrentDirectory(context);
              },

              onExportTree: () {
                if (hasFolder) {
                  controller.exportTree(context);
                }
              },

              onExportProject: () {
                if (hasFolder) {
                  controller.exportProject(context);
                }
              },

              onImportStructure: () {
                context.go('/structure-import');
              },

              onCreateDesktopEntry: () {
                AppDialogs.desktopEntry(context);
              },
            ),

            body: SafeArea(
              top: false,
              bottom: false,
              child: Column(
                children: [
                  // =========================================================
                  // EXISTING TOOLBAR — RESTORED BELOW THE APP BAR
                  // =========================================================
                  Toolbar(
                    onSelectFolder: () {
                      controller.pickAndScanDirectory(context);
                    },

                    onRefresh: () {
                      controller.refreshCurrentDirectory(context);
                    },

                    onToggleTerminal: () {
                      // Terminal toggle remains available through the
                      // existing Toolbar API. Terminal UI is deferred.
                    },

                    onOpenSettings: () {
                      context.go('/settings');
                    },

                    onExportTree: () {
                      if (hasFolder) {
                        controller.exportTree(context);
                      }
                    },

                    onExportProject: () {
                      if (hasFolder) {
                        controller.exportProject(context);
                      }
                    },

                    onOpenStructureImport: () {
                      context.go('/structure-import');
                    },

                    hasActiveFolder: hasFolder,
                  ),

                  // =========================================================
                  // SEARCH
                  // =========================================================
                  SearchBarWidget(
                    onSearchChanged: controller.updateSearchQuery,
                  ),

                  // =========================================================
                  // MAIN EXPLORER
                  // =========================================================
                  Expanded(
                    child: Stack(
                      children: [
                        LayoutBuilder(
                          builder: (
                            context,
                            constraints,
                          ) {
                            return SplitView(
                              leftPanel: TreePanel(
                                rootNode: controller.rootNode,
                                selectedNode:
                                    controller.selectedFileNode,
                                searchQuery: controller.searchQuery,
                                searchResults: controller.searchResults,
                                onFileSelected: (node) {
                                  controller.selectFile(
                                    node,
                                    context,
                                  );
                                },
                              ),

                              rightPanel: FilePreviewPanel(
                                selectedNode:
                                    controller.selectedFileNode,
                                previewResult:
                                    controller.filePreviewResult,
                              ),
                            );
                          },
                        ),

                        // ===================================================
                        // LOADING OVERLAY
                        // ===================================================
                        if (controller.isLoading)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black45,
                              child: LoadingIndicator(
                                message:
                                    controller.loadingMessage ??
                                        l.t('loading'),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // =========================================================
                  // STATUS BAR
                  // =========================================================
                  StatusBar(
                    statistics: controller.statistics,
                    selectedFile: controller.selectedFileNode,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}