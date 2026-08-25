import 'package:flutter/material.dart';
import 'package:taarak/features/map/application/map_search.dart';
import 'package:taarak/features/map/domain/map_search_result.dart';

class MapSearchBar extends StatefulWidget {
  final List<MapSearchResult> index;
  final ValueChanged<MapSearchResult> onSelect;

  const MapSearchBar({super.key, required this.index, required this.onSelect});

  @override
  State<MapSearchBar> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends State<MapSearchBar> {
  final _controller = TextEditingController();
  List<MapSearchResult> _results = const [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() => _results = filterSearchIndex(widget.index, value));
  }

  void _select(MapSearchResult result) {
    widget.onSelect(result);
    _controller.clear();
    setState(() => _results = const []);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          elevation: 3,
          shadowColor: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(14),
          color: scheme.surface,
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Search shelters, incidents, hazards',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        _controller.clear();
                        setState(() => _results = const []);
                      },
                    ),
              filled: true,
              fillColor: scheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            onChanged: _onChanged,
          ),
        ),
        if (_results.isNotEmpty) ...[
          const SizedBox(height: 6),
          Material(
            elevation: 3,
            shadowColor: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(14),
            color: scheme.surface,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                children: [
                  for (final result in _results)
                    ListTile(
                      dense: true,
                      leading: Icon(
                        Icons.place_outlined,
                        size: 18,
                        color: scheme.primary,
                      ),
                      title: Text(result.label),
                      onTap: () => _select(result),
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
