import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';

/// M05's offline cache strategy for the base map: tiles fetched once are
/// written to disk (via `cached_network_image`/`flutter_cache_manager`) and
/// served from there on later loads, so a previously-viewed area still
/// renders with no connectivity. An area that's never been viewed still
/// needs a network hit the first time — pre-fetching a whole region ahead
/// of time is a further step, not built here.
class CachingTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return CachedNetworkImageProvider(
      getTileUrl(coordinates, options),
      headers: headers,
    );
  }
}
