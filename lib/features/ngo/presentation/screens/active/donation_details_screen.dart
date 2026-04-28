import 'package:flutter/material.dart';
import 'package:wastenot/services/donation_services.dart';
import 'package:wastenot/services/location_estimate_service.dart';
import 'package:wastenot/services/session_service.dart';
import 'package:wastenot/shared/widgets/location_map_preview.dart';

class DonationDetailsScreen extends StatefulWidget {
  const DonationDetailsScreen({super.key, required this.donation});

  final DonationModel donation;

  @override
  State<DonationDetailsScreen> createState() =>
      _DonationDetailsScreenState();
}

class _DonationDetailsScreenState
    extends State<DonationDetailsScreen> {
  final DonationService _donationService = DonationService();
  final LocationEstimateService _locationEstimateService =
      const LocationEstimateService();

  late Future<DonationModel> _donationFuture;

  @override
  void initState() {
    super.initState();
    _donationFuture =
        _donationService.getDonationById(widget.donation.donationId);
  }

  /// ðŸ“¸ IMAGE VIEW
  void _openImage(String url) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha:0.9),
      builder: (_) => Stack(
        children: [
          Center(child: InteractiveViewer(child: Image.network(url))),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close,
                  color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          )
        ],
      ),
    );
  }

  String _truncate(String text) {
    if (text.length > 40) return "${text.substring(0, 40)}...";
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),

      /// ðŸ”¥ APPBAR
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B4B3F),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Donation Details",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),

      body: FutureBuilder<DonationModel>(
        future: _donationFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator());
          }

          final donation = snapshot.data!;
          final ngoLocation =
              donation.acceptedByNgoLocation ??
                  SessionService.user?.location;

          final estimate = _locationEstimateService.estimate(
            from: ngoLocation,
            to: donation.location,
          );

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      /// ðŸ“¸ IMAGES
                      const Text("Pictures",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),

                      const SizedBox(height: 10),

                      Row(
                        children: donation.imageUrls
                            .take(3)
                            .map((url) {
                          return Padding(
                            padding:
                                const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () => _openImage(url),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(12),
                                child: Image.network(
                                  url,
                                  height: 90,
                                  width: 90,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 22),

                      /// ðŸ“ LOCATION
                      const Text("Location",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),

                      const SizedBox(height: 10),

                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.grey.shade300),
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(16),
                          child: LocationMapPreview(
                            location: donation.location,
                            secondaryLocation: ngoLocation,
                            height: 170,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: Colors.red, size: 20),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _truncate(donation
                                      .locationAddress ??
                                  ""),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            estimate == null
                                ? ""
                                : "${estimate.distanceKm.toStringAsFixed(1)} km",
                          )
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Estimated Time"),
                          Text(
                            estimate == null
                                ? "--"
                                : "${estimate.estimatedMinutes} mins",
                            style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),

                      const Divider(height: 25),

                      /// ðŸ”¥ INFO (CLEANED)
                      _info("Donor", donation.donorName),
                      _info("Servings",
                          "${donation.quantity} Persons"),
                      _info("Contact",
                          donation.donorPhone ?? "-"),

                      /// âœ… STATUS (GREEN)
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: const [
                            SizedBox(
                              width: 100,
                              child: Text("Status"),
                            ),
                            Text(
                              "Accepted",
                              style: TextStyle(
                                color: Color(0xFF0B4B3F),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// âœ… ACCEPTED TIME
                      if (donation.acceptedAt != null)
                        _info(
                          "Accepted At",
                          _formatDateTime(
                              donation.acceptedAt!),
                        ),

                      const SizedBox(height: 18),

                      const Text("Description",
                          style: TextStyle(
                              fontWeight: FontWeight.bold)),

                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.grey.shade400),
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: Text(
                          donation.description ?? "",
                          style:
                              const TextStyle(height: 1.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// âŒ NO ACCEPT BUTTON
              /// âœ… ONLY RETURN BUTTON
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize:
                        const Size(double.infinity, 52),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Return"),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _info(String title, String value) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(title)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

String _formatDateTime(DateTime value) {
  final hour = value.hour == 0
      ? 12
      : (value.hour > 12 ? value.hour - 12 : value.hour);
  final suffix = value.hour >= 12 ? 'PM' : 'AM';
  final minute = value.minute.toString().padLeft(2, '0');

  return '${value.day}/${value.month}/${value.year} $hour:$minute $suffix';
}