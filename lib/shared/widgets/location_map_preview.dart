import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
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
  Set<Polyline> _polylines = {};

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// 🔥 DRAW REAL ROUTE
  Future<void> _drawRoute(LatLng start, LatLng end) async {
    PolylinePoints polylinePoints = PolylinePoints();

    final result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: "AIzaSyBlE2rQBXGeCbH6Ns7AaLF9d5TS9RK3yqc",
      request: PolylineRequest(
        origin: PointLatLng(start.latitude, start.longitude),
        destination: PointLatLng(end.latitude, end.longitude),
        mode: TravelMode.driving,
      ),
    );

    /// DEBUG (optional)
    print("Points: ${result.points.length}");
    print("Error: ${result.errorMessage}");

    if (result.points.isNotEmpty) {
      final points = result.points
          .map((e) => LatLng(e.latitude, e.longitude))
          .toList();

      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId("route"),
            points: points,
            color: Colors.blue,
            width: 5,
          )
        };
      });
    }
  }

  Future<void> _fitBounds() async {
    final primary = widget.location;
    final secondary = widget.secondaryLocation;

    if (primary == null || _controller == null) return;

    final primaryLatLng = LatLng(primary.latitude, primary.longitude);

    if (secondary == null) {
      await _controller!.animateCamera(
        CameraUpdate.newLatLngZoom(primaryLatLng, 15),
      );
      return;
    }

    final secondaryLatLng =
        LatLng(secondary.latitude, secondary.longitude);

    /// 🔥 DRAW ROUTE
    await _drawRoute(secondaryLatLng, primaryLatLng);

    final bounds = LatLngBounds(
      southwest: LatLng(
        primary.latitude < secondary.latitude
            ? primary.latitude
            : secondary.latitude,
        primary.longitude < secondary.longitude
            ? primary.longitude
            : secondary.longitude,
      ),
      northeast: LatLng(
        primary.latitude > secondary.latitude
            ? primary.latitude
            : secondary.latitude,
        primary.longitude > secondary.longitude
            ? primary.longitude
            : secondary.longitude,
      ),
    );

    await _controller!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );
  }

  @override
  void didUpdateWidget(covariant LocationMapPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    _fitBounds();
  }

  @override
  Widget build(BuildContext context) {
    final primary = widget.location;
    if (primary == null) {
      return const SizedBox();
    }

    final primaryLatLng =
        LatLng(primary.latitude, primary.longitude);

    final secondary = widget.secondaryLocation;
    final secondaryLatLng = secondary == null
        ? null
        : LatLng(secondary.latitude, secondary.longitude);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: widget.height,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: primaryLatLng,
            zoom: 14,
          ),
          onMapCreated: (c) {
            _controller = c;
            _fitBounds();
          },

          /// 🔥 IMPORTANT FIXES
          liteModeEnabled: true,
          zoomGesturesEnabled: false,
          scrollGesturesEnabled: false,
          mapToolbarEnabled: false,

          markers: {
            Marker(
              markerId: const MarkerId('donation'),
              position: primaryLatLng,
            ),
            if (secondaryLatLng != null)
              Marker(
                markerId: const MarkerId('ngo'),
                position: secondaryLatLng,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueAzure,
                ),
              ),
          },

          polylines: _polylines,
        ),
      ),
    );
  }
}