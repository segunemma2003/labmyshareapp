import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class LocationChangePage extends NyStatefulWidget {
  static RouteView path = ("/location-change", (_) => LocationChangePage());

  LocationChangePage({super.key})
      : super(child: () => _LocationChangePageState());
}

class _LocationChangePageState extends NyPage<LocationChangePage> {
  String selectedLocation = "United Kingdom";

  @override
  get init => () {
        // Initialize any data here
      };

  Widget _buildLocationOption({
    required String flag,
    required String countryName,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.blue.shade50 : Colors.white,
        ),
        child: Row(
          children: [
            Text(
              flag,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                countryName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem(String day, String hours) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              day,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            hours,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // World Map Area
              Container(
                height: 200,
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

              // Switch your current location section
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

                    // Location options
                    Row(
                      children: [
                        Expanded(
                          child: _buildLocationOption(
                            flag: "🇬🇧",
                            countryName: "United Kingdom",
                            isSelected: selectedLocation == "United Kingdom",
                            onTap: () {
                              setState(() {
                                selectedLocation = "United Kingdom";
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildLocationOption(
                            flag: "🇦🇪",
                            countryName: "United Arab Emirates",
                            isSelected:
                                selectedLocation == "United Arab Emirates",
                            onTap: () {
                              setState(() {
                                selectedLocation = "United Arab Emirates";
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    // Selected location details
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_city,
                                color: Colors.orange,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  selectedLocation == "United Kingdom"
                                      ? "Beckenham, England, United kingdom"
                                      : "Dubai, United Arab Emirates",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  "Closed",
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                "Opens next 9am Monday",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    // Schedule section
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Schedule",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // Schedule items
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          _buildScheduleItem("Monday", "9am-10pm"),
                          _buildScheduleItem("Tuesday", "9am-10pm"),
                          _buildScheduleItem("Wednesday", "9am-10pm"),
                          _buildScheduleItem("Thursday", "9am-10pm"),
                          _buildScheduleItem("Friday", "9am-10pm"),
                          _buildScheduleItem("Saturday", "9am-10pm"),
                        ],
                      ),
                    ),

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
