enum MuscleGroup {
  none,
  abs,
  back,
  biceps,
  calves,
  chest,
  forearms,
  hamstrings,
  glutes,
  quads,
  shoulders,
  triceps,
}

// Extension to capitalize the first letter, used for muscle group names
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
