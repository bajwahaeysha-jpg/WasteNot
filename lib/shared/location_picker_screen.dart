import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wastenot/models/app_location.dart';
import 'package:wastenot/services/location_service.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({
    super.key,
    this.initialLocation,
    this.title = 'Select Location',
  });

  final AppLocation? initialLocation;
  final String title;

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  static const LatLng _fallbackCenter = LatLng(24.8607, 67.0011);
  static const double _resolvedCoordinatePrecision = 0.00005;

  final LocationService _locationService = const LocationService();
  final TextEditingController _searchController = TextEditingController();

  GoogleMapController? _mapController;
  AppLocation? _selectedLocation;
  AppLocation? _currentLocation;
  LatLng? _cameraTarget;
  LatLng? _lastResolvedTarget;
  List<AppLocation> _searchResults = const <AppLocation>[];
  bool _isInitializing = true;
  bool _isResolvingSelection = false;
  bool _isSearching = false;
  int _selectionRequestId = 0;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    _initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    setState(() {
      _isInitializing = true;
      _statusMessage = null;
    });

    try {
      final currentLocation = await _locationService.getCurrentLocation();
      if (!mounted) {
        return;
      }

      setState(() {
        _currentLocation = currentLocation;
        _selectedLocation ??= widget.initialLocation ?? currentLocation;
        _cameraTarget = LatLng(
          _selectedLocation!.latitude,
          _selectedLocation!.longitude,
        );
      });
    } on LocationPermissionException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedLocation ??= widget.initialLocation;
        _cameraTarget = _selectedLocation == null
            ? null
            : LatLng(
                _selectedLocation!.latitude,
                _selectedLocation!.longitude,
              );
        _statusMessage = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _statusMessage = 'Unable to fetch your current location right now.';
      });
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  Future<void> _selectLatLng(LatLng latLng) async {
    final requestId = ++_selectionRequestId;

    setState(() {
      _cameraTarget = latLng;
      _selectedLocation = AppLocation(
        latitude: latLng.latitude,
        longitude: latLng.longitude,
        address: _selectedLocation?.address ?? '',
      );
      _isResolvingSelection = true;
      _statusMessage = null;
    });

    try {
      final location = await _locationService.reverseGeocode(
        latitude: latLng.latitude,
        longitude: latLng.longitude,
      );

      if (!mounted) {
        return;
      }

      if (requestId != _selectionRequestId) {
        return;
      }

      setState(() {
        _selectedLocation = location;
        _lastResolvedTarget = latLng;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      if (requestId != _selectionRequestId) {
        return;
      }
      setState(() {
        _statusMessage = 'Unable to resolve the selected address.';
      });
    } finally {
      if (mounted) {
        if (requestId == _selectionRequestId) {
          setState(() => _isResolvingSelection = false);
        }
      }
    }
  }

  Future<void> _searchPlaces() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() => _searchResults = const <AppLocation>[]);
      return;
    }

    setState(() {
      _isSearching = true;
      _statusMessage = null;
    });

    final results = await _locationService.searchLocations(query);
    if (!mounted) {
      return;
    }

    setState(() {
      _searchResults = results;
      _isSearching = false;
      if (results.isEmpty) {
        _statusMessage = 'No matching places found. Try a broader search.';
      }
    });
  }

  Future<void> _jumpToLocation(AppLocation location) async {
    setState(() {
      _selectedLocation = location;
      _cameraTarget = LatLng(location.latitude, location.longitude);
      _lastResolvedTarget = _cameraTarget;
      _searchResults = const <AppLocation>[];
      _searchController.text = location.address;
    });

    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(location.latitude, location.longitude),
        16,
      ),
    );
  }

  Future<void> _useCurrentLocation() async {
    if (_currentLocation != null) {
      await _jumpToLocation(_currentLocation!);
      return;
    }

    await _initialize();
    if (_currentLocation != null) {
      await _jumpToLocation(_currentLocation!);
    }
  }

  void _saveSelection() {
    final target = _cameraTarget;
    if (target == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a location first.')),
      );
      return;
    }
    _confirmCameraLocation();
  }

  Future<void> _openExternalMaps() async {
    final target = _cameraTarget;
    if (target == null) {
      return;
    }

    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${target.latitude},${target.longitude}',
    );
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!mounted || launched) {
      return;
    }

    setState(() {
      _statusMessage =
          'Google Maps could not be opened. Keep using the in-app map or search.';
    });
  }

  bool _shouldResolveCameraTarget(LatLng target) {
    final last = _lastResolvedTarget;
    if (last == null) {
      return true;
    }

    return (last.latitude - target.latitude).abs() >
            _resolvedCoordinatePrecision ||
        (last.longitude - target.longitude).abs() >
            _resolvedCoordinatePrecision;
  }

  Future<void> _confirmCameraLocation() async {
    final target = _cameraTarget;
    if (target == null) {
      return;
    }

    setState(() => _isResolvingSelection = true);
    try {
      final location = await _locationService.reverseGeocode(
        latitude: target.latitude,
        longitude: target.longitude,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedLocation = location;
        _lastResolvedTarget = target;
      });
      Navigator.of(context).pop(location);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _statusMessage = 'Unable to confirm this map position.';
      });
    } finally {
      if (mounted) {
        setState(() => _isResolvingSelection = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialTarget = _selectedLocation == null
        ? _currentLocation == null
            ? _fallbackCenter
            : LatLng(_currentLocation!.latitude, _currentLocation!.longitude)
        : LatLng(_selectedLocation!.latitude, _selectedLocation!.longitude);
    _cameraTarget ??= initialTarget;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B4B3F),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _searchPlaces(),
                    decoration: InputDecoration(
                      hintText: 'Search address or place',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _isSearching
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.send_outlined),
                              onPressed: _searchPlaces,
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton.tonalIcon(
                  onPressed: _isInitializing ? null : _useCurrentLocation,
                  icon: const Icon(Icons.my_location),
                  label: const Text('GPS'),
                ),
              ],
            ),
          ),
          if (_searchResults.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 180),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _searchResults.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final result = _searchResults[index];
                  return ListTile(
                    leading: const Icon(Icons.place_outlined),
                    title: Text(result.address),
                    subtitle: Text(result.shortCoordinates),
                    onTap: () => _jumpToLocation(result),
                  );
                },
              ),
            ),
          if (_statusMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F1D9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_statusMessage!),
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: initialTarget,
                    zoom: 14,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
                  onCameraMove: (position) {
                    _cameraTarget = position.target;
                  },
                  onCameraIdle: () {
                    final target = _cameraTarget;
                    if (target != null && _shouldResolveCameraTarget(target)) {
                      _selectLatLng(target);
                    }
                  },
                  markers: {
                    if (_selectedLocation != null)
                      Marker(
                        markerId: const MarkerId('selected-location'),
                        position: LatLng(
                          _selectedLocation!.latitude,
                          _selectedLocation!.longitude,
                        ),
                      ),
                    if (_currentLocation != null)
                      Marker(
                        markerId: const MarkerId('current-location'),
                        position: LatLng(
                          _currentLocation!.latitude,
                          _currentLocation!.longitude,
                        ),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueAzure,
                        ),
                      ),
                  },
                  onTap: _selectLatLng,
                  mapType: MapType.normal,
                  myLocationEnabled: _currentLocation != null,
                  myLocationButtonEnabled: false,
                  compassEnabled: true,
                  mapToolbarEnabled: true,
                  zoomControlsEnabled: false,
                ),
                const IgnorePointer(
                  child: Center(
                    child: Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 42,
                    ),
                  ),
                ),
                if (_isInitializing || _isResolvingSelection)
                  Container(
                    color: Colors.black.withValues(alpha: 0.12),
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected location',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedLocation?.address ??
                      'Move the map or tap to choose a place.',
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedLocation?.shortCoordinates ?? 'No coordinates selected',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _cameraTarget == null ? null : _openExternalMaps,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open in Google Maps'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveSelection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B4B3F),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Use this location'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
