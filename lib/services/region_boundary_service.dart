import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

class RegionBoundary {
  // Each polygon contains an outer ring followed by any holes.
  final List<List<List<LatLng>>> polygons;

  const RegionBoundary(this.polygons);

  List<LatLng> get outlinePoints => [
    for (final polygon in polygons) ...polygon.first,
  ];
}

class RegionBoundaryService {
  static Future<Map<String, RegionBoundary>>? _cached;

  static Future<Map<String, RegionBoundary>> load() async {
    try {
      return await (_cached ??= _read());
    } catch (_) {
      _cached = null;
      rethrow;
    }
  }

  static Future<Map<String, RegionBoundary>> _read() async {
    const codes = {
      1: 'I', 2: 'II', 3: 'III', 4: 'IVA', 5: 'V',
      6: 'VI', 7: 'VII', 8: 'VIII', 9: 'IX', 10: 'X',
      11: 'XI', 12: 'XII', 13: 'NCR', 14: 'CAR',
      16: 'XIII', 17: 'IVB', 18: 'NIR', 19: 'BARMM',
    };
    final source = await rootBundle.loadString(
      'assets/data/boundaries/ph_regions.geojson',
    );
    final document = jsonDecode(source) as Map<String, dynamic>;
    final result = <String, RegionBoundary>{};
    for (final feature in document['features'] as List) {
      final psgc = (feature['properties']['adm1_psgc'] as num).toInt();
      final code = codes[psgc ~/ 100000000];
      if (code == null) continue;
      final geometry = feature['geometry'];
      final coordinates = geometry['coordinates'] as List;
      final List parts;
      switch (geometry['type']) {
        case 'Polygon':
          parts = [coordinates];
          break;
        case 'MultiPolygon':
          parts = coordinates;
          break;
        default:
          throw const FormatException('Unsupported region geometry');
      }
      result[code] = RegionBoundary([
        for (final polygon in parts)
          [
            for (final ring in polygon)
              [
                for (final point in ring)
                  LatLng(
                    (point[1] as num).toDouble(),
                    (point[0] as num).toDouble(),
                  ),
              ],
          ],
      ]);
    }
    return result;
  }
}