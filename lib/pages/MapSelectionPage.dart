
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapSelectionPage extends StatefulWidget {
  final LatLng? initialLocation;

  const MapSelectionPage({super.key, this.initialLocation});

  @override
  _MapSelectionPageState createState() => _MapSelectionPageState();
}

class _MapSelectionPageState extends State<MapSelectionPage> {
  late MapController _mapController;
  LatLng? _selectedLocation;
  LatLng _currentLocation = LatLng(0, 0);
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _isLoading = false;

  // LocationIQ API key
  final String apiKey = 'pk.0aaca77af3f5b1ba9002bae57ef1b2c6';

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedLocation = widget.initialLocation;

    if (_selectedLocation != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(_selectedLocation!, 15.0);
      });
    } else {
      _checkLocationPermission();
    }
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')),
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are permanently denied, we cannot request permissions.'),
          ),
        );
      }
      return;
    }

    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          if (_selectedLocation == null) {
            _selectedLocation = _currentLocation;
          }
          _mapController.move(_selectedLocation!, 15.0);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _isLoading = true;
    });

    // LocationIQ API endpoint with your token
    final url = Uri.parse(
        'https://us1.locationiq.com/v1/search?key=$apiKey&q=$query&format=json&limit=5'
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _searchResults = data.map((item) => {
              'displayName': item['display_name'],
              'lat': double.parse(item['lat']),
              'lon': double.parse(item['lon']),
            }).toList();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          String errorMessage = 'Search failed with status: ${response.statusCode}';
          try {
            final errorData = json.decode(response.body);
            if (errorData['error'] != null) {
              errorMessage = 'Search failed: ${errorData['error']}';
            }
          } catch (e) {
            // If parsing fails, use the default error message
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      }
    } catch (e) {
      print("Search error: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search error: $e')),
        );
      }
    }
  }

  void _moveToLocation(LatLng location) {
    setState(() {
      _selectedLocation = location;
      _isSearching = false;

      final matchingResult = _searchResults.firstWhere(
            (item) => item['lat'] == location.latitude && item['lon'] == location.longitude,
        orElse: () => {'displayName': '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}'},
      );

      _searchController.text = matchingResult['displayName'];
      _searchResults = [];
    });

    _mapController.move(location, 15.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              if (_selectedLocation != null) {
                Navigator.pop(context, {
                  'latLng': _selectedLocation,
                  'placeName': _searchController.text
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select a location first')),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for location...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchResults = [];
                      _isSearching = false;
                    });
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                // Debounce the search to avoid too many API calls
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (value == _searchController.text && value.isNotEmpty) {
                    _searchLocation(value);
                  } else if (value.isEmpty) {
                    setState(() {
                      _searchResults = [];
                      _isSearching = false;
                    });
                  }
                });
              },
              onTap: () {
                if (_searchController.text.isNotEmpty) {
                  setState(() {
                    _isSearching = true;
                  });
                  _searchLocation(_searchController.text);
                }
              },
            ),
          ),
          if (_isSearching)
            _isLoading
                ? const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            )
                : _searchResults.isNotEmpty
                ? Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final location = _searchResults[index];
                  return ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(location['displayName']),
                    onTap: () {
                      final latLng = LatLng(location['lat'], location['lon']);
                      final placeName = location['displayName'];
                      _moveToLocation(latLng);
                    },
                  );
                },
              ),
            )
                : const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No results found'),
            ),
          if (!_isSearching)
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      center: _selectedLocation ?? _currentLocation,
                      zoom: 15.0,
                      onTap: (tapPosition, point) {
                        setState(() {
                          _selectedLocation = point;
                          _searchController.text = "${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}";
                          _isSearching = false;
                          _searchResults = [];
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        // Use LocationIQ's tile server with your API key
                        urlTemplate: 'https://tiles.locationiq.com/v3/streets/r/{z}/{x}/{y}.png?key=$apiKey',
                        // Alternative if the above doesn't work:
                        // urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      ),
                      MarkerLayer(
                        markers: [
                          if (_selectedLocation != null)
                            Marker(
                              point: _selectedLocation!,
                              width: 40,
                              height: 40,
                              builder: (ctx) => const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          if (_currentLocation != LatLng(0, 0) &&
                              (_selectedLocation == null ||
                                  _selectedLocation!.latitude != _currentLocation.latitude ||
                                  _selectedLocation!.longitude != _currentLocation.longitude))
                            Marker(
                              point: _currentLocation,
                              width: 40,
                              height: 40,
                              builder: (ctx) => const Icon(
                                Icons.my_location,
                                color: Colors.blue,
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  if (_selectedLocation != null)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, {
                              'latLng': _selectedLocation,
                              'placeName': _searchController.text
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text(
                            'Use this location',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.clear();
    // super.dispose();
  }
}


