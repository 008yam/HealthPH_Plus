import 'package:flutter/material.dart';
import '../localization/app_translations.dart';
import '../models/mobile_alert.dart';
import '../services/api_config.dart';
import '../services/mobile_alert_service.dart';
import '../services/profile_store.dart';
import '../theme/responsive.dart';

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
        builder: (dialogContext) => AlertDialog(
          title: Text(detail.title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.regionName.isEmpty ? detail.region : detail.regionName,
                ),
                const SizedBox(height: 12),
                Text(
                  detail.message.isEmpty
                      ? context.tr('No additional alert details were provided.')
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
    final colors = Theme.of(context).colorScheme;
    final query = _search.text.trim().toLowerCase();
    final visible = _alerts
        .where(
          (a) => '${a.title} ${a.regionName} ${a.region} ${a.message}'
              .toLowerCase()
              .contains(query),
        )
        .toList();
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
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
              style: Theme.of(context).textTheme.titleLarge,
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
                fillColor: colors.surfaceContainerHighest,
                border: const OutlineInputBorder(),
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
                    query.isEmpty
                        ? 'No recent alerts right now.'
                        : 'No matching alerts.',
                  ),
                ),
              ),
            for (final alert in visible)
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: colors.outlineVariant),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: _opening ? null : () => _open(alert),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              alert.readAt == null
                                  ? Icons.notifications_active_outlined
                                  : Icons.notifications_none,
                              color: colors.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                alert.title,
                                style: TextStyle(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: colors.onSurfaceVariant,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          alert.regionName.isEmpty
                              ? alert.region
                              : alert.regionName,
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                        if (alert.message.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            alert.message,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: colors.onSurface),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          context.tr(
                            '{reports} reports',
                            parameters: {'reports': alert.reportCount},
                          ),
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (_error != null) ...[
              Text(context.tr(_error!), style: TextStyle(color: colors.error)),
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
                child: Text(context.tr(_loading ? 'Loading...' : 'Load more')),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
