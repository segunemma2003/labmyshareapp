import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/professional.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/app/services/professionals_data_service.dart';
import 'package:flutter_app/app/services/auth_service.dart';
import 'package:flutter_app/app/models/service_item.dart';
import 'package:intl/intl.dart';
import '../../resources/pages/select_time_page.dart';

class SelectProfessionalPage extends NyStatefulWidget {
  static RouteView path =
      ("/select-professional", (_) => SelectProfessionalPage());

  SelectProfessionalPage({super.key})
      : super(child: () => _SelectProfessionalPageState());
}

class _SelectProfessionalPageState extends NyPage<SelectProfessionalPage> {
  int? selectedProfessionalIndex;
  List<Professional> professionals = [];
  bool _loading = true;
  bool _error = false;
  Map<int, bool> _professionalAvailability = {};

  @override
  get init => () async {
        await _loadProfessionals();
      };

  Future<void> _loadProfessionals() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final user = await AuthService.getCurrentUser();
      final regionId = user?.currentRegion?.id;
      // Get selected services from navigation data
      final selectedServices =
          (widget.data()?['selectedServices'] as List<Service>?) ?? [];
      final int? serviceId =
          selectedServices.isNotEmpty ? selectedServices.first.id : null;
      final apiProfessionals = await ProfessionalsDataService.getProfessionals(
        serviceId: serviceId,
        regionId: regionId,
      );

      // Check availability for each professional
      final availabilityMap = <int, bool>{};
      if (apiProfessionals != null && serviceId != null) {
        for (final professional in apiProfessionals) {
          if (professional.id != null) {
            final hasAvailability = await _checkProfessionalAvailability(
                professional.id!, serviceId);
            availabilityMap[professional.id!] = hasAvailability;
          }
        }
      }

      setState(() {
        professionals = apiProfessionals ?? [];
        _professionalAvailability = availabilityMap;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  Future<bool> _checkProfessionalAvailability(
      int professionalId, int serviceId) async {
    try {
      // Check for available slots in the next 30 days
      final today = DateTime.now();
      final futureDate = today.add(Duration(days: 30));
      final startDate = DateFormat('yyyy-MM-dd').format(today);
      final endDate = DateFormat('yyyy-MM-dd').format(futureDate);

      // Get current user's region
      final user = await AuthService.getCurrentUser();
      final regionId = user?.currentRegion?.id;

      final slots = await ProfessionalsDataService.getAvailableSlots(
        professionalId: professionalId,
        serviceId: serviceId,
        startDate: startDate,
        endDate: endDate,
        regionId: regionId,
      );

      // Check if there are any available slots
      if (slots != null && slots.isNotEmpty) {
        for (var slot in slots) {
          if (slot is Map && slot['is_available'] == true) {
            return true; // Found at least one available slot
          }
        }
      }

      return false; // No available slots found
    } catch (e) {
      print('Error checking professional availability: $e');
      return false; // Assume unavailable on error
    }
  }

  void _showUnavailableMessage(String professionalName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Professional Unavailable'),
          content: Text(
              '$professionalName is currently unavailable for booking. Please select another professional.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget view(BuildContext context) {
    // Calculate total price from selected services and add-ons
    final navData = widget.data() ?? {};
    final selectedServices =
        navData['selectedServices'] as List<Service>? ?? [];
    final serviceAddOns =
        navData['serviceAddOns'] as Map<int, List<AddOn>>? ?? {};
    double totalPrice =
        selectedServices.fold(0, (sum, s) => sum + (s.regionalPrice ?? 0));
    totalPrice += serviceAddOns.values.expand((list) => list).fold(
        0, (sum, addon) => sum + (double.tryParse(addon.price ?? "0") ?? 0));
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Select Professional",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _error
              ? Center(child: Text('Failed to load professionals'))
              : Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.1,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: professionals.length,
                          itemBuilder: (context, index) {
                            final professional = professionals[index];
                            final isSelected =
                                selectedProfessionalIndex == index;

                            final isAvailable = professional.id != null
                                ? _professionalAvailability[professional.id!] ??
                                    true
                                : true;

                            return GestureDetector(
                              onTap: isAvailable
                                  ? () {
                                      setState(() {
                                        selectedProfessionalIndex = index;
                                      });
                                    }
                                  : () {
                                      _showUnavailableMessage(
                                          professional.name ?? 'Professional');
                                    },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.black
                                        : isAvailable
                                            ? Colors.grey.shade300
                                            : Colors.grey.shade400,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  color: isAvailable
                                      ? Colors.white
                                      : Colors.grey.shade100,
                                ),
                                child: Stack(
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Profile Image or Logo
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: professional
                                                        .isAnyProfessional ==
                                                    true
                                                ? const Color(0xFF4A5C6A)
                                                : Colors.grey.shade200,
                                          ),
                                          child: professional
                                                      .isAnyProfessional ==
                                                  true
                                              ? const Center(
                                                  child: Text(
                                                    "H",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    ),
                                                  ),
                                                )
                                              : professional.imageUrl != null
                                                  ? ClipOval(
                                                      child: Image.asset(
                                                        professional.imageUrl!,
                                                        width: 60,
                                                        height: 60,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context,
                                                            error, stackTrace) {
                                                          return Container(
                                                            width: 60,
                                                            height: 60,
                                                            color: Colors
                                                                .grey.shade300,
                                                            child: const Icon(
                                                                Icons.person,
                                                                size: 30),
                                                          );
                                                        },
                                                      ).localAsset(),
                                                    )
                                                  : const Icon(Icons.person,
                                                      size: 30),
                                        ),
                                        const SizedBox(height: 12),
                                        // Name
                                        Text(
                                          professional.name ?? "",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        // Subtitle
                                        if (professional.subtitle != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            professional.subtitle!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ],
                                    ),
                                    // Unavailable indicator
                                    if (!isAvailable)
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade100,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: Colors.red.shade300),
                                          ),
                                          child: Text(
                                            'Professional is Unavailable',
                                            style: TextStyle(
                                              color: Colors.red.shade700,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Bottom Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "£${totalPrice.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Container(
                                width: 120,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: selectedProfessionalIndex != null
                                      ? Colors.black
                                      : Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: selectedProfessionalIndex != null
                                        ? () {
                                            final selectedProfessional =
                                                professionals[
                                                    selectedProfessionalIndex!];

                                            // Check if selected professional is available
                                            final isAvailable =
                                                selectedProfessional.id != null
                                                    ? _professionalAvailability[
                                                            selectedProfessional
                                                                .id!] ??
                                                        true
                                                    : true;

                                            if (!isAvailable) {
                                              _showUnavailableMessage(
                                                  selectedProfessional.name ??
                                                      'Professional');
                                              return;
                                            }

                                            final navData = widget.data() ?? {};
                                            final selectedServices =
                                                navData['selectedServices']
                                                        as List<Service>? ??
                                                    [];
                                            final serviceAddOns = navData[
                                                        'serviceAddOns']
                                                    as Map<int, List<AddOn>>? ??
                                                {};
                                            routeTo(
                                              SelectTimePage.path,
                                              data: {
                                                'selectedProfessional':
                                                    selectedProfessional,
                                                'professionals': professionals,
                                                'selectedServices':
                                                    selectedServices,
                                                'serviceAddOns': serviceAddOns,
                                              },
                                            );
                                          }
                                        : null,
                                    child: const Center(
                                      child: Text(
                                        "Continue",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                "1 service",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Container(
                                width: 4,
                                height: 4,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade600,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Text(
                                "8 Hours 30 mins - 9 Hours",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
