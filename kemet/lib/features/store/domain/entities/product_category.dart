class ProductCategory {
  final String categoryId;
  final String categoryName;
  final String? categoryNameAr;

  const ProductCategory({
    required this.categoryId,
    required this.categoryName,
    this.categoryNameAr,
  });

  /// Return a localized display name for this category.
  /// If `code` == 'ar' and an Arabic name is present, it will be returned.
  /// Otherwise, for Arabic code and missing Arabic field, we try to map
  /// some well-known English category names to Arabic equivalents.
  /// For any other case we return [categoryName].
  String localizedName(String code) {
    final key = categoryName.trim().toLowerCase();
    if (code == 'ar') {
      if (categoryNameAr != null && categoryNameAr!.trim().isNotEmpty) {
        return categoryNameAr!;
      }

      // fallback mappings for common categories
      switch (key) {
        case 'pottery':
          return 'فخار';
        case 'accessories':
          return 'إكسسوارات';
        case 'decoration':
        case 'decor':
        case 'home decor':
          return 'ديكورات';
        case 'handbag':
        case 'bags':
        case 'bag':
          return 'حقائب';
        case 'jewelry':
        case 'jewellery':
          return 'مجوهرات';
        case 'figurines':
          return 'تماثيل';
        case 'all':
        case 'general':
          return 'الكل';
        default:
          return categoryName;
      }
    }

    return categoryName;
  }
}
