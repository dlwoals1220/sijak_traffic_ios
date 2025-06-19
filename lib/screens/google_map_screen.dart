import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/signal_data_loader.dart';
import '../local_storage_service.dart';
import '../services/email_service.dart';
import '../widgets/signal_info_bottom_sheet.dart';
import 'package:geolocator/geolocator.dart';
class GoogleMapScreen extends StatefulWidget {
  final String selectedCity;
  final String selectedType;

  const GoogleMapScreen({
    super.key,
    required this.selectedCity,
    required this.selectedType,
  });

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> with SingleTickerProviderStateMixin {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  late AnimationController _drawerController;
  late Animation<Offset> _drawerAnimation;
  bool _isDrawerOpen = false;

  @override
  void initState() {
    super.initState();
    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _drawerAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _drawerController,
      curve: Curves.easeInOut,
    ));
    _loadMarkers(widget.selectedCity);
    _initLocationTracking();
  }
  void _initLocationTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();

    mapController.animateCamera(
      CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
    );

    Geolocator.getPositionStream().listen((Position pos) {
      mapController.animateCamera(
        CameraUpdate.newLatLng(LatLng(pos.latitude, pos.longitude)),
      );
    });
  }
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.setMapStyle(null);
  }

  Future<void> _loadMarkers(String cityName) async {
    try {
      final newMarkers = await loadSignalData(
        cityName: cityName,
        selectedType: widget.selectedType,
        onTap: ({
          required double lat,
          required double lng,
          required List<Map<String, dynamic>> phases,
          required int pattern,
          required Map signal,
        }) {
          showSignalBottomSheet(
            context: context,
            lat: lat,
            lng: lng,
            phases: phases,
            pattern: pattern,
          );
        },
        onDragEnd: ({
          required String city,
          required Map signal,
          required LatLng newPosition,
        }) async {
          await saveSignalToLocal(
            city: city,
            signal: signal,
            newPosition: newPosition,
          );
          await sendEmail(
            city: city,
            signal: signal,
            newPosition: newPosition,
          );
        },
      );

      setState(() {
        _markers.clear();
        _markers.addAll(newMarkers);
      });
    } catch (e) {
      print('❌ 마커 로딩 실패: $e');
    }
  }

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
      if (_isDrawerOpen) {
        _drawerController.forward();
      } else {
        _drawerController.reverse();
      }
    });
  }

  void _showCitySelector() async {
    final newCity = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('지역 변경'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: '예: 구리'),
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
      ),
    );
    if (newCity != null && newCity.isNotEmpty) {
      _loadMarkers(newCity);
    }
  }

  @override
  void dispose() {
    _drawerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('시작 - 신호등 지도'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: _toggleDrawer,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(37.603, 127.138),
              zoom: 25,
              tilt: 65,
            ),
            buildingsEnabled: true,
            markers: _markers,
            mapType: MapType.normal,
            myLocationEnabled: true,           // ← 현재 위치 파란 점
            myLocationButtonEnabled: true,     // ← 내 위치 버튼
          ),
          SlideTransition(
            position: _drawerAnimation,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Container(
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Colors.indigo,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                        ),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Text('설정 메뉴', style: TextStyle(color: Colors.white, fontSize: 20)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.location_city),
                      title: const Text('지역 변경'),
                      onTap: () {
                        _toggleDrawer();
                        _showCitySelector();
                      },
                    ),
                    const ListTile(
                      leading: Icon(Icons.traffic),
                      title: Text('신호등 유형 필터 (준비 중)'),
                    ),
                    const ListTile(
                      leading: Icon(Icons.info),
                      title: Text('앱 정보 (준비 중)'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}