import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/hadith.dart';
import '../widgets/hadith_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<Hadith> _results = [];

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AppProvider>(context, listen: false);
    _results = provider.service.allHadiths;
  }

  void _onSearch(String q, AppProvider provider) {
    setState(() {
      _results = provider.service.search(q);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search 1001 Hadiths'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (q) => _onSearch(q, provider),
              decoration: InputDecoration(
                hintText: 'Search Arabic, English, Narrator, ID...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF0D9488)),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          _onSearch('', provider);
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? const Color(0xFF162238) : const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _searchCtrl.text.isEmpty ? 'All Hadiths' : 'Results',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_results.length} Found',
                  style: const TextStyle(color: Color(0xFF14B8A6), fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _results.isEmpty
                ? const Center(
                    child: Text(
                      'No matching Hadiths found.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _results.length > 100 ? 100 : _results.length,
                    itemBuilder: (context, index) {
                      return HadithListCard(hadith: _results[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
