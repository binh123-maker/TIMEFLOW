import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stream provider for live digital clock update (remains accurate to second)
final liveClockProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
});
