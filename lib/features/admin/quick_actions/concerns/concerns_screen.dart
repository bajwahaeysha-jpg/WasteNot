import 'package:flutter/material.dart';
import 'package:wastenot/services/concern_services.dart';

class ConcernsScreen extends StatefulWidget {
  const ConcernsScreen({super.key});

  @override
  State<ConcernsScreen> createState() => _ConcernsScreenState();
}

class _ConcernsScreenState extends State<ConcernsScreen> {
  static const Color mainGreen = Color(0xFF0B4B3F);

  final ConcernService _concernService = ConcernService();
  String? _deletingConcernId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: mainGreen,
        elevation: 0,
        title: const Text(
          'Concerns',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<ConcernModel>>(
        stream: _concernService.getAllConcerns(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Unable to load concerns right now.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final concerns = snapshot.data ?? const <ConcernModel>[];
          if (concerns.isEmpty) {
            return const Center(
              child: Text(
                'No concerns available',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: concerns.length,
            itemBuilder: (_, index) => _concernCard(concerns[index]),
          );
        },
      ),
    );
  }

  Widget _concernCard(ConcernModel concern) {
    final isDeleting = _deletingConcernId == concern.concernId;
    final imageUrl = concern.imageUrl.trim();
    final ngoName = concern.ngoName.trim().isEmpty ? 'Unknown NGO' : concern.ngoName;

    return GestureDetector(
      onLongPress: isDeleting ? null : () => _confirmDelete(concern),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _imagePlaceholder(),
                    )
                  : _imagePlaceholder(),
            ),
            if (isDeleting)
              const LinearProgressIndicator(
                minHeight: 2,
                color: mainGreen,
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    concern.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    concern.message,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Concern raised by $ngoName',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: mainGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        color: Colors.grey.shade500,
        size: 36,
      ),
    );
  }

  void _confirmDelete(ConcernModel concern) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Concern'),
        content: const Text(
          'This concern will be permanently removed. Do you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _deletingConcernId == concern.concernId
                ? null
                : () async {
                    Navigator.pop(context);
                    await _deleteConcern(concern);
                  },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteConcern(ConcernModel concern) async {
    setState(() => _deletingConcernId = concern.concernId);

    try {
      await _concernService.deleteConcern(
        concern.concernId,
        deletedByAdmin: true,
        reason: 'Removed by admin review',
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Concern removed successfully.')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Concern could not be removed.')),
      );
    } finally {
      if (mounted) {
        setState(() => _deletingConcernId = null);
      }
    }
  }
}
