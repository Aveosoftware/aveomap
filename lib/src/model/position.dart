part of '../../aveomap.dart';

class MarkerPosition {
  /// The latitude in degrees between -90.0 and 90.0, both inclusive.
  final double latitude;

  /// The longitude in degrees between -180.0 (inclusive) and 180.0 (exclusive).
  final double longitude;

  MarkerPosition(this.latitude, this.longitude);
}
