part of '../../aveomap.dart';

class AveoMap extends StatefulWidget {
  /// [markerList] is list of AveoMaker.
  final List<AveoMarker>? markerList;

  /// [markerListJson] is json consisting data to be shown in [AveoMarker], it should be formated stricly as below example.
  ///
  /// [
  /// {
  ///
  ///   "lat": "latitude",
  ///
  ///   "long": "longitude",
  ///
  ///   "img": "Marker icon",
  ///
  ///   "title":"Title of infowindow",
  ///
  ///   "sub_title":"subTitle of infoWindow",
  ///
  ///   "leading":"leading image url of infoWindow",
  ///
  ///   "traling":"traling image url of infoWindow"
  ///
  ///   },
  /// ...
  ///
  /// ]
  final String? markerListJson;

  /// This function will be called onTap of infoWindow and will return Tapped marker.
  final Function(AveoMarker)? infoTap;

  /// The zoom level of the camera.
  ///
  /// A zoom of 0.0, the default, means the screen width of the world is 256.
  /// Adding 1.0 to the zoom level doubles the screen width of the map. So at
  /// zoom level 3.0, the screen width of the world is 2³x256=2048.
  ///
  /// Larger zoom levels thus means the camera is placed closer to the surface
  /// of the Earth, revealing more detail in a narrower geographical region.
  ///
  /// The supported zoom level range depends on the map data and device. Values
  /// beyond the supported range are allowed, but on applying them to a map they
  /// will be silently clamped to the supported range.
  final double zoom;

  /// AveoMap feature requires adding location permissions to both native
  /// platforms of your app.
  /// * On Android add either
  /// `<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />`
  /// or `<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />`
  /// to your `AndroidManifest.xml` file. `ACCESS_COARSE_LOCATION` returns a
  /// location with an accuracy approximately equivalent to a city block, while
  /// `ACCESS_FINE_LOCATION` returns as precise a location as possible, although
  /// it consumes more battery power. You will also need to request these
  /// permissions during run-time. If they are not granted, the My Location
  /// feature will fail silently.
  /// * On iOS add a `NSLocationWhenInUseUsageDescription` key to your
  /// `Info.plist` file. This will automatically prompt the user for permissions
  /// when the map tries to turn on the My Location layer.

  /// Aveo map will return googleMap with markers placed on it.
  /// You need to provide either [markerList] or [markerListJson].
  /// both [markerList] and [markerListJson] can not be null and if both are provided then [markerList] will be shown.

  /// Enables or disables the my-location button.
  ///
  /// The my-location button causes the camera to move such that the user's
  /// location is in the center of the map. If the button is enabled, it is
  /// only shown when the my-location layer is enabled.
  ///
  /// By default, the my-location button is enabled (and hence shown when the
  /// my-location layer is enabled).
  ///
  /// See also:
  ///   * [myLocationEnabled] parameter.
  final bool myLocationButtonEnabled;

  /// True if a "My Location" layer should be shown on the map.
  ///
  /// This layer includes a location indicator at the current device location,
  /// as well as a My Location button.
  /// * The indicator is a small blue dot if the device is stationary, or a
  /// chevron if the device is moving.
  /// * The My Location button animates to focus on the user's current location
  final bool myLocationEnabled;

  ///True if the map should show a toolbar when you interact with the map. Android only.
  final bool mapToolbarEnable;

  ///Type of map tiles to be rendered.
  MapType mapType;

  ///To change intial camera postion default it is set to user's current location.
  CameraPosition? initialCameraPosition;

  ///textStyle for infoWidget texts.
  TextStyle? infoTextStyle;

  ///backround color of info Container.
  BoxDecoration? infoDecoration;

