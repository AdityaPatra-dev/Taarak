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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(8),
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Search shelters, incidents, hazards',
              prefixIcon: Icon(Icons.search),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onChanged: _onChanged,
          ),
        ),
        if (_results.isNotEmpty)
          Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final result in _results)
                    ListTile(
                      dense: true,
                      title: Text(result.label),
                      onTap: () => _select(result),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
