part of '../aveomaps.dart';

Future<List> getJson(String json) async {
  List data = jsonDecode(json);
  data.isEmpty ? AssertionError('Invalid json') : null;
  return data;
}

Future<List<AveoMarker>> parsePositionData(String json) async {
  List<AveoMarker> temp = [];
  List data = await getJson(json);
  try {
    for (var element in data) {
      temp.add(
        AveoMarker(
          position: LatLng(
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

  return temp;
}
