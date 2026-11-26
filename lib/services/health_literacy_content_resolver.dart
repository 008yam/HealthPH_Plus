class HealthLiteracyContentResolver {
  final String baseUrl;

  const HealthLiteracyContentResolver({required this.baseUrl});

  String joinList(dynamic value) {
    if (value is List) return value.join(' ');
    return '';
  }

  String mediaUrl(Map<String, dynamic> item) {
    final media = item['media'];
    final nestedUrl = media is Map ? media['url'] : null;
    final resolvedNestedUrl = _resolveUrl(nestedUrl);

    return resolvedNestedUrl.isNotEmpty
        ? resolvedNestedUrl
        : _resolveUrl(item['mediaUrl']);
  }

  String imageUrl(Map<String, dynamic> item) {
    final directImageUrl = _resolveUrl(item['imageUrl']);
    if (directImageUrl.isNotEmpty) return directImageUrl;

    final media = item['media'];
    final mediaType = media is Map
        ? (media['contentType'] ?? '').toString().toLowerCase()
        : '';

    return mediaType.startsWith('image/')
        ? _resolveUrl(media is Map ? media['url'] : null)
        : '';
  }

  String thumbnailUrl(Map<String, dynamic> item) {
    final primaryImageUrl = imageUrl(item);
    if (primaryImageUrl.isNotEmpty) return primaryImageUrl;

    final galleryImages = item['galleryImages'];
    if (galleryImages is! List) return '';

    for (final galleryItem in galleryImages) {
      if (galleryItem is! Map) continue;

      final galleryMedia = galleryItem['media'];
      if (galleryMedia is! Map) continue;

      final contentType = (galleryMedia['contentType'] ?? '')
          .toString()
          .toLowerCase();

      if (!contentType.startsWith('image/')) continue;

      final galleryImageUrl = _resolveUrl(galleryMedia['url']);
      if (galleryImageUrl.isNotEmpty) return galleryImageUrl;
    }

    return '';
  }

  String mediaContentType(Map<String, dynamic> item) {
    final media = item['media'];

    return media is Map
        ? (media['contentType'] ?? '').toString().toLowerCase()
        : '';
  }

  String openUrl(Map<String, dynamic> item) {
    final externalUrl = (item['externalUrl'] ?? '').toString();

    if (externalUrl.isNotEmpty && externalUrl != 'null') {
      return externalUrl;
    }

    final resolvedMediaUrl = mediaUrl(item);
    if (resolvedMediaUrl.isNotEmpty) return resolvedMediaUrl;

    return imageUrl(item);
  }

  String _resolveUrl(dynamic rawValue) {
    final value = rawValue?.toString().trim() ?? '';

    if (value.isEmpty || value == 'null') return '';

    if (value.startsWith('/')) {
      return '$baseUrl$value';
    }

    return value;
  }
}