  ///google maps api key is required for using this package.
  ///For Android :
  ///
  ///Navigate to the file android/app/src/main/AndroidManifest.xml and add the following code snippet inside the application tag:
  ///
  ///<meta-data android:name="com.google.android.geo.API_KEY"
  ///             android:value="YOUR KEY HERE"/>
  ///
  ///For IOS :
  ///Navigate to the file ios/Runner/AppDelegate.swift and Add the following:
  ///
  ///GMSServices.provideAPIKey("YOUR KEY HERE")
  AveoMap({
    Key? key,
    this.infoTextStyle,
    this.initialCameraPosition,
    this.markerList,
    this.infoDecoration,
    this.markerListJson,
    this.mapType = MapType.normal,
    this.mapToolbarEnable = true,
    this.infoTap,
    this.zoom = 0.0,
    this.myLocationButtonEnabled = true,
    this.myLocationEnabled = false,
  });

  @override
  State<AveoMap> createState() => _AveoMapState();
}

class _AveoMapState extends State<AveoMap> {
  @override
  void initState() {
    if ((widget.markerList == null && widget.markerListJson == null)) {
      throw AssertionError(
          'both markerList and markerListJson can not be null');
    }

    widget.markerList != null
        ? controller.addMarker(
            infoDecoration: widget.infoDecoration,
            infoTextStyle: widget.infoTextStyle,
            aveoMarkerList: widget.markerList,
            infoTap: widget.infoTap)
        : controller.addMarker(
            json: widget.markerListJson!, infoTap: widget.infoTap);
    super.initState();
  }

  MapController controller = Get.put(MapController());
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: controller.locationPermission(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.data != null) {
            bool permission = snapshot.data!;
            if (permission) {
              return Container(
                  child: FutureBuilder<LatLng>(
                      future: controller.getUserLocation(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return GetBuilder<MapController>(
                            builder: (controller) {
                              return Stack(
                                children: [
                                  GoogleMap(
                                      mapToolbarEnabled:
                                          widget.mapToolbarEnable,
                                      mapType: widget.mapType,
                                      onTap: (argument) {
                                        controller.markerTapped.value = false;
                                        controller.customInfoWindowController
                                            .hideInfoWindow!();
                                      },
                                      onMapCreated: (googleController) {
                                        controller.customInfoWindowController
                                                .googleMapController =
                                            googleController;
                                      },
                                      onCameraMove: (position) {
                                        controller.customInfoWindowController
                                            .onCameraMove!();
                                      },
                                      myLocationEnabled:
                                          widget.myLocationEnabled,
                                      markers: controller.markers,
                                      myLocationButtonEnabled:
                                          widget.myLocationButtonEnabled,
                                      initialCameraPosition:
                                          widget.initialCameraPosition ??
                                              CameraPosition(
                                                  target: snapshot.data!,
                                                  zoom: widget.zoom)),
                                  Visibility(
                                    visible: Platform.isIOS &&
                                        controller.markerTapped.value &&
                                        widget.mapToolbarEnable,
                                    child: Positioned(
                                      bottom: 20,
                                      right: 65,
                                      child: GestureDetector(
                                        onTap: () {
                                          mapLaunch.MapLauncher.showDirections(
                                              mapType: mapLaunch.MapType.apple,
                                              destination: mapLaunch.Coords(
                                                  controller.markerPosition
                                                      .value.latitude,
                                                  controller.markerPosition
                                                      .value.longitude));
                                        },
                                        child: Row(
                                          children: [
                                            Container(
                                              height: 38,
                                              width: 38,
                                              color: Colors.white70,
                                              child: const Icon(
                                                Icons.directions,
                                                color: Colors.blue,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 1,
                                              // child: Con,
                                            ),
                                            Container(
                                                height: 38,
                                                width: 38,
                                                color: Colors.white70,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 8),
                                                child: Image.asset(
                                                  'assets/icons/apple_map.png',
                                                  // scale: 0.5,
                                                )),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  CustomInfoWindow(
                                    controller:
                                        controller.customInfoWindowController,
                                    height: 82,
                                    width: 300,
                                    offset: 50,
                                  )
                                ],
                              );
                            },
                          );
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      }));
            } else {
              return Center(
                child: Text('Location permission is required'),
              );
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}
