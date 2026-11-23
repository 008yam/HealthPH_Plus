import 'package:healthphplus/main_page.dart';
import 'package:flutter/material.dart';
import '../localization/app_translations.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';
import '../widgets/coach_mark.dart';
import '../widgets/data_collection/my_reports_tab.dart';
import '../widgets/data_collection/community_tab.dart';
import '../widgets/data_collection/self_report_wizard.dart';

class DataCollectionPage extends StatefulWidget {
  const DataCollectionPage({super.key});

  @override
  State<DataCollectionPage> createState() => _DataCollectionPageState();
}

class _DataCollectionPageState extends State<DataCollectionPage> {
  final dataHeaderKey = GlobalKey();
  final dataTabsKey = GlobalKey();
  final dataContentKey = GlobalKey();
  final reportSymptomsButtonKey = GlobalKey();

  Future<void> _openSelfReportWizard() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final screen = MediaQuery.sizeOf(dialogContext);

        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 620,
              maxHeight: screen.height * 0.90,
            ),
            child: SelfReportWizard(
              onSubmitted: () {
                if (Navigator.of(dialogContext).canPop()) {
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 650), () {
        if (!mounted) return;

        CoachMark.showOnce(
          context,
          discoveryKey: "health_contributions_v1",
          steps: [
            CoachMarkStep(
              targetKey: dataHeaderKey,
              title: "Health Contributions",
              description:
                  "Review your reports and explore anonymous community health trends.",
              icon: Icons.health_and_safety_outlined,
              color: AppTheme.primary,
            ),
            CoachMarkStep(
              targetKey: dataTabsKey,
              title: "Contribution Views",
              description:
                  "Switch between your previous reports and anonymous community information.",
              icon: Icons.tab,
              color: AppTheme.info,
            ),
            CoachMarkStep(
              targetKey: reportSymptomsButtonKey,
              title: "Report Symptoms",
              description:
                  "Open the guided self-report form to submit symptoms and location information.",
              icon: Icons.add_circle_outline,
              color: AppTheme.warning,
            ),
          ],
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final pagePadding = Responsive.pagePadding(context);
    final headerRadius = Responsive.isLandscapePhone(context) ? 24.0 : 45.0;
    final contentMargin = Responsive.isLandscapePhone(context)
        ? EdgeInsets.fromLTRB(pagePadding, 8, pagePadding, 8)
        : EdgeInsets.all(pagePadding * 0.8);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Column(
              children: [
                // HEADER
                KeyedSubtree(
                  key: dataHeaderKey,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(headerRadius),
                        bottomRight: Radius.circular(headerRadius),
                      ),
                    ),

                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          pagePadding,
                          10,
                          pagePadding,
                          Responsive.verticalGap(context, 20, compact: 12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                } else {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const MainPage(),
                                    ),
                                  );
                                }
                              },
                              child: Text(context.tr("Back")),
                            ),

                            SizedBox(
                              height: Responsive.verticalGap(context, 8),
                            ),

                            Image.asset(
                              'assets/images/healthphplusbarlogo.png',
                              height: Responsive.logoHeight(context),
                            ),

                            SizedBox(
                              height: Responsive.verticalGap(context, 8),
                            ),

                            Text(
                              context.tr("Health Contributions"),
                              style: TextStyle(
                                fontSize: Responsive.isLandscapePhone(context)
                                    ? 20
                                    : 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),

                            Text(
                              context.tr("Reports and community health trends"),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.indigo,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: Container(
                    margin: contentMargin,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppTheme.border),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Theme(
                      data: AppTheme.lightTheme,
                      child: Column(
                        children: [
                          KeyedSubtree(
                            key: dataTabsKey,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TabBar(
                                isScrollable: Responsive.isSmallPhone(context),
                                labelColor: Colors.black,
                                unselectedLabelColor: Colors.grey,
                                indicator: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.indigo,
                                      width: 3,
                                    ),
                                  ),
                                ),
                                tabs: [
                                  Tab(
                                    icon: const Icon(
                                      Icons.assignment_turned_in_outlined,
                                    ),
                                    text: context.tr("My Reports"),
                                  ),
                                  Tab(
                                    icon: const Icon(Icons.groups_outlined),
                                    text: context.tr("Community"),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          Expanded(
                            child: KeyedSubtree(
                              key: dataContentKey,
                              child: const TabBarView(
                                children: [MyReportsTab(), CommunityTab()],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: KeyedSubtree(
          key: reportSymptomsButtonKey,
          child: FloatingActionButton.extended(
            onPressed: _openSelfReportWizard,
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_circle_outline),
            label: Text(context.tr("Report Symptoms")),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
