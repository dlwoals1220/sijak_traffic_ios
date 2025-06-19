import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'screens/google_map_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF00C471),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.traffic, size: 64, color: Colors.white),
            SizedBox(height: 20),
            Text('시작', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 8),
            Text('도시의 신호, 당신의 시간으로 바꾸다',
                style: TextStyle(fontSize: 14, color: Colors.white70),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final pwController = TextEditingController();
  String message = '';

  void tryLogin() {
    if (emailController.text == 'test@example.com' && pwController.text == '1234') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SelectionPage()),
      );
    } else {
      setState(() {
        message = '로그인 정보가 올바르지 않습니다.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('로그인', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: '이메일',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pwController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: tryLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C471),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('로그인'),
              ),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpPage())),
                child: const Text('계정이 없으신가요? 회원가입'),
              ),
              Text(message, style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final emailController = TextEditingController();
  final pwController = TextEditingController();
  String message = '';

  void trySignUp() {
    if (emailController.text.isNotEmpty && pwController.text.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SelectionPage()),
      );
    } else {
      setState(() {
        message = '모든 정보를 입력해주세요.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('회원가입', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: '이메일',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pwController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: trySignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C471),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('회원가입'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('이미 계정이 있으신가요? 로그인'),
              ),
              Text(message, style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}

class SelectionPage extends StatefulWidget {
  const SelectionPage({super.key});
  @override
  State<SelectionPage> createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  String selectedCity = '수원';
  String selectedType = '보행자용';
  final List<String> allowedCities = ['구리','수원'];

  void _goToMap() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('위치 권한이 필요합니다. 설정에서 허용해주세요.')),
        );
        return;
      }
    }

    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GoogleMapScreen(
          selectedCity: selectedCity,
          selectedType: selectedType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('신호등 설정 선택')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('지역 선택', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: selectedCity,
              isExpanded: true,
              items: allowedCities
                  .map((city) => DropdownMenuItem(value: city, child: Text(city)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedCity = value);
                }
              },
            ),
            const SizedBox(height: 24),
            const Text('신호등 종류 선택', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: selectedType,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: '보행자용', child: Text('보행자용')),
                DropdownMenuItem(value: '차량용', child: Text('차량용')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedType = value);
                }
              },
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _goToMap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C471),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('지도 보기'),
            ),
          ],
        ),
      ),
    );
  }
}

