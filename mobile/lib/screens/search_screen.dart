import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/hadith.dart';
import '../models/category.dart';
import '../widgets/hadith_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  ThematicCategory _selectedCategory = ThematicCategory.categories.first;
  bool _bookmarkedOnly = false;
  List<Hadith> _results = [];

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AppProvider>(context, listen: false);
    _filter(provider);
  }

  void _filter(AppProvider provider) {
    setState(() {
      _results = provider.service.search(
        _searchCtrl.text,
        category: _selectedCategory,
        bookmarkedIds: provider.bookmarks,
        bookmarkedOnly: _bookmarkedOnly,
      );
    });
  }

  void _onSearchChanged(String q, AppProvider provider) {
    _filter(provider);
  }

  void _onSearchSubmitted(String q, AppProvider provider) {
    if (q.trim().isNotEmpty) {
      provider.addRecentSearch(q);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          // Search Input Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (q) => _onSearchChanged(q, provider),
              onSubmitted: (q) => _onSearchSubmitted(q, provider),
              decoration: InputDecoration(
                hintText: 'Search Arabic, English, Narrator, Chapter, ID...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF0D9488)),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          _filter(provider);
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

          // Horizontal Thematic Category Filter Chips
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: ThematicCategory.categories.length + 1,
              itemBuilder: (context, index) {
                // Last item is Bookmarked Only filter
                if (index == ThematicCategory.categories.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      selected: _bookmarkedOnly,
                      showCheckmark: false,
                      avatar: Icon(
                        _bookmarkedOnly ? Icons.bookmark : Icons.bookmark_border,
                        size: 16,
                        color: _bookmarkedOnly ? Colors.white : const Color(0xFFF59E0B),
                      ),
                      label: const Text('Bookmarked'),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _bookmarkedOnly ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[800]),
                      ),
                      backgroundColor: isDark ? const Color(0xFF162238) : const Color(0xFFF1F5F9),
                      selectedColor: const Color(0xFFF59E0B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onSelected: (val) {
                        setState(() => _bookmarkedOnly = val);
                        _filter(provider);
                      },
                    ),
                  );
                }

                final cat = ThematicCategory.categories[index];
                final isSelected = _selectedCategory.id == cat.id;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    selected: isSelected,
                    showCheckmark: false,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(cat.icon, style: const TextStyle(fontSize: 13)),
                        const SizedBox(width: 6),
                        Text(cat.titleEn),
                      ],
                    ),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[800]),
                    ),
                    backgroundColor: isDark ? const Color(0xFF162238) : const Color(0xFFF1F5F9),
                    selectedColor: cat.color,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onSelected: (_) {
                      setState(() => _selectedCategory = cat);
                      _filter(provider);
                    },
                  ),
                );
              },
            ),
          ),

          // Recent Searches (if search text is empty and recent searches exist)
          if (_searchCtrl.text.isEmpty && provider.recentSearches.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Searches',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  InkWell(
                    onTap: () => provider.clearRecentSearches(),
                    child: const Text(
                      'Clear',
                      style: TextStyle(fontSize: 12, color: Color(0xFF14B8A6), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: provider.recentSearches.length,
                itemBuilder: (context, index) {
                  final term = provider.recentSearches[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ActionChip(
                      avatar: const Icon(Icons.history, size: 14, color: Colors.grey),
                      label: Text(term, style: const TextStyle(fontSize: 11)),
                      backgroundColor: isDark ? const Color(0xFF111B2D) : const Color(0xFFE2E8F0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      onPressed: () {
                        _searchCtrl.text = term;
                        _filter(provider);
                      },
                    ),
                  );
                },
              ),
            ),
          ],

          // Results Counter
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _searchCtrl.text.isEmpty
                      ? (_selectedCategory.id == 'all' ? 'All Hadiths' : _selectedCategory.titleEn)
                      : 'Results for "${_searchCtrl.text}"',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_results.length} Found',
                    style: const TextStyle(
                      color: Color(0xFF14B8A6),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Results List
          Expanded(
            child: _results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text(
                          'No matching Hadiths found.',
                          style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Try searching for a different keyword or category.',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      return HadithListCard(
                        hadith: _results[index],
                        highlightQuery: _searchCtrl.text,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
