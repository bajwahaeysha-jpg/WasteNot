import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wastenot/features/donor/presentation/home/screens/donation_detail_screen.dart';
import 'package:wastenot/features/donor/presentation/messages/screens/chat_screen.dart';
import 'package:wastenot/features/donor/presentation/search/services/donor_global_search_service.dart';
import 'package:wastenot/models/app_user_model.dart';
import 'package:wastenot/services/donation_services.dart';
import 'package:wastenot/services/session_service.dart';

class DonorGlobalSearchScreen extends StatefulWidget {
  const DonorGlobalSearchScreen({
    super.key,
    this.initialQuery = '',
  });

  final String initialQuery;

  @override
  State<DonorGlobalSearchScreen> createState() => _DonorGlobalSearchScreenState();
}

class _DonorGlobalSearchScreenState extends State<DonorGlobalSearchScreen> {
  static const Duration _debounceDuration = Duration(milliseconds: 400);

  final DonorGlobalSearchService _searchService = DonorGlobalSearchService();
  late final TextEditingController _controller;

  Timer? _debounce;
  bool _isLoading = false;
  String _lastQuery = '';
  String? _errorMessage;
  DonorGlobalSearchResults _results = const DonorGlobalSearchResults();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _lastQuery = widget.initialQuery.trim();
    if (_lastQuery.isNotEmpty) {
      _performSearch(_lastQuery);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(_debounceDuration, () {
      _performSearch(value);
    });
  }

  Future<void> _performSearch(String value) async {
    final query = value.trim();
    if (!mounted) {
      return;
    }

    if (query.isEmpty) {
      setState(() {
        _lastQuery = '';
        _results = const DonorGlobalSearchResults();
        _errorMessage = null;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _lastQuery = query;
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await _searchService.search(query);
      if (!mounted || query != _controller.text.trim()) {
        return;
      }
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted || query != _controller.text.trim()) {
        return;
      }
      setState(() {
        _results = const DonorGlobalSearchResults();
        _errorMessage = 'Search could not be completed right now.';
        _isLoading = false;
      });
    }
  }

  Future<void> _openDonation(DonationModel donation) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DonationDetailScreen(
          donation: donation,
          onStatusChanged: () {},
        ),
      ),
    );
  }

  Future<void> _openNgo(AppUserModel ngo) async {
    final currentUser = SessionService.user;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donor session not available.')),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          donorName: currentUser.displayName,
          ngoName: ngo.displayName,
          ngoUser: ngo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9F9),
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.black,
        titleSpacing: 0,
        title: Container(
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: TextField(
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: _onQueryChanged,
            onSubmitted: _performSearch,
            decoration: InputDecoration(
              hintText: 'Search donations, NGOs, food items...',
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _controller.text.trim().isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _controller.clear();
                        _performSearch('');
                      },
                      icon: const Icon(Icons.close),
                    ),
            ),
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _results.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_lastQuery.isEmpty) {
      return const Center(
        child: Text(
          'Search donations, NGOs, food items, or locations.',
          style: TextStyle(color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No matches found for "$_lastQuery".',
            style: const TextStyle(color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final tiles = <Widget>[
      if (_results.donations.isNotEmpty) ...[
        const _ResultHeader(title: 'Donations'),
        ..._results.donations.map(
          (donation) => _ResultTile(
            icon: Icons.fastfood_rounded,
            title: donation.foodItems.isEmpty
                ? 'Donation'
                : donation.foodItems.join(', '),
            subtitle: _donationSubtitle(donation),
            onTap: () => _openDonation(donation),
          ),
        ),
      ],
      if (_results.ngos.isNotEmpty) ...[
        const _ResultHeader(title: 'NGOs'),
        ..._results.ngos.map(
          (ngo) => _ResultTile(
            icon: Icons.volunteer_activism_rounded,
            title: ngo.displayName,
            subtitle: _ngoSubtitle(ngo),
            onTap: () => _openNgo(ngo),
          ),
        ),
      ],
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: tiles.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, index) => tiles[index],
    );
  }

  String _donationSubtitle(DonationModel donation) {
    final location = donation.locationAddress ?? 'Location not available';
    final description = donation.description?.trim();
    if (description != null && description.isNotEmpty) {
      return '$description â€¢ $location';
    }
    return location;
  }

  String _ngoSubtitle(AppUserModel ngo) {
    final location = ngo.location?.address ?? ngo.address ?? 'Location not available';
    final about = ngo.organizationDescription?.trim() ?? ngo.about?.trim() ?? '';
    if (about.isNotEmpty) {
      return '$about â€¢ $location';
    }
    return location;
  }
}

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 2),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B4B3F).withValues(alpha:0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF0B4B3F),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black54,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}
