import 'package:flutter/material.dart';
import 'package:wastenot/services/location_estimate_service.dart';
import 'package:wastenot/services/donation_services.dart';
import 'package:wastenot/services/session_service.dart';
import 'package:wastenot/shared/widgets/location_map_preview.dart';

class DonationDetailsScreen extends StatefulWidget {
  const DonationDetailsScreen({super.key, required this.donation});

  final DonationModel donation;

  @override
  State<DonationDetailsScreen> createState() =>
      _DonationDetailsScreenState();
}

class _DonationDetailsScreenState extends State<DonationDetailsScreen> {
  final DonationService _donationService = DonationService();
  final LocationEstimateService _locationEstimateService =
      const LocationEstimateService();

  late Future<DonationModel> _donationFuture;
  bool _isAccepting = false;

  @override
  void initState() {
    super.initState();
    _donationFuture =
        _donationService.getDonationById(widget.donation.donationId);
  }

  /// 📸 OPEN IMAGE
  void _openImage(String url) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
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

  /// ✅ ACCEPT DONATION
  Future<void> _accept(DonationModel donation) async {
    setState(() => _isAccepting = true);

    try {
      await _donationService.acceptDonation(
        donationId: donation.donationId,
        ngo: SessionService.user!,
      );

      if (!mounted) return;

      _showSuccessPopup(); // ✅ popup
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to accept donation')),
      );
    } finally {
      if (mounted) {
        setState(() => _isAccepting = false);
      }
    }
  }

  /// ✅ SUCCESS POPUP
  void _showSuccessPopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// drag line
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 20),

              /// icon
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F4C45),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check,
                    color: Colors.white, size: 32),
              ),

              const SizedBox(height: 18),

              /// title
              const Text(
                "Donation Accepted!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              /// subtitle
              const Text(
                "You can track it in active donations.",
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Colors.black54, fontSize: 14),
              ),

              const SizedBox(height: 22),

              /// button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF0F4C45),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // close popup
                    Navigator.pop(context, true); // go back
                  },
                  child: const Text("OK",
                      style: TextStyle(fontSize: 15)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 📏 ADDRESS SHORTENER
  String _truncate(String text) {
    if (text.length > 40) return "${text.substring(0, 40)}...";
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),

      /// 🔥 APPBAR
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F4C45),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Donation Details",
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w600,
          ),
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
          final ngoLocation = SessionService.user?.location;

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
                      /// 📸 IMAGES
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

                      /// 📍 LOCATION
                      const Text("Location",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),

                      const SizedBox(height: 10),

                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1),
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

                      /// INFO
                      _info("Donor", donation.donorName),
                      _info("Servings",
                          "${donation.quantity} Persons"),
                      _info("Contact",
                          donation.donorPhone ?? "-"),

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

              /// 🔻 BUTTONS
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(
                                  vertical: 17),
                        ),
                        onPressed: () =>
                            Navigator.pop(context),
                        child: const Text("Return"),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF0F4C45),
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(
                                  vertical: 17),
                        ),
                        onPressed: _isAccepting
                            ? null
                            : () => _accept(donation),
                        child: _isAccepting
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text("Accept"),
                      ),
                    ),
                  ],
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
          SizedBox(
            width: 100,
            child: Text(title),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}