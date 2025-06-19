import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<void> saveSignalToLocal({
  required String city,
  required Map signal,
  required LatLng newPosition,
}) async {
  final fileName = '${city}_${DateTime.now().millisecondsSinceEpoch}.json';
  final directory = await getApplicationDocumentsDirectory();
  final path = '${directory.path}/$fileName';

  final updatedSignal = {
    ...signal,
    'lat': newPosition.latitude,
    'lng': newPosition.longitude,
  };

  final file = File(path);
  await file.writeAsString(json.encode(updatedSignal));
  print('✅ 로컬에 저장됨: $fileName');
}