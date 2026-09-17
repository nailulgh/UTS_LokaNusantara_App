import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/destination_model.dart';

/// [Modul 01 - Struktur Widget Flutter]
/// [Modul 07 & 08 - Navigasi dengan Passing Arguments]:
/// DetailPage menerima objek DestinationModel yang dikirimkan melalui
/// Navigator.pushNamed('/detail', arguments: item).
/// Data diakses dengan ModalRoute.of(context)!.settings.arguments (Modul 08).
/// [Modul 09 - StatefulWidget]: Mengelola interaksi status bookmark (like) secara reaktif dengan setState().
class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  static const String routeName = '/detail';

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  // ==========================================
  // [Design System Tokens - Sesuai Stitch Canvas]
  // ==========================================
  static const Color primaryTeal = Color(0xFF0D9488); // Primary Color
  static const Color primaryDark = Color(0xFF0F766E);
  static const Color primaryLight = Color(0xFFCCFBF1);
  static const Color accentAmber = Color(0xFFF59E0B); // Secondary Color
  static const Color tertiaryTerracotta = Color(0xFFC36D4B); // Tertiary Color
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color borderSubtle = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color favoriteRed = Color(0xFFEF4444);

  bool _isFavorite = false;
  bool _isInit = false;
  int _selectedGalleryIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Inisialisasi status favorit awal dari argumen yang diteruskan
    if (!_isInit) {
      final item =
          ModalRoute.of(context)?.settings.arguments as DestinationModel?;
      if (item != null) {
        _isFavorite = item.isFavorite;
      }
      _isInit = true;
    }
  }

  /// [Modul 09 - Interaksi Tombol Like/Bookmark]:
  /// Mengubah status favorit secara dinamis dengan setState()
  void _toggleFavorite(DestinationModel item) {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    // [Modul 13 - Feedback Interaktif SnackBar]:
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _isFavorite
                    ? '${item.name} ditambahkan ke Favorit! ❤️'
                    : '${item.name} dihapus dari Favorit.',
              ),
            ),
          ],
        ),
        backgroundColor: _isFavorite ? primaryTeal : textPrimary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // [Modul 08 - Mengambil Data Argument Navigasi]:
    final item =
        ModalRoute.of(context)?.settings.arguments as DestinationModel?;

    // Proteksi data jika halaman dibuka tanpa parameter
    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Destinasi')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, size: 48, color: textMuted),
              const SizedBox(height: 12),
              const Text('Data destinasi tidak ditemukan.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kembali ke Beranda'),
              ),
            ],
          ),
        ),
      );
    }

    final List<String> activeGallery =
        item.gallery.isNotEmpty ? item.gallery : [item.imageUrl];

    return Scaffold(
      backgroundColor: backgroundLight,
      body: Stack(
        children: [
          // 1. KONTEN UTAMA YANG DAPAT DIGULIR (SCROLLABLE)
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // [Modul 10 - Hero Photography Banner 320px]
                _buildHeroBanner(item, activeGallery),

                // [Modul 02 & 05 - Rounded Sheet Content Container]
                Transform.translate(
                  offset: const Offset(0, -24),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: surfaceWhite,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 24.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Kategori & Label Harga Utama
                        _buildCategoryAndPriceRow(item),

                        const SizedBox(height: 12),

                        // Nama Destinasi / Judul Utama (Display Scale)
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                            letterSpacing: -0.3,
                            height: 1.3,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Lokasi Jalan / Wilayah Lengkap
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: primaryTeal,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item.address,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: textMuted,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // [Modul 03, 04, 05 - Quick Stat Badges: Rating, Jam Buka, Kota]
                        _buildQuickStatBadges(item),

                        const SizedBox(height: 24),

                        // [Modul 06 & 10 - Galeri Foto Tambahan (Horizontal List)]
                        if (activeGallery.length > 1) ...[
                          _buildGalleryThumbnails(activeGallery),
                          const SizedBox(height: 24),
                        ],

                        // Tentang Destinasi (Deskripsi Komprehensif)
                        const Text(
                          'Tentang Destinasi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.description,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.65,
                            color: textMuted,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Fasilitas & Layanan Unggulan
                        if (item.facilities.isNotEmpty) ...[
                          _buildFacilitiesSection(item),
                          const SizedBox(height: 24),
                        ],

                        // [Modul 12 - GPS Coordinates & Map Integration Card]
                        _buildGpsMapCard(item),

                        // Jarak bawah agar tidak tertutup bottom action bar
                        const SizedBox(height: 90),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. FLOATING TOP APP BAR (BACK & BOOKMARK)
          _buildFloatingTopBar(item),

          // 3. FIXED BOTTOM ACTION BAR (CTA PETUNJUK ARAH)
          _buildBottomActionBar(item),
        ],
      ),
    );
  }

  /// [Modul 10 - Hero Banner]: Foto utama dengan counter galeri
  Widget _buildHeroBanner(DestinationModel item, List<String> gallery) {
    return Stack(
      children: [
        Image.network(
          gallery[_selectedGalleryIndex],
          height: 330,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 330,
            color: primaryLight,
            child: const Center(
              child: Icon(Icons.broken_image, size: 50, color: primaryTeal),
            ),
          ),
        ),

        // Gradient gelap halus di bagian atas agar tombol terlihat jelas
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 100,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.45),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Counter Foto (Kanan Bawah Banner)
        Positioned(
          bottom: 36,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.camera_alt, color: Colors.white, size: 13),
                const SizedBox(width: 5),
                Text(
                  '${_selectedGalleryIndex + 1}/${gallery.length} Foto',
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
      ],
    );
  }

  /// [Modul 07 - Navigator.pop & Modul 09 - Bookmark Floating Button]:
  Widget _buildFloatingTopBar(DestinationModel item) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // [Modul 07 - Navigator.pop]: Tombol Kembali
              _buildCircleButton(
                icon: Icons.arrow_back_ios_new,
                iconSize: 18,
                onTap: () => Navigator.pop(context),
              ),

              // Tombol Bagikan & Tombol Bookmark
              Row(
                children: [
                  _buildCircleButton(
                    icon: Icons.share_outlined,
                    iconSize: 18,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Tautan ${item.name} siap dibagikan!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  // [Modul 09 - Toggle Bookmark Favorite]:
                  _buildCircleButton(
                    icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
                    iconColor: _isFavorite ? favoriteRed : textPrimary,
                    iconSize: 20,
                    onTap: () => _toggleFavorite(item),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = textPrimary,
    double iconSize = 18,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: surfaceWhite.withValues(alpha: 0.92),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: iconSize),
      ),
    );
  }

  /// [Modul 02, 03 - Row & SpaceBetween]: Kategori dan Harga
  Widget _buildCategoryAndPriceRow(DestinationModel item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: primaryLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            item.category.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: primaryDark,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Text(
          item.formattedPrice,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: primaryTeal,
          ),
        ),
      ],
    );
  }

  /// [Modul 04 & 05 - Row, Expanded, & Card Stat Badges]:
  Widget _buildQuickStatBadges(DestinationModel item) {
    return Row(
      children: [
        // 1. Rating Badge (Secondary Amber)
        Expanded(
          child: _buildBadgeCard(
            icon: Icons.star_rounded,
            iconColor: accentAmber,
            title: '${item.rating} / 5.0',
            subtitle: '${item.reviewCount} ulasan',
          ),
        ),
        const SizedBox(width: 8),

        // 2. Jam Operasional (Primary Teal)
        Expanded(
          child: _buildBadgeCard(
            icon: Icons.access_time_filled_rounded,
            iconColor: primaryTeal,
            title: 'Jam Buka',
            subtitle: item.openHours,
          ),
        ),
        const SizedBox(width: 8),

        // 3. Wilayah (Tertiary Terracotta)
        Expanded(
          child: _buildBadgeCard(
            icon: Icons.explore,
            iconColor: tertiaryTerracotta,
            title: item.district,
            subtitle: item.city,
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: backgroundLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderSubtle),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: textMuted,
            ),
          ),
        ],
      ),
    );
  }

  /// [Modul 06 - Horizontal Gallery ListView]:
  Widget _buildGalleryThumbnails(List<String> gallery) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Galeri Foto',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 64,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: gallery.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedGalleryIndex == index;
              return Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedGalleryIndex = index;
                    });
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? primaryTeal : borderSubtle,
                        width: isSelected ? 2.5 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        gallery[index],
                        width: 80,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// [Modul 02 - Wrap Widget untuk Fasilitas]:
  Widget _buildFacilitiesSection(DestinationModel item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fasilitas & Layanan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: item.facilities.map((fac) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: backgroundLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderSubtle),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 14,
                    color: primaryTeal,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    fac,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// [Modul 12 - GPS Coordinates Card]:
  Widget _buildGpsMapCard(DestinationModel item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryLight.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryTeal.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryTeal.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.near_me,
                  color: primaryDark,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Koordinat GPS Presisi',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryDark,
                    ),
                  ),
                  Text(
                    'Terintegrasi Layanan Geolocator',
                    style: TextStyle(fontSize: 11, color: textMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: surfaceWhite,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderSubtle),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Latitude / Longitude:',
                      style: TextStyle(fontSize: 10, color: textMuted),
                    ),
                    Text(
                      '${item.latitude.toStringAsFixed(6)}, ${item.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 16, color: primaryTeal),
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(
                        text: '${item.latitude}, ${item.longitude}',
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Koordinat berhasil disalin ke clipboard!'),
                        duration: Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Membuka peta Google Maps ke koordinat ${item.latitude}, ${item.longitude}...',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.map_outlined, size: 16, color: primaryDark),
              label: const Text(
                'Buka di Google Maps',
                style: TextStyle(
                  color: primaryDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: primaryTeal),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// [Modul 04 - Bottom Action Bar dengan Expanded]:
  Widget _buildBottomActionBar(DestinationModel item) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: surfaceWhite,
          border: const Border(
            top: BorderSide(color: borderSubtle, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Harga Tiket / Biaya Masuk
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Biaya / Tiket',
                  style: TextStyle(fontSize: 11, color: textMuted),
                ),
                Text(
                  item.formattedPrice,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryDark,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),

            // Tombol CTA Utama "Petunjuk Arah"
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Memulai panduan navigasi ke ${item.name}!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.navigation_rounded, color: Colors.white),
                label: const Text(
                  'Petunjuk Arah',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryTeal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
