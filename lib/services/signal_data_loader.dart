import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';

typedef Phase = Map<String, dynamic>;

typedef OnTapCallback = void Function({
required double lat,
required double lng,
required List<Phase> phases,
required int pattern,
required Map signal,
});

typedef OnDragEndCallback = void Function({
required String city,
required Map signal,
required LatLng newPosition,
});

Future<List<Marker>> loadSignalData({
  required String cityName,
  required String selectedType,
  required OnTapCallback onTap,
  required OnDragEndCallback onDragEnd,
}) async {
  final jsonString = await rootBundle.loadString('assets/$cityName.json');
  final data = json.decode(jsonString);
  final List signals = data is List ? data : data['signals'] ?? [];

  final Set<Marker> newMarkers = {};

  for (final signal in signals) {
    final lat = signal['lat'];
    final lng = signal['lng'];
    final pattern = signal['신호등화방식'] ?? 99;
    final durationRaw = signal['신호등화시간'];

    List<int> durations;
    if (durationRaw is String) {
      durations = durationRaw.split('+').map((e) => int.tryParse(e) ?? 0).toList();
    } else if (durationRaw is List) {
      durations = durationRaw.map((e) => e is int ? e : int.tryParse('$e') ?? 0).toList();
    } else {
      durations = [30, 30, 5];
    }

    if (durations.fold(0, (a, b) => a + b) == 0) {
      durations = [30, 30, 5];
    }

    final phases = generatePhases(pattern, durations);
    final markerId = MarkerId('${lat}_${lng}');

    final marker = Marker(
      markerId: markerId,
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(
        title: '신호등 (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})',
      ),
      onTap: () {
        onTap(
          lat: lat,
          lng: lng,
          phases: phases,
          pattern: pattern,
          signal: signal,
        );
      },
      draggable: true,
      onDragEnd: (newPosition) {
        onDragEnd(
          city: cityName,
          signal: signal,
          newPosition: newPosition,
        );
      },
    );

    newMarkers.add(marker);
  }

  return newMarkers.toList();
}

List<Phase> generatePhases(int method, List<int> d) {
  while (d.length < 5) d.add(0);

  switch (method) {
    case 1:
    case 6:
      return [
        {"type": "적색", "duration": d[0]},
        {"type": "녹색", "duration": d[1]},
        {"type": "황색", "duration": d[2]},
      ];
    case 2:
      return [
        {"type": "녹색", "duration": d[0]},
        {"type": "황색", "duration": d[1]},
        {"type": "적색", "duration": d[2]},
      ];
    case 3:
      return [
        {"type": "녹색", "duration": d[0]},
        {"type": "황색", "duration": d[1]},
        {"type": "적색", "duration": d[2]},
        {"type": "적색", "duration": d[3]},
      ];
    case 4:
      return [
        {"type": "녹색+황색+녹색화살", "duration": d[0]},
        {"type": "적색+황색", "duration": d[1]},
        {"type": "적색+적색", "duration": d[2]},
      ];
    case 5:
      return [
        {"type": "녹색", "duration": d[0]},
        {"type": "황색", "duration": d[1]},
        {"type": "녹색화살", "duration": d[2]},
        {"type": "황색", "duration": d[3]},
        {"type": "적색", "duration": d[4]},
      ];
    default:
      return [
        {"type": "적색", "duration": 30},
        {"type": "녹색", "duration": 30},
        {"type": "황색", "duration": 5},
      ];
  }
}