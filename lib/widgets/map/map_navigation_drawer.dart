import 'package:flutter/material.dart';

import '../../localization/app_translations.dart';
import '../../theme/responsive.dart';

const Color _navy = Color(0xFF243B8F);
const Color _deepBlue = Color(0xFF31459B);
const Color _lightPurple = Color(0xFFDDE6FF);

class MapNavigationDrawer extends StatelessWidget {
  final VoidCallback onHome;
  final VoidCallback onMap;
  final VoidCallback onDiseaseWatch;
  final VoidCallback onHealthLiteracy;
  final VoidCallback onSentimentPulse;
  final VoidCallback onDataCollection;
  final VoidCallback onProfile;

  const MapNavigationDrawer({
    super.key,
    required this.onHome,
    required this.onMap,
    required this.onDiseaseWatch,
    required this.onHealthLiteracy,
    required this.onSentimentPulse,
    required this.onDataCollection,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    final isLandscapePhone = Responsive.isLandscapePhone(context);

    return Drawer(
      width: isLandscapePhone ? 320 : null,
      backgroundColor: Colors.white,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                18,
                isLandscapePhone ? 10 : 14,
                18,
                isLandscapePhone ? 10 : 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/healthphplusbarlogo.png',
                    height: isLandscapePhone ? 36 : 50,
                  ),
                  SizedBox(height: isLandscapePhone ? 6 : 10),
                  Text(
                    context.tr('Disease Map'),
                    style: TextStyle(
                      color: _navy,
                      fontSize: isLandscapePhone ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    context.tr('Respiratory outbreak monitoring'),
                    style: TextStyle(
                      color: _deepBlue,
                      fontSize: isLandscapePhone ? 11 : 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            _MapDrawerNavTile(icon: Icons.home, label: 'Home', onTap: onHome),
            _MapDrawerNavTile(
              icon: Icons.map,
              label: 'Disease Map',
              isSelected: true,
              onTap: onMap,
            ),
            _MapDrawerNavTile(
              icon: Icons.coronavirus,
              label: 'Disease Watch',
              onTap: onDiseaseWatch,
            ),
            _MapDrawerNavTile(
              icon: Icons.article_outlined,
              label: 'Health Literacy',
              onTap: onHealthLiteracy,
            ),
            _MapDrawerNavTile(
              icon: Icons.analytics,
              label: 'Sentiment Pulse',
              onTap: onSentimentPulse,
            ),
            _MapDrawerNavTile(
              icon: Icons.assignment,
              label: 'Data Collection',
              onTap: onDataCollection,
            ),
            const Divider(height: 1),
            _MapDrawerNavTile(
              icon: Icons.person_outline,
              label: 'Profile',
              onTap: onProfile,
            ),
            SizedBox(height: isLandscapePhone ? 6 : 8),
          ],
        ),
      ),
    );
  }
}

class _MapDrawerNavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  const _MapDrawerNavTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final isLandscapePhone = Responsive.isLandscapePhone(context);

    return ListTile(
      dense: isLandscapePhone,
      visualDensity: isLandscapePhone
          ? const VisualDensity(horizontal: -2, vertical: -3)
          : VisualDensity.standard,
      minLeadingWidth: isLandscapePhone ? 28 : null,
      selected: isSelected,
      selectedTileColor: _lightPurple,
      leading: Icon(
        icon,
        size: isLandscapePhone ? 22 : 24,
        color: isSelected ? _deepBlue : Colors.black54,
      ),
      title: Text(
        context.tr(label),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isSelected ? _navy : const Color(0xFF1D2450),
          fontSize: isLandscapePhone ? 14 : 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }
}
