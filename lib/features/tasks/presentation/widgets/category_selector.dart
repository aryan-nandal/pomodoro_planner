import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';

class CategorySelector extends StatelessWidget {
  final Category? selectedCategory;
  final ValueChanged<Category?> onCategorySelected;

  static const List<Category> defaultCategories = [
    Category(id: 'work', name: 'Work', colorHex: 0xFF6366F1, iconName: 'work_outline'),
    Category(id: 'study', name: 'Study', colorHex: 0xFFF59E0B, iconName: 'school_outlined'),
    Category(id: 'health', name: 'Health', colorHex: 0xFF10B981, iconName: 'favorite_border'),
    Category(id: 'personal', name: 'Personal', colorHex: 0xFFEC4899, iconName: 'person_outline'),
    Category(id: 'routine', name: 'Routine', colorHex: 0xFF6B7280, iconName: 'repeat'),
  ];

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  IconData _getIconData(String name) {
    switch (name) {
      case 'work_outline':
        return Icons.work_outline;
      case 'school_outlined':
        return Icons.school_outlined;
      case 'favorite_border':
        return Icons.favorite_border;
      case 'person_outline':
        return Icons.person_outline;
      case 'repeat':
        return Icons.repeat;
      default:
        return Icons.label_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: defaultCategories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = defaultCategories[index];
              final isSelected = selectedCategory?.id == cat.id;

              return ChoiceChip(
                showCheckmark: false,
                avatar: Icon(
                  _getIconData(cat.iconName),
                  size: 16,
                  color: isSelected ? Colors.black : Color(cat.colorHex),
                ),
                label: Text(
                  cat.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.black : Colors.white70,
                  ),
                ),
                selected: isSelected,
                selectedColor: Colors.white,
                backgroundColor: Theme.of(context).cardColor,
                side: BorderSide(
                  color: isSelected ? Colors.white : Theme.of(context).dividerColor,
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (selected) {
                  onCategorySelected(selected ? cat : null);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
