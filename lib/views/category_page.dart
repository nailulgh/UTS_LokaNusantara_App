import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/destination_model.dart';
import 'detail_page.dart';

/// [Modul 01 - Struktur Widget Flutter]
/// [Modul 07 - Navigasi Antar Halaman & Routing]:
/// CategoryPage menampilkan katalog destinasi wisata dan kuliner dengan filter kategori,
/// pengurutan dinamis, serta navigasi ke halaman Detail dengan passing argument (Modul 08).
/// [Modul 09 - StatefulWidget]: Mengelola state lokal filter kategori, opsi sort, dan bookmark.
class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  static const String routeName = '/category';

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  // ==========================================
  // [Design System Tokens - Berdasarkan Stitch]
  // ==========================================
  static const Color primaryTeal = Color(0xFF0D9488); // Primary
  static const Color primaryDark = Color(0xFF0F766E);
  static const Color primaryLight = Color(0xFFCCFBF1);
  static const Color accentAmber = Color(0xFFF59E0B); // Secondary
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color borderSubtle = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color favoriteRed = Color(0xFFEF4444);

  // [Modul 09 - State Data]:
  List<DestinationModel> _allDestinations = [];
  List<DestinationModel> _displayedDestinations = [];
  bool _isLoading = true;
  String _selectedCategory = 'Semua';
  String _activeSort = 'Populer';
  final TextEditingController _searchController = TextEditingController();

  // Kategori sesuai desain Stitch Wireframe dengan Icon & Counter
  final List<Map<String, dynamic>> _categoryTabs = [
    {'name': 'Semua', 'icon': '✨'},
    {'name': 'Wisata Alam', 'icon': '🏔️'},
    {'name': 'Budaya & Edukasi', 'icon': '🏛️'},
    {'name': 'Wahana Rekreasi', 'icon': '🎡'},
    {'name': 'Kuliner Legendaris', 'icon': '🍜'},
    {'name': 'Kafe & Santai', 'icon': '☕'},
  ];

  final List<String> _sortOptions = ['Populer', 'Terdekat', 'Harga', 'Rating > 4.6'];

  @override
  void initState() {
    super.initState();
    // [Modul 10 - Membaca data JSON lokal]:
    _loadDestinations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// [Modul 10 - JSON Deserialization]:
  /// Mengambil data dari assets/data/destinations.json
  Future<void> _loadDestinations() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/destinations.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      final List<DestinationModel> loaded = jsonList
          .map((item) => DestinationModel.fromJson(item as Map<String, dynamic>))
          .toList();

      setState(() {
        _allDestinations = loaded;
        _isLoading = false;
        _filterAndSortData();
      });
    } catch (e) {
      debugPrint('Gagal memuat data destinasi: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Logika filter kategori, kata kunci pencarian, dan pengurutan
  void _filterAndSortData() {
    final query = _searchController.text.toLowerCase().trim();
    List<DestinationModel> list = List.from(_allDestinations);

    // 1. Filter Kategori
    if (_selectedCategory != 'Semua') {
      list = list.where((item) => item.category == _selectedCategory).toList();
    }

    // 2. Filter Pencarian
    if (query.isNotEmpty) {
      list = list.where((item) {
        return item.name.toLowerCase().contains(query) ||
            item.district.toLowerCase().contains(query) ||
            item.city.toLowerCase().contains(query) ||
            item.description.toLowerCase().contains(query);
      }).toList();
    }

    // 3. Pengurutan (Sorting)
    if (_activeSort == 'Populer') {
      list.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    } else if (_activeSort == 'Harga') {
      list.sort((a, b) => a.ticketPrice.compareTo(b.ticketPrice));
    } else if (_activeSort == 'Rating > 4.6') {
      list = list.where((item) => item.rating >= 4.6).toList();
      list.sort((a, b) => b.rating.compareTo(a.rating));
    }

    setState(() {
      _displayedDestinations = list;
    });
  }

  /// [Modul 09 - Bookmark Toggle]:
  void _toggleBookmark(String id) {
    setState(() {
      final index = _allDestinations.indexWhere((item) => item.id == id);
      if (index != -1) {
        final current = _allDestinations[index].isFavorite;
        _allDestinations[index] =
            _allDestinations[index].copyWith(isFavorite: !current);
        _filterAndSortData();
      }
    });

    // [Modul 13 - Interaktivitas SnackBar]:
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Status favorit diperbarui.'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  int _countByCategory(String category) {
    if (category == 'Semua') return _allDestinations.length;
    return _allDestinations.where((e) => e.category == category).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      // [Modul 07 - AppBar Navigasi]:
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryTeal))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // 1. Kolom Pencarian Cepat
                _buildSearchInput(),

                const SizedBox(height: 12),

                // 2. Filter Kategori Horizontal (Stitch Style)
                _buildCategoryChips(),

                const SizedBox(height: 12),

                // 3. Tab Pengurutan & Counter Hasil
                _buildSortAndCounterBar(),

                const SizedBox(height: 8),

                // 4. Feed Kartu Destinasi (Modul 06 - ListView.builder)
                Expanded(
                  child: _displayedDestinations.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: _displayedDestinations.length,
                          itemBuilder: (context, index) {
                            final item = _displayedDestinations[index];
                            return _buildDestinationCard(item);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  /// [Modul 02, 03, & 07 - Top App Bar]:
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: surfaceWhite,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: textPrimary, size: 18),
        // [Modul 07 - Navigator.pop]: Kembali ke halaman sebelumnya
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Eksplor Wisata & Kuliner',
        style: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.2,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.tune_outlined, color: primaryTeal, size: 20),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Filter kustom diterapkan.'),
                duration: Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: borderSubtle, height: 1),
      ),
    );
  }

  /// [Modul 10 - Search Input Widget]:
  Widget _buildSearchInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderSubtle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (_) => _filterAndSortData(),
          decoration: InputDecoration(
            hintText: 'Cari destinasi, kuliner, lokasi...',
            hintStyle: const TextStyle(color: textMuted, fontSize: 13),
            prefixIcon: const Icon(Icons.search, color: primaryTeal, size: 20),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, size: 16, color: textMuted),
                    onPressed: () {
                      _searchController.clear();
                      _filterAndSortData();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }

  /// [Modul 02 & 06 - Category Chips Selector dengan Counter]:
  Widget _buildCategoryChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categoryTabs.length,
        itemBuilder: (context, index) {
          final cat = _categoryTabs[index];
          final String catName = cat['name'] as String;
          final String catIcon = cat['icon'] as String;
          final isSelected = _selectedCategory == catName;
          final int count = _countByCategory(catName);

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedCategory = catName;
                });
                _filterAndSortData();
              },
              borderRadius: BorderRadius.circular(50),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? primaryTeal : surfaceWhite,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: isSelected ? primaryTeal : borderSubtle,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: primaryTeal.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(catIcon, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 6),
                    Text(
                      '$catName ($count)',
                      style: TextStyle(
                        color: isSelected ? Colors.white : textPrimary,
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// [Modul 02, 03 - Row Alignment & Sort Option Tabs]:
  Widget _buildSortAndCounterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Counter Hasil
          Text(
            '${_displayedDestinations.length} Destinasi',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),

          // Pilihan Pengurutan (Pill Button)
          Row(
            children: _sortOptions.map((opt) {
              final isSelected = _activeSort == opt;
              return Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _activeSort = opt;
                    });
                    _filterAndSortData();
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryLight.withValues(alpha: 0.8)
                          : surfaceWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? primaryTeal : borderSubtle,
                      ),
                    ),
                    child: Text(
                      opt,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? primaryDark : textMuted,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// [Modul 04 & 05 - Card Item Destinasi Berstruktur Rapi]:
  Widget _buildDestinationCard(DestinationModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderSubtle),
        ),
        color: surfaceWhite,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            // [Modul 07 & 08 - Navigasi dengan Arguments]:
            Navigator.pushNamed(
              context,
              DetailPage.routeName,
              arguments: item,
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Gambar Banner & Badges Overlay
              Stack(
                children: [
                  Image.network(
                    item.imageUrl,
                    height: 165,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 165,
                      color: primaryLight,
                      child: const Center(
                        child: Icon(Icons.image, color: primaryTeal, size: 36),
                      ),
                    ),
                  ),

                  // Rating Badge
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: accentAmber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${item.rating} (${item.reviewCount})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bookmark Button
                  Positioned(
                    top: 10,
                    right: 10,
                    child: InkWell(
                      onTap: () => _toggleBookmark(item.id),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: surfaceWhite.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: item.isFavorite ? favoriteRed : textMuted,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // 2. Informasi Detail Destinasi
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kategori & Harga
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: primaryLight.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.category.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: primaryDark,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        Text(
                          item.formattedPrice,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: primaryTeal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Judul Destinasi
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Lokasi Kecamatan & Kota
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: textMuted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${item.district}, ${item.city}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Lihat Detail',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: primaryTeal,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 10,
                          color: primaryTeal,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 54, color: textMuted.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          const Text(
            'Tidak ada destinasi yang cocok.',
            style: TextStyle(fontSize: 14, color: textMuted),
          ),
        ],
      ),
    );
  }
}
