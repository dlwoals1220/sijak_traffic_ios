import 'dart:async';
import 'package:flutter/material.dart';

typedef Phase = Map<String, dynamic>;

void showSignalBottomSheet({
  required BuildContext context,
  required double lat,
  required double lng,
  required List<Phase> phases,
  required int pattern,
}) {
  Timer? timer;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext ctx) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          String currentPhase = '';
          int remaining = 0;

          void updatePhase() {
            final totalCycle = phases.fold(0, (sum, p) => sum + (p['duration'] as int));
            final now = DateTime.now();
            final elapsed = now.difference(DateTime(now.year, now.month, now.day)).inSeconds % totalCycle;

            int acc = 0;
            for (final phase in phases) {
              final d = phase['duration'] as int;
              if (elapsed < acc + d) {
                currentPhase = phase['type'];
                remaining = acc + d - elapsed;
                break;
              }
              acc += d;
            }
          }

          updatePhase();

          timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
            updatePhase();
            setModalState(() {});
          });

          return WillPopScope(
            onWillPop: () async {
              timer?.cancel();
              return true;
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🚦 신호등', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('📍 위치: ($lat, $lng)'),
                  Text('🔁 등화방식 코드: $pattern'),
                  Text('🔄 현재 신호: $currentPhase'),
                  Text('⏳ 다음 단계까지 남은 시간: ${remaining}s'),
                  const SizedBox(height: 12),
                  Text('🧭 신호 사이클 구성'),
                  ...phases.map((p) => Text('- ${p['type']}: ${p['duration']}초')).toList(),
                ],
              ),
            ),
          );
        },
      );
    },
  ).whenComplete(() {
    timer?.cancel();
    timer = null;
  });
}