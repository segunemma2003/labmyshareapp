import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/app/services/region_service.dart';
import 'package:flutter_app/app/services/auth_service.dart';
import 'package:flutter_app/app/models/region.dart';
import '/config/keys.dart';

class LocationChangePage extends NyStatefulWidget {
  static RouteView path = ("/location-change", (_) => LocationChangePage());

  LocationChangePage({super.key})
      : super(child: () => _LocationChangePageState());
}

class _LocationChangePageState extends NyPage<LocationChangePage> {
  List<Region> _regions = [];
  String? _selectedRegionCode;
  bool _loading = true;
  bool _error = false;

  @override
  get init => () async {
        await _loadRegionsAndCurrent();
      };

  Future<void> _loadRegionsAndCurrent() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final regions = await RegionService.getRegions();
      String? currentRegionCode = await Keys.currentRegion.read();
      setState(() {
        _regions = regions ?? [];
        _selectedRegionCode = currentRegionCode ??
            (_regions.isNotEmpty ? _regions.first.code : null);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  Future<void> _onRegionTap(Region region) async {
    if (_selectedRegionCode == region.code) return;
    setState(() {
      _loading = true;
    });
    final success = await AuthService.switchRegion(regionCode: region.code!);
    if (success) {
      setState(() {
        _selectedRegionCode = region.code;
        _loading = false;
      });
      showToast(
        title: "Success",
        description: "Region switched to ${region.name}",
        style: ToastNotificationStyleType.success,
      );
    } else {
      setState(() {
        _loading = false;
      });
      showToast(
        title: "Error",
        description: "Failed to switch region.",
        style: ToastNotificationStyleType.danger,
      );
    }
  }

  Widget _buildRegionSelection() {
    if (_regions.isEmpty) {
      return Text(
        "No regions available",
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF666666),
        ),
      );
    }
    return Row(
      children: _regions.map((region) {
        bool isSelected = _selectedRegionCode == region.code;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: _regions.last == region ? 0 : 12,
            ),
            child: GestureDetector(
              onTap: () => _onRegionTap(region),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Color(0xFF000000) : Color(0xFFE0E0E0),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on,
                        color:
                            isSelected ? Color(0xFF000000) : Color(0xFF5C7CFA)),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        region.name ?? region.code ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF000000),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Location Change",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? Center(child: CircularProgressIndicator())
            : _error
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 40),
                        SizedBox(height: 12),
                        Text('Failed to load regions'),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _loadRegionsAndCurrent,
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // World Map Area
                        Container(
                          height: 300,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade200),
                            ),
                            image: DecorationImage(
                              image: AssetImage('map.png').localAsset(),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Switch your current location",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 20),
                              _buildRegionSelection(),
                              SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
