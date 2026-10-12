import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:store/core/theme/burhan_colors.dart';
import 'package:store/core/theme/burhan_typography.dart';
import 'package:store/core/widgets/burhan_bottom_sheet.dart';

class AddressLocationResult {
  const AddressLocationResult({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;
}

Future<AddressLocationResult?> showAddressLocationPickerSheet({
  required BuildContext context,
  double? initialLatitude,
  double? initialLongitude,
}) {
  return BurhanBottomSheet.show<AddressLocationResult>(
    context: context,
    title: 'تحديد الموقع على الخريطة',
    child: _AddressLocationPickerBody(
      initialLatitude: initialLatitude,
      initialLongitude: initialLongitude,
    ),
  );
}

class _AddressLocationPickerBody extends StatefulWidget {
  const _AddressLocationPickerBody({
    this.initialLatitude,
    this.initialLongitude,
  });

  final double? initialLatitude;
  final double? initialLongitude;

  @override
  State<_AddressLocationPickerBody> createState() =>
      _AddressLocationPickerBodyState();
}

class _AddressLocationPickerBodyState extends State<_AddressLocationPickerBody> {
  static const _sanaa = LatLng(15.3694, 44.1910);

  late LatLng _pin;
  GoogleMapController? _controller;
  String? _error;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _pin = LatLng(
      widget.initialLatitude ?? _sanaa.latitude,
      widget.initialLongitude ?? _sanaa.longitude,
    );
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _locating = true;
      _error = null;
    });
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        setState(() => _error = 'فعّل خدمة الموقع من إعدادات الجهاز');
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _error = 'يلزم السماح بالوصول إلى موقعك');
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final next = LatLng(position.latitude, position.longitude);
      setState(() => _pin = next);
      await _controller?.animateCamera(CameraUpdate.newLatLngZoom(next, 16));
    } catch (_) {
      setState(() => _error = 'تعذر تحديد الموقع الحالي');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.55;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'حرّك الخريطة أو اضغط لاختيار النقطة، ثم أكّد الموقع.',
          style: BurhanTypography.caption.copyWith(color: BurhanColors.slate600),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: height.clamp(280, 420),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: _pin, zoom: 14),
              myLocationButtonEnabled: false,
              myLocationEnabled: false,
              zoomControlsEnabled: false,
              markers: {
                Marker(
                  markerId: const MarkerId('selected'),
                  position: _pin,
                  draggable: true,
                  onDragEnd: (value) => setState(() => _pin = value),
                ),
              },
              onMapCreated: (controller) => _controller = controller,
              onTap: (value) => setState(() => _pin = value),
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              _error!,
              style: BurhanTypography.caption.copyWith(color: BurhanColors.rose500),
            ),
          ),
        OutlinedButton.icon(
          onPressed: _locating ? null : _useCurrentLocation,
          icon: _locating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.my_location_rounded, size: 18),
          label: const Text('موقعي الحالي'),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 46,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: BurhanColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop(
                AddressLocationResult(
                  latitude: _pin.latitude,
                  longitude: _pin.longitude,
                ),
              );
            },
            child: Text(
              'تأكيد الموقع',
              style: BurhanTypography.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
