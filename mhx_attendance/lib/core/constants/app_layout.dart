import 'package:flutter/material.dart';

/// Khoảng cách nội dung màn hình trong shell / danh sách.
abstract final class AppLayout {
  static const double gutter = 16;
  static const EdgeInsets contentPadding = EdgeInsets.all(gutter);
  static const EdgeInsets listPadding = EdgeInsets.fromLTRB(gutter, 0, gutter, 88);
  static const EdgeInsets messagePadding = EdgeInsets.all(24);
}
