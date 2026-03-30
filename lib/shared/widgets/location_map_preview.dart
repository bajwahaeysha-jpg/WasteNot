import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wastenot/models/app_location.dart';

class LocationMapPreview extends StatefulWidget {
  const LocationMapPreview({
    super.key,
    required this.location,
    this.secondaryLocation,
    this.height = 180,
  });

  final AppLocation? location;
  final AppLocation? secondaryLocation;
  final double height;

  @override
  State<LocationMapPreview> createState() => _LocationMapPreviewState();
}

class _LocationMapPreviewState extends State<LocationMapPreview> {
  GoogleMapController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _fitBounds() async {
    final primary = widget.location;
    if (primary == null || _controller == null) {
      return;
    }

    final secondary = widget.secondaryLocation;
    if (secondary == null) {
      await _controller!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(primary.latitude, primary.longitude),
            zoom: 15,
          ),
        ),
      );
      return;
    }

    final sw = LatLng(
      primary.latitude < secondary.latitude
          ? primary.latitude
          : secondary.latitude,
      primary.longitude < secondary.longitude
          ? primary.longitude
          : secondary.longitude,
    );
    final ne = LatLng(
      primary.latitude > secondary.latitude
          ? primary.latitude
          : secondary.latitude,
      primary.longitude > secondary.longitude
          ? primary.longitude
          : secondary.longitude,
    );

    await _controller!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: sw, northeast: ne),
        48,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryLocation = widget.location;
    if (primaryLocation == null) {
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        alignment: Alignment.center,
        child: const Text('Location preview unavailable'),
      );
    }

    final primaryPosition = LatLng(
      primaryLocation.latitude,
      primaryLocation.longitude,
    );
    final secondary = widget.secondaryLocation;
    final secondaryPosition = secondary == null
        ? null
        : LatLng(secondary.latitude, secondary.longitude);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: widget.height,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: primaryPosition,
            zoom: 15,
          ),
          onMapCreated: (controller) {
            _controller = controller;
            _fitBounds();
          },
          markers: {
            Marker(
              markerId: const MarkerId('primary-location-preview'),
              position: primaryPosition,
            ),
            if (secondaryPosition != null)
              Marker(
                markerId: const MarkerId('secondary-location-preview'),
                position: secondaryPosition,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueAzure,
                ),
              ),
          },
          polylines: {
            if (secondaryPosition != null)
              Polyline(
                polylineId: const PolylineId('location-route-preview'),
                points: <LatLng>[secondaryPosition, primaryPosition],
                width: 4,
                geodesic: true,
                color: const Color(0xFF4A90E2),
                patterns: <PatternItem>[
                  PatternItem.dot,
                  PatternItem.gap(8),
                ],
              ),
          },
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
          rotateGesturesEnabled: false,
          tiltGesturesEnabled: false,
        ),
      ),
    );
  }
}
