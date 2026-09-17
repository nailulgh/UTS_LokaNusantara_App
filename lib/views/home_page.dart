import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/destination_model.dart';

/// [Modul 01 - Pengenalan Flutter & Struktur Widget]
/// [Modul 09 - StatefulWidget]: HomePage menggunakan StatefulWidget karena memiliki
/// variabel state yang berubah secara dinamis berdasarkan interaksi pengguna:
/// pencarian teks, filter kategori aktif, data destinasi lokal, dan status bookmark.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const String routeName = '/';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // [Design System Tokens - Berdasarkan Stitch Design System]
  static const Color primaryTeal = Color(0xFF0D9488);
  static const Color primaryDark = Color(0xFF0F766E);
  static const Color primaryLight = Color(0xFFCCFBF1);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color borderSubtle = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color favoriteRed = Color(0xFFEF4444);

  // [Modul 09 - State Management]: Variabel state
  List<DestinationModel> _allDestinations = [];
  List<DestinationModel> _filteredDestinations = [];
  bool _isLoading = true;
  String _selectedCategory = 'Semua';
  final TextEditingController _searchController = TextEditingController();

  // [Modul 12 - Akses Lokasi dengan GPS]: Simulasi info geolokasi perangkat
  String _currentKecamatan = 'Klojen';
  String _currentKota = 'Kota Malang';

  // Daftar kategori sesuai topik perancangan
  final List<String> _categories = [
    'Semua',
    'Wisata Alam',
    'Budaya & Edukasi',
    'Wahana Rekreasi',
    'Kuliner Legendaris',
    'Kafe & Santai',
  ];

  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    // [Modul 10 - Integrasi Data JSON]: Muat data lokal saat widget pertama kali diinisialisasi
    _loadDestinationsFromJson();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// [Modul 10 - Deserialisasi JSON]:
  /// Mengambil data dari assets/data/destinations.json dan mengubahnya menjadi
  /// List objek DestinationModel menggunakan factory constructor fromJson.
  Future<void> _loadDestinationsFromJson() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/destinations.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      final List<DestinationModel> loadedList = jsonList
          .map((item) => DestinationModel.fromJson(item as Map<String, dynamic>))
          .toList();

      // [Modul 09 - setState()]: Memperbarui state agar UI dirender ulang
      setState(() {
        _allDestinations = loadedList;
        _filteredDestinations = loadedList;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Gagal memuat file JSON: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Logika filter gabungan pencarian kata kunci dan kategori
  void _applyFilter() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredDestinations = _allDestinations.where((item) {
        final matchesCategory =
            _selectedCategory == 'Semua' || item.category == _selectedCategory;
        final matchesQuery = query.isEmpty ||
            item.name.toLowerCase().contains(query) ||
            item.district.toLowerCase().contains(query) ||
            item.city.toLowerCase().contains(query) ||
            item.category.toLowerCase().contains(query);
        return matchesCategory && matchesQuery;
      }).toList();
    });
  }

  /// [Modul 09 - Like/Bookmark Toggle]:
  /// Mengubah status favorit destinasi secara dinamis
  void _toggleBookmark(String id) {
    setState(() {
      final index = _allDestinations.indexWhere((item) => item.id == id);
      if (index != -1) {
        final currentFav = _allDestinations[index].isFavorite;
        _allDestinations[index] =
            _allDestinations[index].copyWith(isFavorite: !currentFav);
        _applyFilter();
      }
    });

    // [Modul 13 - Feedback Interaktif SnackBar]
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Daftar favorit berhasil diperbarui!'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// [Modul 12 - GPS Refresh]: Simulasi pembaruan lokasi perangkat
  void _refreshLocation() {
    setState(() {
      _currentKecamatan = 'Batu';
      _currentKota = 'Kota Wisata Batu';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lokasi GPS disinkronkan: Kota Wisata Batu'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: primaryTeal),
              )
            : RefreshIndicator(
                color: primaryTeal,
                onRefresh: _loadDestinationsFromJson,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Header Lokasi GPS & Notifikasi
                        _buildLocationHeader(),

                        const SizedBox(height: 16),

                        // 2. Greeting & Search Bar
                        _buildHeroSearchSection(),

                        const SizedBox(height: 20),

                        // 3. Filter Kategori (Horizontal Chips)
                        _buildCategoryFilter(),

                        const SizedBox(height: 24),

                        // 4. Seksi Destinasi Populer (Horizontal Carousel)
                        _buildFeaturedSection(),

                        const SizedBox(height: 24),

                        // 5. Seksi Kuliner Legendaris (Vertical Feed)
                        _buildCulinarySection(),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
      ),
      // 6. Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// [Modul 02, 03, & 12 - Row, Column & GPS Header]:
  /// Menampilkan chip lokasi pengguna saat ini dengan ikon pin GPS
  Widget _buildLocationHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // GPS Location Pill
          InkWell(
            onTap: _refreshLocation,
            borderRadius: BorderRadius.circular(50),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: primaryLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: primaryTeal.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on,
                    color: primaryTeal,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$_currentKecamatan, $_currentKota',
                    style: const TextStyle(
                      color: primaryDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: primaryDark,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),

          // Tombol Notifikasi / Aksi Kanan
          Container(
            decoration: BoxDecoration(
              color: surfaceWhite,
              shape: BoxShape.circle,
              border: Border.all(color: borderSubtle),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_none_outlined),
              color: textPrimary,
              iconSize: 22,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tidak ada notifikasi baru.'),
                    duration: Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// [Modul 02 & 10 - Greeting & Search Input]:
  Widget _buildHeroSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Halo, Petualang! 🌿',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textMuted,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Eksplor Wisata & Kuliner',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),

          // [Modul 10 - TextField Search Bar]:
          Container(
            decoration: BoxDecoration(
              color: surfaceWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderSubtle),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _applyFilter(),
              decoration: InputDecoration(
                hintText: 'Cari destinasi, bakso, kafe...',
                hintStyle: const TextStyle(color: textMuted, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: primaryTeal),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilter();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// [Modul 02 & 06 - Horizontal Category Chips]:
  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
                _applyFilter();
              },
              borderRadius: BorderRadius.circular(50),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? primaryTeal : surfaceWhite,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: isSelected ? primaryTeal : borderSubtle,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: primaryTeal.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// [Modul 04, 05 & 06 - Destinasi Populer Horizontal Cards]:
  Widget _buildFeaturedSection() {
    final featuredItems = _filteredDestinations
        .where((item) => item.rating >= 4.7)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Destinasi Populer ⭐',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              InkWell(
                onTap: () {
                  // [Modul 07 - Navigasi]: Pindah ke halaman Kategori/Eksplor
                  Navigator.pushNamed(context, '/category');
                },
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: primaryTeal,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        featuredItems.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text('Tidak ada destinasi yang cocok.'),
              )
            : SizedBox(
                height: 270,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: featuredItems.length,
                  itemBuilder: (context, index) {
                    final item = featuredItems[index];
                    return _buildFeaturedCard(item);
                  },
                ),
              ),
      ],
    );
  }

  /// [Modul 05 - Widget Card & ClipRRect]:
  Widget _buildFeaturedCard(DestinationModel item) {
    return Container(
      width: 210,
      margin: const EdgeInsets.only(right: 14, bottom: 6),
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
            // [Modul 07 & 08 - Navigasi dengan Argument]:
            // Membuka halaman detail dan meneruskan objek destinasi
            Navigator.pushNamed(
              context,
              '/detail',
              arguments: item,
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto Destinasi dengan overlay bookmark dan rating
              Stack(
                children: [
                  Image.network(
                    item.imageUrl,
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 130,
                      color: primaryLight,
                      child: const Center(
                        child: Icon(Icons.broken_image, color: primaryTeal),
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
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: accentAmber,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.rating.toString(),
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
                  // [Modul 09 - Tombol Like/Bookmark]:
                  Positioned(
                    top: 8,
                    right: 8,
                    child: InkWell(
                      onTap: () => _toggleBookmark(item.id),
                      borderRadius: BorderRadius.circular(50),
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
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Detail Teks
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge Kategori
                    Text(
                      item.category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: primaryTeal,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Nama Destinasi
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Lokasi Kecamatan & Kota
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: textMuted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${item.district}, ${item.city}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Harga Tiket
                    Text(
                      item.formattedPrice,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: primaryDark,
                      ),
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

  /// [Modul 05 & 06 - Seksi Kuliner Legendaris]:
  Widget _buildCulinarySection() {
    final culinaryItems = _filteredDestinations
        .where((item) =>
            item.category == 'Kuliner Legendaris' ||
            item.category == 'Kafe & Santai')
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kuliner Legendaris Khas 🍜',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _selectedCategory = 'Kuliner Legendaris';
                  });
                  _applyFilter();
                },
                child: const Text(
                  'Filter Kuliner',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: primaryTeal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // [Modul 06 - ListView.builder Vertikal]:
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: culinaryItems.length,
            itemBuilder: (context, index) {
              final item = culinaryItems[index];
              return _buildCulinaryListCard(item);
            },
          ),
        ],
      ),
    );
  }

  /// [Modul 02, 04, 05 - Row, Expanded, & Card Kuliner]:
  Widget _buildCulinaryListCard(DestinationModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            Navigator.pushNamed(
              context,
              '/detail',
              arguments: item,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                // Thumbnail Gambar Bersudut Melengkung
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    item.imageUrl,
                    width: 84,
                    height: 84,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 84,
                      height: 84,
                      color: primaryLight,
                      child: const Icon(Icons.restaurant, color: primaryTeal),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // [Modul 04 - Expanded Info Teks]:
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => _toggleBookmark(item.id),
                            child: Icon(
                              item.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: item.isFavorite ? favoriteRed : textMuted,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 12,
                            color: textMuted,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.openHours,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.formattedPrice,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: primaryTeal,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: accentAmber,
                                size: 16,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${item.rating}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                            ],
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
      ),
    );
  }

  /// [Modul 04 & 05 - Bottom Navigation Bar]:
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: surfaceWhite,
        border: const Border(
          top: BorderSide(color: borderSubtle, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
          if (index == 1) {
            Navigator.pushNamed(context, '/category');
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: surfaceWhite,
        selectedItemColor: primaryTeal,
        unselectedItemColor: textMuted,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 11,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Eksplor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_outline),
            activeIcon: Icon(Icons.bookmark),
            label: 'Disimpan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Akun',
          ),
        ],
      ),
    );
  }
}
