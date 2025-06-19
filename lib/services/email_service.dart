import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

Future<void> sendEmail({
  required String city,
  required Map signal,
  required LatLng newPosition,
}) async {
  final smtpServer = SmtpServer(
    'smtp.naver.com',
    username: 'dkdlel01458@naver.com',
    password: 'VG42D3RYM5BT',
    port: 465,
    ssl: true,
  );

  final message = Message()
    ..from = Address('dkdlel01458@naver.com', '신호등 수정 제보')
    ..recipients.add('dkdlel01458@naver.com')
    ..subject = '[시작 앱] $city 신호등 위치 수정 제보'
    ..text = '''
📍 신호등 위치 수정 제보 도착!

- 도시: $city
- 기존 신호 정보: ${json.encode(signal)}
- 새로운 위치: 위도 ${newPosition.latitude}, 경도 ${newPosition.longitude}
    ''';

  try {
    await send(message, smtpServer);
    print('✅ 이메일 전송 성공');
  } catch (e) {
    print('❌ 이메일 전송 실패: $e');
  }
}