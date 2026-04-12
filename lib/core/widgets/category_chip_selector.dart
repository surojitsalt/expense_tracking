import 'package:flutter/material.dart';

class CategoryChipSelector extends StatelessWidget {
  final List<String> defaultCategories;
  final List<String> customCategories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback onAddCustomCategory;
  final Color selectedColor;

  const CategoryChipSelector({
    super.key,
    required this.defaultCategories,
    required this.customCategories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onAddCustomCategory,
    required this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final allCategories = [...defaultCategories, ...customCategories];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...allCategories.map(
            (category) => Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(category),
                selected: selectedCategory == category,
                selectedColor: selectedColor.withAlpha(150),
                onSelected: (selected) {
                  if (selected) {
                    onCategorySelected(category);
                  }
                },
              ),
            ),
          ),
          ActionChip(
            label: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 16),
                SizedBox(width: 4),
                Text('Add Custom'),
              ],
            ),
            onPressed: onAddCustomCategory,
          ),
        ],
      ),
    );
  }
}
