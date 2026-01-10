import 'package:flutter/material.dart';
import '../../../../core/search/search_registry.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  String query = "";

  @override
Widget build(BuildContext context) {
  final results = query.isEmpty
      ? []
      : globalSearchItems
          .where((item) =>
              item.title.toLowerCase().contains(query.toLowerCase()))
          .toList();

  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      title: TextField(
        autofocus: true,
        onChanged: (val) => setState(() => query = val),
        decoration: const InputDecoration(
          hintText: "Search anything...",
          border: InputBorder.none,
        ),
      ),
    ),
    body: results.isEmpty
        ? const Center(
            child: Text(
              "Start typing to search",
              style: TextStyle(color: Colors.black54),
            ),
          )
        : ListView.builder(
            itemCount: results.length,
            itemBuilder: (_, i) {
              final item = results[i];
              return ListTile(
                leading: Icon(item.icon),
                title: Text(item.title),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => item.page),
                  );
                },
              );
            },
          ),
  );
}

}
