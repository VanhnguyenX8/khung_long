import 'package:flutter/widgets.dart';

abstract class GameObject {
  Widget render();
  Rect getRect(Size screenSize, double runDistance);
  void update(Duration lastUpdate, Duration elapsedTime) {}
}
// ?????
// getRect: vi tri con nay se o tren khung ve
// update: thong bao cho cac doi tuong thoi gian da troi qua ???
