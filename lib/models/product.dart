import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String? id;
  final String? name;
  final String? description;
  final double? price;
  final String? category;
  final String? subCategory;
  final List<String>? colors;
  final List<String>? sizes;
  final List<String>? images;
  final String? brand;
  final int? stock;
  final double? rating;
  final int? reviewCount;
  final bool? isFeatured;
  final bool? isNew;
  final bool? isBestSelling;
  final bool? isOnSale;
  final double? discount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    this.id,
    this.name,
    this.description,
    this.price,
    this.category,
    this.subCategory,
    this.colors,
    this.sizes,
    this.images,
    this.brand,
    this.stock,
    this.rating,
    this.reviewCount,
    this.isFeatured,
    this.isNew,
    this.isBestSelling,
    this.isOnSale,
    this.discount,
    this.createdAt,
    this.updatedAt,
  });

  // Create a Product from Firestore document
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Document data is null");
    }

    return Product(
      id: doc.id,
      name: data['name'],
      description: data['description'],
      price: (data['price'] as num?)?.toDouble(),
      category: data['category'],
      subCategory: data['subCategory'],
      colors: List<String>.from(data['colors'] ?? []),
      sizes: List<String>.from(data['sizes'] ?? []),
      images: List<String>.from(data['images'] ?? []),
      brand: data['brand'],
      stock: data['stock'],
      rating: (data['rating'] as num?)?.toDouble(),
      reviewCount: data['reviewCount'],
      isFeatured: data['isFeatured'],
      isNew: data['isNew'],
      isBestSelling: data['isBestSelling'],
      isOnSale: data['isOnSale'],
      discount: (data['discount'] as num?)?.toDouble(),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Create a Product from a Map
  factory Product.fromMap(Map<String, dynamic> data) {
    return Product(
      name: data['name'],
      description: data['description'],
      price: (data['price'] as num?)?.toDouble(),
      category: data['category'],
      subCategory: data['subCategory'],
      colors: List<String>.from(data['colors'] ?? []),
      sizes: List<String>.from(data['sizes'] ?? []),
      images: List<String>.from(data['images'] ?? []),
      brand: data['brand'],
      stock: data['stock'],
      rating: (data['rating'] as num?)?.toDouble(),
      reviewCount: data['reviewCount'],
      isFeatured: data['isFeatured'],
      isNew: data['isNew'],
      isBestSelling: data['isBestSelling'],
      isOnSale: data['isOnSale'],
      discount: (data['discount'] as num?)?.toDouble(),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }
  
  // Create a Product from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product.fromMap(json);
  }

  // Convert Product to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'subCategory': subCategory,
      'colors': colors,
      'sizes': sizes,
      'images': images,
      'brand': brand,
      'stock': stock,
      'rating': rating,
      'reviewCount': reviewCount,
      'isFeatured': isFeatured,
      'isNew': isNew,
      'isBestSelling': isBestSelling,
      'isOnSale': isOnSale,
      'discount': discount,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': DateTime.now(),
    };
  }

  // Create a copy of the Product with updated fields
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    String? subCategory,
    List<String>? colors,
    List<String>? sizes,
    List<String>? images,
    String? brand,
    int? stock,
    double? rating,
    int? reviewCount,
    bool? isFeatured,
    bool? isNew,
    bool? isBestSelling,
    bool? isOnSale,
    double? discount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      colors: colors ?? this.colors,
      sizes: sizes ?? this.sizes,
      images: images ?? this.images,
      brand: brand ?? this.brand,
      stock: stock ?? this.stock,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isFeatured: isFeatured ?? this.isFeatured,
      isNew: isNew ?? this.isNew,
      isBestSelling: isBestSelling ?? this.isBestSelling,
      isOnSale: isOnSale ?? this.isOnSale,
      discount: discount ?? this.discount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Calculate the sale price after applying discount
  double? get salePrice {
    if (price == null) return null;
    if (discount == null || discount == 0) return price;
    return price! - (price! * (discount! / 100));
  }

  // Check if the product is in stock
  bool get isInStock {
    return stock == null || stock! > 0;
  }
}