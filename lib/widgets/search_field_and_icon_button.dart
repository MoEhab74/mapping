import 'package:flutter/material.dart';

class SearchFieldAndIconButton extends StatelessWidget {
  const SearchFieldAndIconButton({
    super.key,
    required TextEditingController searchController,
    this.onPressed,
  }) : _searchController = searchController;

  final TextEditingController _searchController;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ).copyWith(bottom: 0, right: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a location',
                fillColor: Colors.white.withAlpha(204),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  borderSide: BorderSide.none,
                ),

                filled: true,
              ),
            ),
          ),
        ),
        // Search button
        Container(
          margin: const EdgeInsets.only(right: 8, top: 8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(204),
            borderRadius: const BorderRadius.all(Radius.circular(24)),
          ),
          child: IconButton(
            icon: const Icon(Icons.search),
            onPressed:
                onPressed ??
                () {
                  // Fetch coordinates for the entered location
                  // if (_searchController.text.isEmpty) {
                  //   return;
                  // }
                  // _fetchCoordinates(_searchController.text);
                },
          ),
        ),
      ],
    );
  }
}
