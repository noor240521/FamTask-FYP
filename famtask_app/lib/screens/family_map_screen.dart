import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../core/app_state.dart';

class FamilyMapScreen extends StatefulWidget {
  const FamilyMapScreen({super.key});

  @override
  State<FamilyMapScreen> createState() => _FamilyMapScreenState();
}

class _FamilyMapScreenState extends State<FamilyMapScreen> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final user = state.currentUser!;

    // Coordinates mapping for other members
    // Starting coordinates centered near the Islamabad center (from app_state coordinates)
    final LatLng centerLatLng = LatLng(33.7150, 73.0750);

    // Dynamic marker for CURRENT user based on the selected simulated location
    final double userLat = state.currentSimLocation.latitude;
    final double userLng = state.currentSimLocation.longitude;
    final LatLng userLatLng = LatLng(userLat, userLng);

    // List of simulated markers for the family members
    // 1. Current User
    final List<Marker> markers = [
      Marker(
        point: userLatLng,
        width: 80,
        height: 80,
        child: _buildAvatarMarker(user.name, user.avatar, isSelf: true),
      ),
    ];

    // 2. Add static/simulated locations for other members to showcase collaborative maps
    final otherMembers = state.familyMembers.where((m) => m.id != user.id).toList();
    
    // Assign unique coordinates to other family members so they spread across mock locations
    final List<LatLng> otherCoords = [
      LatLng(33.7299, 73.0940), // Utility Store
      LatLng(33.6844, 73.0479), // School
      LatLng(33.7081, 73.0498), // Main Bank
      LatLng(33.7294, 73.0931), // Home
    ];

    for (int i = 0; i < otherMembers.length; i++) {
      if (i < otherCoords.length) {
        final member = otherMembers[i];
        markers.add(
          Marker(
            point: otherCoords[i],
            width: 80,
            height: 80,
            child: _buildAvatarMarker(member.name, member.avatar, isSelf: false, role: member.role),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Family Map',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: FamTheme.darkPurple,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: FamTheme.darkPurple),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Reset map view center to user
              _mapController.move(userLatLng, 13.5);
            },
            icon: const Icon(Icons.my_location_rounded, color: FamTheme.primary),
            tooltip: 'Center on Me',
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. FREE MAP LAYER (OpenStreetMap)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: userLatLng,
              initialZoom: 13.5,
              maxZoom: 18,
              minZoom: 10,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.fyp.famtask',
              ),
              MarkerLayer(markers: markers),
            ],
          ),

          // 2. BOTTOM CONTROLLER / INFO SHEET
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: FamTheme.primary.withOpacity(0.15)),
                boxShadow: [
                  BoxShadow(
                    color: FamTheme.darkPurple.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: FamTheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.map_rounded, color: FamTheme.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Simulated Proximity Tracking',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: FamTheme.darkPurple,
                              ),
                            ),
                            Text(
                              'Change simulated location on Dashboard to see markers move.',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: FamTheme.darkPurple.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildLegendItem('You (Self)', FamTheme.primary),
                      _buildLegendItem('Family Members', FamTheme.secondary),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: FamTheme.darkPurple),
        ),
      ],
    );
  }

  Widget _buildAvatarMarker(String name, String avatar, {required bool isSelf, String? role}) {
    final Color markerColor = isSelf ? FamTheme.primary : FamTheme.secondary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Name overlay
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: FamTheme.darkPurple,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            isSelf ? 'You' : '$name (${role ?? "Family"})',
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 2),
        // Pins Avatar
        Stack(
          alignment: Alignment.center,
          children: [
            // Pointer pin
            Icon(
              Icons.location_on_rounded,
              color: markerColor,
              size: 52,
            ),
            // White background ring for avatar
            Positioned(
              top: 5,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  avatar,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: markerColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
