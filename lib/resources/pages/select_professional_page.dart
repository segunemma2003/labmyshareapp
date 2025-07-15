import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/professional.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/app/services/professionals_data_service.dart';
import 'package:flutter_app/app/services/auth_service.dart';
import 'package:flutter_app/app/models/service_item.dart';

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
      setState(() {
        professionals = apiProfessionals ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  @override
  Widget view(BuildContext context) {
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

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedProfessionalIndex = index;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.grey.shade300,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  color: Colors.white,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Profile Image or Logo
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: professional.isAnyProfessional ==
                                                true
                                            ? const Color(0xFF4A5C6A)
                                            : Colors.grey.shade200,
                                      ),
                                      child: professional.isAnyProfessional ==
                                              true
                                          ? const Center(
                                              child: Text(
                                                "H",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle: FontStyle.italic,
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
                              const Text(
                                "£520",
                                style: TextStyle(
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
                                            // Handle continue action
                                            print(
                                                "Continue with professional: ${professionals[selectedProfessionalIndex!].name ?? 'Unknown'}");
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
