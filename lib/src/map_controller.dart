part of '../aveomaps.dart';

class MapController extends GetxController {
  final count = 0.obs;
  final markers = <Marker>{};
  RxBool markerTapped = false.obs;
  Rx<LatLng> markerPosition = LatLng(0, 0).obs;
  CustomInfoWindowController customInfoWindowController =
      CustomInfoWindowController();

  Future<LatLng> getUserLocation() async {
    var position = await GeolocatorPlatform.instance.getCurrentPosition();
    update();

    return Future.value(LatLng(position.latitude, position.longitude));
  }

  Future<Uint8List> getBytesFromAsset(ByteData byteData, int width) async {
    ui.Codec codec = await ui.instantiateImageCodec(
        byteData.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  addMarker(
      {String? json,
      List<AveoMarker>? aveoMarkerList,
      Function(AveoMarker)? infoTap}) async {
    List<AveoMarker> aveoMarkers =
        aveoMarkerList ?? await parsePositionData(json!);

    for (var element in aveoMarkers) {
      Uint8List? markerIcon;
      if (element.markerIconImage.isNotEmpty) {
        ByteData imageData =
            await NetworkAssetBundle(Uri.parse(element.markerIconImage))
                .load('');
        markerIcon = await getBytesFromAsset(imageData, 70);
      }
      markers.add(Marker(
          icon: element.markerIconImage.isNotEmpty
              ? BitmapDescriptor.fromBytes(
                  markerIcon!,
                )
              : BitmapDescriptor.defaultMarker,
          draggable: false,
          onDragStart: (_) => markers.clear(),
          onTap: () {
            markerTapped.value = true;
            markerPosition.value =
                LatLng(element.position.latitude, element.position.longitude);
            customInfoWindowController.addInfoWindow!(
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child: ListTile(
                    onTap: () => infoTap?.call(element),
                    leading: ConstrainedBox(
                        constraints: const BoxConstraints(
                            maxWidth: 45, maxHeight: 45, minHeight: 45),
                        child: Center(child: element.infoLeadingWidget)),
                    title: Text(element.infoTitle),
                    subtitle: Text(element.infoSubTitle),
                    trailing: ConstrainedBox(
                        constraints:
                            const BoxConstraints(maxWidth: 45, maxHeight: 45),
                        child: Center(child: element.infoTralingWidget)),
                  ),
                ),
              ),
              element.position,
            );
          },
          markerId: MarkerId(element.position.latitude.toString() +
              element.position.longitude.toString()),
          position: element.position));
    }

    update();
  }
}
