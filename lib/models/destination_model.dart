class DestinationModel {
  final String id;
  final String name;
  final String category;
  final String categoryId;
  final int ticketPrice;
  final String formattedPrice;
  final double rating;
  final int reviewCount;
  final String openHours;
  final String address;
  final String city;
  final String district;
  final double latitude;
  final double longitude;
  final String imageUrl;
  final List<String> gallery;
  final String description;
  final List<String> facilities;
  final bool isFavorite;
  final String phone;

  DestinationModel({
    required this.id,
    required this.name,
    required this.category,
    required this.categoryId,
    required this.ticketPrice,
    required this.formattedPrice,
    required this.rating,
    required this.reviewCount,
    required this.openHours,
    required this.address,
    required this.city,
    required this.district,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    required this.gallery,
    required this.description,
    required this.facilities,
    this.isFavorite = false,
    required this.phone,
  });

  factory DestinationModel.fromJson(Map<String, dynamic> json) {
    return DestinationModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Tanpa Nama',
      category: json['category'] as String? ?? 'Umum',
      categoryId: json['category_id'] as String? ?? 'all',
      ticketPrice: (json['ticket_price'] as num?)?.toInt() ?? 0,
      formattedPrice: json['formatted_price'] as String? ?? 'Gratis',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      openHours: json['open_hours'] as String? ?? 'Setiap Hari',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      district: json['district'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url'] as String? ?? '',
      gallery: (json['gallery'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      description: json['description'] as String? ?? '',
      facilities: (json['facilities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isFavorite: json['is_favorite'] as bool? ?? false,
      phone: json['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'category_id': categoryId,
      'ticket_price': ticketPrice,
      'formatted_price': formattedPrice,
      'rating': rating,
      'review_count': reviewCount,
      'open_hours': openHours,
      'address': address,
      'city': city,
      'district': district,
      'latitude': latitude,
      'longitude': longitude,
      'image_url': imageUrl,
      'gallery': gallery,
      'description': description,
      'facilities': facilities,
      'is_favorite': isFavorite,
      'phone': phone,
    };
  }

  DestinationModel copyWith({
    String? id,
    String? name,
    String? category,
    String? categoryId,
    int? ticketPrice,
    String? formattedPrice,
    double? rating,
    int? reviewCount,
    String? openHours,
    String? address,
    String? city,
    String? district,
    double? latitude,
    double? longitude,
    String? imageUrl,
    List<String>? gallery,
    String? description,
    List<String>? facilities,
    bool? isFavorite,
    String? phone,
  }) {
    return DestinationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      formattedPrice: formattedPrice ?? this.formattedPrice,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      openHours: openHours ?? this.openHours,
      address: address ?? this.address,
      city: city ?? this.city,
      district: district ?? this.district,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      gallery: gallery ?? this.gallery,
      description: description ?? this.description,
      facilities: facilities ?? this.facilities,
      isFavorite: isFavorite ?? this.isFavorite,
      phone: phone ?? this.phone,
    );
  }
}
