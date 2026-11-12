import 'package:flutter/material.dart';
import '../localization/app_translations.dart';
import '../models/mobile_alert.dart';
import '../services/api_config.dart';
import '../services/mobile_alert_service.dart';
import '../services/profile_store.dart';
import '../theme/responsive.dart';
import '../theme/app_theme.dart';
import '../widgets/disease_alert_card.dart';
import 'package:healthphplus/main_page.dart';

class DiseaseWatchPage extends StatefulWidget {
  final MobileAlertService? alertService;
  const DiseaseWatchPage({super.key, this.alertService});
  @override
  State<DiseaseWatchPage> createState() => _DiseaseWatchPageState();
}

class _DiseaseWatchPageState extends State<DiseaseWatchPage> {
  late final MobileAlertService _service;
  final _search = TextEditingController();
  final List<MobileAlert> _alerts = [];
  String? _cursor;
  String? _error;
  bool _loading = false;
  bool _opening = false;
  String _readFilter = 'all';
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _service =
        widget.alertService ?? MobileAlertService(baseUrl: ApiConfig.baseUrl);
    ProfileStore.instance.addListener(_profileChanged);
    _load();
  }

  void _profileChanged() => _load();

  Future<void> _load({bool more = false}) async {
    if (more && (_loading || _cursor == null)) return;
    final generation = ++_generation;
    setState(() {
      _loading = true;
      _error = null;
      if (!more) {
        _alerts.clear();
        _cursor = null;
      }
    });
    try {
      final page = await _service.fetchAlerts(
        accessToken: ProfileStore.instance.profile?.accessToken,
        cursor: more ? _cursor : null,
      );
      if (!mounted || generation != _generation) return;
      setState(() {
        final ids = _alerts.map((a) => a.id).toSet();
        _alerts.addAll(page.items.where((a) => ids.add(a.id)));
        _cursor = page.nextCursor?.isNotEmpty == true ? page.nextCursor : null;
      });
    } catch (error) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _error = error is MobileAlertAuthenticationException
            ? error.message
            : 'Unable to load alerts.';
        if (error is MobileAlertAuthenticationException) {
          _alerts.clear();
          _cursor = null;
        }
      });
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _open(MobileAlert alert) async {
    if (_opening) return;
    setState(() => _opening = true);
    final token = ProfileStore.instance.profile?.accessToken;
    try {
      final detail = await _service.fetchAlert(
        alertId: alert.id,
        accessToken: token,
      );
      if (!mounted || token != ProfileStore.instance.profile?.accessToken) {
        return;
      }
      setState(() => _opening = false);
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => Theme(
          data: AppTheme.lightTheme,
          child: AlertDialog(
            title: Text(detail.title),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detail.regionName.isEmpty
                        ? detail.region
                        : detail.regionName,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    detail.message.isEmpty
                        ? context.tr(
                            'No additional alert details were provided.',
                          )
                        : detail.message,
                  ),
                  if (detail.publishedAt != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      MaterialLocalizations.of(
                        context,
                      ).formatMediumDate(detail.publishedAt!.toLocal()),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(context.tr('Close')),
              ),
            ],
          ),
        ),
      );
      if (!mounted || token != ProfileStore.instance.profile?.accessToken) {
        return;
      }
      try {
        final read = await _service.markAlertRead(
          alertId: alert.id,
          accessToken: token,
        );
        if (!mounted || token != ProfileStore.instance.profile?.accessToken) {
          return;
        }
        setState(() {
          final index = _alerts.indexWhere((a) => a.id == alert.id);
          if (index >= 0) _alerts[index] = read.item;
        });
      } catch (error) {
        if (!mounted) return;
        _notify(
          error is MobileAlertAuthenticationException
              ? error.message
              : 'Unable to mark alert as read.',
        );
      }
    } catch (error) {
      if (!mounted) return;
      _notify(
        error is MobileAlertAuthenticationException
            ? error.message
            : 'Unable to open this alert right now.',
      );
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  void _notify(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(context.tr(message))));

  @override
  void dispose() {
    ProfileStore.instance.removeListener(_profileChanged);
    _search.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  final colors = AppTheme.lightTheme.colorScheme;
  final query = _search.text.trim().toLowerCase();
  final pagePadding = Responsive.pagePadding(context);
  final headerRadius = Responsive.isLandscapePhone(context) ? 24.0 : 35.0;
  final contentMargin = Responsive.isLandscapePhone(context)
      ? EdgeInsets.fromLTRB(pagePadding, 8, pagePadding, 8)
      : EdgeInsets.all(pagePadding * 0.8);

  final visible = _alerts
      .where(
        (alert) =>
            '${alert.title} ${alert.regionName} '
                    '${alert.region} ${alert.message}'
                .toLowerCase()
                .contains(query),
      )
      .where(
        (alert) =>
            _readFilter == 'all' ||
            (_readFilter == 'unread'
                ? alert.readAt == null
                : alert.readAt != null),
      )
      .toList();

  return Theme(
    data: AppTheme.lightTheme,
    child: Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Container(
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
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MainPage(),
                                ),
                              );
                            }
                          },
                          child: Text(context.tr('Back')),
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: context.tr('Refresh'),
                          onPressed: _loading ? null : () => _load(),
                          icon: const Icon(Icons.refresh),
                        ),
                      ],
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
                      context.tr('Disease Watch'),
                      style: TextStyle(
                        color: AppTheme.navy,
                        fontSize: Responsive.isLandscapePhone(context)
                            ? 19
                            : 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      context.tr('Track outbreaks and alerts'),
                      style: const TextStyle(
                        color: AppTheme.navy,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: contentMargin,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppTheme.border),
                borderRadius: BorderRadius.circular(14),
              ),
              child: RefreshIndicator(
                onRefresh: () => _load(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    Text(
                      context.tr('Health Alerts'),
                      style: const TextStyle(
                        color: AppTheme.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                      style: TextStyle(color: colors.onSurface),
                      decoration: InputDecoration(
                        hintText: context.tr('Search alerts'),
                        hintStyle: TextStyle(
                          color: colors.onSurfaceVariant,
                        ),
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: AppTheme.surfaceSoft,
                        suffixIcon: query.isEmpty
                            ? null
                            : IconButton(
                                tooltip: context.tr('Clear'),
                                onPressed: () {
                                  setState(() => _search.clear());
                                },
                                icon: const Icon(Icons.close),
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<String>(
                        expandedInsets: EdgeInsets.zero,
                        showSelectedIcon: false,
                        segments: [
                          ButtonSegment<String>(
                            value: 'all',
                            label: Text(context.tr('All alerts')),
                          ),
                          ButtonSegment<String>(
                            value: 'unread',
                            label: Text(context.tr('Unread')),
                          ),
                          ButtonSegment<String>(
                            value: 'read',
                            label: Text(context.tr('Read')),
                          ),
                        ],
                        selected: {_readFilter},
                        onSelectionChanged: (selection) {
                          setState(() {
                            _readFilter = selection.single;
                          });
                        },
                        style: SegmentedButton.styleFrom(
                          backgroundColor: const Color(0xFFEEF2F7),
                          selectedBackgroundColor: Colors.white,
                          selectedForegroundColor: AppTheme.primary,
                          foregroundColor: AppTheme.mutedText,
                          side: const BorderSide(color: AppTheme.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_opening) const LinearProgressIndicator(),
                    if (_loading && _alerts.isEmpty)
                      Semantics(
                        label: context.tr('Loading...'),
                        child: Column(
                          children: List.generate(
                            3,
                            (_) => Container(
                              height: 108,
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceSoft,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppTheme.border,
                                ),
                              ),
                              child: const Center(
                                child: LinearProgressIndicator(),
                              ),
                            ),
                          ),
                        ),
                      )
                    else if (_error == null && visible.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        child: Text(
                          context.tr(
                            query.isEmpty && _readFilter == 'all'
                                ? 'No recent alerts right now.'
                                : 'No matching alerts.',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    for (final alert in visible)
                      DiseaseAlertCard(
                        alert: alert,
                        onOpen: _opening ? null : () => _open(alert),
                      ),
                    if (_error != null) ...[
                      Text(
                        context.tr(_error!),
                        style: TextStyle(color: colors.error),
                        textAlign: TextAlign.center,
                      ),
                      TextButton.icon(
                        onPressed: _loading
                            ? null
                            : () => _load(
                                more: _alerts.isNotEmpty,
                              ),
                        icon: const Icon(Icons.refresh),
                        label: Text(context.tr('Retry')),
                      ),
                    ],
                    if (_cursor != null && _error == null)
                      TextButton(
                        onPressed: _loading
                            ? null
                            : () => _load(more: true),
                        child: Text(
                          context.tr(
                            _loading ? 'Loading...' : 'Load more',
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
