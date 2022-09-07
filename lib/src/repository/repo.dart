part of '../../aveomap.dart';

Future<List> decodeJson(String json) async {
  List data = jsonDecode(json);
  data.isEmpty ? AssertionError('Invalid json') : null;
  return data;
}

///this will convert json data to the List of AveoMarkers
Future<List<AveoMarker>> parsePositionData(String json) async {
  List<AveoMarker> markerList = [];
  List data = await decodeJson(json);
  try {
    for (var element in data) {
      markerList.add(
        AveoMarker(
          position: MarkerPosition(
              double.parse(element['lat']), double.parse(element['long'])),
          markerIconImage: element['img'],
          infoTitle: element['title'],
          infoSubTitle: element['sub_title'],
          infoLeadingWidget: CachedNetworkImage(
            imageUrl: element['leading'],
            errorWidget: (ctx, _, __) {
              return const SizedBox();
            },
          ),
          infoTralingWidget: CachedNetworkImage(
            imageUrl: element['traling'],
            errorWidget: (ctx, _, __) {
              return const SizedBox();
            },
          ),
        ),
      );
    }
  } catch (e) {
    throw AssertionError('Invalid json');
  }

  return markerList;
}
