import 'package:flutter/material.dart';

class MoodSelector extends StatelessWidget {
  const MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  final String? selectedMood;
  final ValueChanged<String> onMoodSelected;

  @override
  Widget build(BuildContext context) {
    const moods = <String>['1', '2', '3', '4', '5'];

    // Future mood labels/icons can be mapped to each numeric mood value.
    return Wrap(
      spacing: 8,
      children: moods.map((mood) {
        final isSelected = selectedMood == mood;
        return ChoiceChip(
          label: Text(mood),
          selected: isSelected,
          onSelected: (_) => onMoodSelected(mood),
        );
      }).toList(),
    );
  }
}
