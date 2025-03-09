import 'package:flutter/material.dart';

import '../../theme/theme.dart';

///
///  The Search bar combines the search input + the navigation back button
///  A clear button appears when search contains some text.
///
class BlaSearchBar extends StatefulWidget {
  const BlaSearchBar(
      {super.key, required this.onSearchChanged, required this.onBackPressed});

  final Function(String text) onSearchChanged;
  final VoidCallback onBackPressed;

  @override
  State<BlaSearchBar> createState() => _BlaSearchBarState();
}

class _BlaSearchBarState extends State<BlaSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool get searchIsNotEmpty => _controller.text.isNotEmpty;

  void onChanged(String newText) {
    // 1 - Notity the listener
    widget.onSearchChanged(newText);

    // 2 - Update the cross icon
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: BlaColors.backgroundAccent,
          borderRadius:
          BorderRadius.circular(BlaSpacings.radius), // Rounded corners
        ),
        child: Row(
          children: [
            // Left icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: IconButton(
                onPressed: widget.onBackPressed,
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: BlaColors.iconLight,
                  size: 16,
                ),
              ),
            ),

            Expanded(
              child: TextField(
                focusNode: _focusNode, // Keep focus
                onChanged: onChanged,
                controller: _controller,
                style: TextStyle(color: BlaColors.textLight),
                decoration: InputDecoration(
                  hintText: "Any city, street...",
                  border: InputBorder.none, // No border
                  filled: false, // No background fill
                ),
              ),
            ),

            searchIsNotEmpty // A clear button appears when search contains some text
                ? IconButton(
              icon: Icon(Icons.close, color: BlaColors.iconLight),
              onPressed: () {
                _controller.clear();
                _focusNode.requestFocus(); // Ensure it stays focused
                onChanged("");
              },
            )
                : SizedBox.shrink(), // Hides the icon if text field is empty
          ],
        ),
      ),
    );
  }
}