import 'package:flutter/material.dart';
import '../localization/app_translations.dart';
import '../models/mobile_alert.dart';
import '../services/api_config.dart';
import '../services/mobile_alert_service.dart';
import '../services/profile_store.dart';
import '../theme/responsive.dart';
import '../theme/app_theme.dart';
import '../widgets/disease_alert_card.dart';

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
    final visible = _alerts
        .where(
          (a) => '${a.title} ${a.regionName} ${a.region} ${a.message}'
              .toLowerCase()
              .contains(query),
        )
        .where(
          (a) =>
              _readFilter == 'all' ||
              (_readFilter == 'unread' ? a.readAt == null : a.readAt != null),
        )
        .toList();
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          title: Text(context.tr('Disease Watch')),
          actions: [
            IconButton(
              tooltip: context.tr('Refresh'),
              onPressed: _loading ? null : () => _load(),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => _load(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(Responsive.pagePadding(context)),
            children: [
              Text(
                context.tr('Health Alerts'),
                style: const TextStyle(
                  color: AppTheme.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                style: TextStyle(color: colors.onSurface),
                decoration: InputDecoration(
                  hintText: context.tr('Search alerts'),
                  hintStyle: TextStyle(color: colors.onSurfaceVariant),
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: context.tr('Clear'),
                          onPressed: () => setState(() => _search.clear()),
                          icon: const Icon(Icons.close),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SegmentedButton<String>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: 'all',
                      label: Text(context.tr('All alerts')),
                    ),
                    ButtonSegment(
                      value: 'unread',
                      label: Text(context.tr('Unread')),
                    ),
                    ButtonSegment(
                      value: 'read',
                      label: Text(context.tr('Read')),
                    ),
                  ],
                  selected: {_readFilter},
                  onSelectionChanged: (selection) =>
                      setState(() => _readFilter = selection.single),
                  style: SegmentedButton.styleFrom(
                    backgroundColor: const Color(0xFFEEF2F7),
                    selectedBackgroundColor: Colors.white,
                    selectedForegroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.mutedText,
                    side: const BorderSide(color: AppTheme.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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
                          color: colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(child: LinearProgressIndicator()),
                      ),
                    ),
                  ),
                )
              else if (_error == null && visible.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    context.tr(
                      query.isEmpty && _readFilter == 'all'
                          ? 'No recent alerts right now.'
                          : 'No matching alerts.',
                    ),
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
                ),
                TextButton.icon(
                  onPressed: _loading
                      ? null
                      : () => _load(more: _alerts.isNotEmpty),
                  icon: const Icon(Icons.refresh),
                  label: Text(context.tr('Retry')),
                ),
              ],
              if (_cursor != null && _error == null)
                TextButton(
                  onPressed: _loading ? null : () => _load(more: true),
                  child: Text(
                    context.tr(_loading ? 'Loading...' : 'Load more'),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
