part of '../../aveomap.dart';

class MapController extends GetxController {
  final markers = <Marker>{};
  RxBool markerTapped = false.obs;
  Rx<LatLng> markerPosition = LatLng(0, 0).obs;
  CustomInfoWindowController customInfoWindowController =
      CustomInfoWindowController();

  Future<bool> locationPermission() async {
    LocationPermission permission =
        await GeolocatorPlatform.instance.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return Future.value(true);
    } else {
      LocationPermission permission =
          await GeolocatorPlatform.instance.requestPermission();
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        return Future.value(true);
      }

      return Future.value(false);
    }
  }

  Future<LatLng> getUserLocation() async {
    var position = await GeolocatorPlatform.instance.getCurrentPosition();
    update();

    return Future.value(LatLng(position.latitude, position.longitude));
  }

  //for converting image url to byte which is required for custom marker icon
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
      double? infoHeight,
      double? infoWidth,
      required bool showInfowindow,
      List<AveoMarker>? aveoMarkerList,
      Function(AveoMarker)? infoTap,
      Function(AveoMarker)? markerTap,
      BoxDecoration? infoDecoration,
      TextStyle? infoTextStyle}) async {
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
      markers.add(
        Marker(
          icon: element.markerIconImage.isNotEmpty
              ? BitmapDescriptor.fromBytes(
                  markerIcon!,
                )
              : BitmapDescriptor.defaultMarker,
          draggable: false,
          infoWindow: kIsWeb
              ? const InfoWindow(
                  title: 'Test marker', snippet: 'This is test marker')
              : InfoWindow.noText,
          onDragStart: (_) => markers.clear(),
          onTap: showInfowindow
              ? () {
                  if (kIsWeb) {
                    null;
                  } else {
                    markerTapped.value = true;
                    markerPosition.value = LatLng(
                        element.position.latitude, element.position.longitude);
                    customInfoWindowController.addInfoWindow!(
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: infoDecoration ??
                                BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                            width: infoWidth ?? double.infinity,
                            height: infoHeight != null ? infoHeight - 12 : 70,
                            child: Center(
                              child: ListTile(
                                horizontalTitleGap: 8,
                                isThreeLine: true,
                                onTap: () => infoTap?.call(element),
                                leading: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                        maxWidth: 45,
                                        maxHeight: 45,
                                        minHeight: 45),
                                    child: Center(
                                        child: element.infoLeadingWidget)),
                                title: Text(
                                  element.infoTitle,
                                  style: infoTextStyle,
                                ),
                                subtitle: Text(
                                  element.infoSubTitle,
                                  style: infoTextStyle,
                                ),
                                trailing: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                        maxWidth: 45, maxHeight: 45),
                                    child: Center(
                                        child: element.infoTralingWidget)),
                              ),
                            ),
                          ),
                          ClipPath(
                            clipper: TriangleClipper(),
                            child: Container(
                              color: infoDecoration?.color ??
                                  infoDecoration?.gradient?.colors.first ??
                                  Colors.white,
                              height: 12,
                              width: 24,
                            ),
                          )
                        ],
                      ),
                      LatLng(element.position.latitude,
                          element.position.longitude),
                    );
                  }
                }
              : () => markerTap?.call(element),
          markerId: MarkerId(element.position.latitude.toString() +
              element.position.longitude.toString()),
          position:
              LatLng(element.position.latitude, element.position.longitude),
        ),
      );
    }

    update();
  }
}
