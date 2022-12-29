part of '../../aveomap.dart';

class AveoMarker {
  /// position is [LatLng] of marker's location
  MarkerPosition position;

  /// if you don't want default red pin marker than you can provide your custom MarkerIcon with ImageUrl
  String markerIconImage;

  /// for using asset image as markerIcon you need to get Uint8List.
  ///  which you can get by AveoMapUtils().getBytesFromAsset()
  Future<Uint8List>? assetIconFuture;

  /// This will be the title  of infowindow to be shown when user taps on a marker.
  String infoTitle;

  /// This will be SubTitle of infowindow to be shown when user taps on a marker.
  String infoSubTitle;

  /// This will be leading Widget of infowindow to be shown when user taps on a marker.
  Widget? infoLeadingWidget;

  /// This will be traling Widget of infowindow to be shown when user taps on a marker.
  Widget? infoTralingWidget;

  AveoMarker(
      {required this.position,
      this.markerIconImage = '',
      this.infoLeadingWidget,
      this.infoTralingWidget,
      this.infoSubTitle = '',
      this.infoTitle = '',
      this.assetIconFuture});
}
