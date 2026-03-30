import 'package:flutter/material.dart';

import 'admin_search_registry.dart';

class AdminGlobalSearchScreen extends StatefulWidget {
  const AdminGlobalSearchScreen({
    super.key,
    required this.user,
  });

  final Map<String, dynamic> user;

  @override
  State<AdminGlobalSearchScreen> createState() =>
      _AdminGlobalSearchScreenState();
}

class _AdminGlobalSearchScreenState extends State<AdminGlobalSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = buildAdminSearchItems(widget.user);
    final normalizedQuery = _query.trim().toLowerCase();
    final results = normalizedQuery.isEmpty
        ? items
        : items.where((item) {
            final searchableText = [
              item.title,
              ...item.keywords,
            ].join(' ').toLowerCase();
            return searchableText.contains(normalizedQuery);
          }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        titleSpacing: 0,
        title: Container(
          height: 46,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F5F4),
            borderRadius: BorderRadius.circular(26),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Search admin screens...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.trim().isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      icon: const Icon(Icons.close),
                    ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ),
      body: results.isEmpty
          ? const Center(
              child: Text(
                'No matching admin pages found.',
                style: TextStyle(color: Colors.black54),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: results.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = results[index];
                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    leading: CircleAvatar(
                      backgroundColor:
                          const Color(0xFF0F4C45).withValues(alpha: 0.10),
                      child: Icon(item.icon, color: const Color(0xFF0F4C45)),
                    ),
                    title: Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: item.builder),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
