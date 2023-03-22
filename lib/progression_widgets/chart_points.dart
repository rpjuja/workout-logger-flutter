import 'package:collection/collection.dart';

class ChartPoints {
  final int x;
  final double y;
  ChartPoints({required this.x, required this.y});
}

List<ChartPoints> get chartPoints {
  final data = <int>[2, 4, 6, 8];
  return data
      .mapIndexed(
          (index, element) => ChartPoints(x: index + 1, y: element.toDouble()))
      .toList();
}
