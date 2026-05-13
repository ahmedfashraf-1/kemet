import 'product_category.dart';
import 'product_photo.dart';

class Product {
  final String productId;
  final String name;
  final String? nameAr;
  final String description;
  final String? descriptionAr;
  final double price;
  final ProductCategory category;     
  final List<ProductPhoto> photos;    
  final bool isAvailable;     
  final int stock; 

  const Product({
    required this.productId,
    required this.name,
    this.nameAr,
    required this.description,
    this.descriptionAr,
    required this.price,
    required this.category,
    required this.photos,
    required this.isAvailable,
    required this.stock,
  });

  /// Return a localized product name depending on language code.
  /// If Arabic code and [nameAr] exists, it is returned. Otherwise some
  /// common English product names are mapped to Arabic fallbacks.
  String localizedName(String code) {
    if (code == 'ar') {
      if (nameAr != null && nameAr!.trim().isNotEmpty) return nameAr!;

      final key = name.trim().toLowerCase();
      switch (key) {
        case 'ancient script terracotta vase':
          return 'مزهرية فخارية بنقوش قديمة';
        case 'pharaohic heritage serving':
        case 'pharaohic heritage serving bowls':
        case 'pharaohic heritage serving bowl':
          return 'أوعية تقديم فرعونية تراثية';
        case 'golden ankh pyramid box':
          return 'صندوق هرم أنخ ذهبي';
        case 'gold horus necklace':
          return 'عقد عين حورس الذهبي';
        case 'golden pyramid storage set':
          return 'مجموعة صناديق هرمية ذهبية للتخزين';
        case 'royal gilded egyptian vase':
          return 'مزهرية مصرية ملكية مذهبة';
        case 'handcrafted nubian clay bowl':
        case 'handcrafted nubian clay bowls':
          return 'وعاء فخاري نوبي مصنوع يدويًا';
        case 'nefertiti tote bag':
        case 'nefertiti tote bags':
          return 'حقيبة توت نيفرتيتي';
        case 'isis goddess handbag':
        case 'isis goddess handbags':
          return 'حقيبة يد إيزيس';
        case 'egypt map gold necklace':
        case 'egypt map gold necklaces':
          return 'عقد خريطة مصر ذهبي';
        case 'handmade egyptian camel scroll':
        case 'handmade egyptian camel scrolls':
          return 'مخطوطة جملية مصرية مصنوعة يدويًا';
        case 'golden hieroglyphic band':
        case 'golden hieroglyphic band bracelet':
          return 'سوار نقوش هيروغليفية ذهبي';
        case 'golden hieroglyphic band ring':
        case 'golden hieroglyphic ring':
          return 'خاتم ذهبي بنقوش هيروغليفية';
        default:
          // fallback heuristics: try to detect keywords in product name
          final k = key;
          if (k.contains('pyramid') && k.contains('storage')) {
            return 'مجموعة صناديق هرمية ذهبية للتخزين';
          }
          if (k.contains('pharaoh') || k.contains('pharao') || k.contains('pharaonic')) {
            return 'أوعية تقديم فرعونية تراثية';
          }
          if (k.contains('hieroglyph') && (k.contains('ring') || k.contains('خاتم') || k.contains('ring'))) {
            return 'خاتم ذهبي بنقوش هيروغليفية';
          }
          if (k.contains('hieroglyph') || k.contains('hierogl')) {
            return 'سوار نقوش هيروغليفية ذهبي';
          }
          if (k.contains('nubian') || (k.contains('clay') && k.contains('nub'))) {
            return 'وعاء فخاري نوبي مصنوع يدويًا';
          }
          if (k.contains('nefertiti')) {
            return 'حقيبة توت نيفرتيتي';
          }
          if (k.contains('isis')) {
            return 'حقيبة يد إيزيس';
          }
          if (k.contains('egypt') && k.contains('map')) {
            return 'عقد خريطة مصر ذهبي';
          }
          if (k.contains('camel') && k.contains('scroll')) {
            return 'مخطوطة جملية مصرية مصنوعة يدويًا';
          }

          return name;
      }
    }
    return name;
  }

  /// Return localized description based on code.
  String localizedDescription(String code) {
    if (code == 'ar') {
      if (descriptionAr != null && descriptionAr!.trim().isNotEmpty) return descriptionAr!;

      final key = name.trim().toLowerCase();

      switch (key) {
        case 'golden ankh pyramid box':
          return 'صندوق ديكوري فاخر مستوحى من شكل الهرم المدرج، بتفاصيل فرعونية ونقوش مستوحاة من الحضارة المصرية القديمة. يتميز بغطاء قابل للإزالة مزين برمز العنخ الشهير، مع لمسات ذهبية تمنحه مظهرًا ملكيًا أنيقًا. مثالي لحفظ المجوهرات أو كقطعة ديكور فريدة.';
        case 'golden pyramid storage set':
          return 'مجموعة صناديق هرمية ذهبية للتخزين، بتفاصيل مستوحاة من الهرم المدرج ولمسات فرعونية تمنحها حضورًا فاخرًا. مناسبة لحفظ المجوهرات أو كقطعة ديكور مميزة.';
        case 'pharaohic heritage serving':
        case 'pharaohic heritage serving bowl':
        case 'pharaohic heritage serving bowls':
          return 'أوعية تقديم فرعونية تراثية بتصميم أنيق يجمع بين الطابع الملكي والروح المصرية القديمة، مثالية للتقديم الأنيق أو كقطع ديكور فاخرة.';
        case 'golden hieroglyphic band ring':
        case 'golden hieroglyphic ring':
          return 'خاتم ذهبي بنقوش هيروغليفية دقيقة، يضفي لمسة تاريخية راقية ويمنحك حضورًا لافتًا.';
        case 'golden hieroglyphic band':
        case 'golden hieroglyphic band bracelet':
          return 'سوار مذهب بنقوش هيروغليفية دقيقة، يجمع بين الفخامة والرموز التاريخية.';
        case 'royal gilded egyptian vase':
          return 'مزهرية مصرية ملكية مذهبة بتشطيب فاخر وتفاصيل مستوحاة من التراث المصري، تمنح أي مساحة لمسة أنيقة ودافئة.';
        case 'handcrafted nubian clay bowl':
        case 'handcrafted nubian clay bowls':
          return 'وعاء فخاري نوبي مصنوع يدويًا بحرفية تقليدية، يتميز بملمس طبيعي وحضور تراثي دافئ يناسب الاستخدام أو العرض.';
        case 'nefertiti tote bag':
        case 'nefertiti tote bags':
          return 'حقيبة توت نيفرتيتي بتصميم عصري مستوحى من الجمال المصري القديم، عملية وأنيقة للاستخدام اليومي.';
        case 'isis goddess handbag':
        case 'isis goddess handbags':
          return 'حقيبة يد إيزيس بتفاصيل فاخرة ولمسات تراثية، تعكس الأناقة والهوية المصرية في تصميم واحد.';
        case 'egypt map gold necklace':
        case 'egypt map gold necklaces':
          return 'عقد خريطة مصر الذهبي، قطعة رمزية راقية تجمع بين الفخامة والانتماء الوطني.';
        case 'handmade egyptian camel scroll':
        case 'handmade egyptian camel scrolls':
          return 'مخطوطة مصرية يدوية بنقوش الجمل والتراث الشعبي، مصنوعة بحرفية عالية وتناسب العرض كقطعة فنية مميزة.';
        case 'ancient script terracotta vase':
          return 'مزهرية فخارية بنقوش قديمة تضيف طابعًا تاريخيًا ودافئًا للديكور.';
      }

      final k = key;
      if (k.contains('pyramid') && k.contains('storage')) {
        return 'مجموعة صناديق هرمية ذهبية للتخزين، بتفاصيل مستوحاة من الهرم المدرج ولمسات فرعونية تمنحها حضورًا فاخرًا. مناسبة لحفظ المجوهرات أو كقطعة ديكور مميزة.';
      }
      if (k.contains('pharaoh') || k.contains('pharao') || k.contains('pharaonic')) {
        return 'أوعية تقديم فرعونية تراثية بتصميم أنيق يجمع بين الطابع الملكي والروح المصرية القديمة، مثالية للتقديم الأنيق أو كقطع ديكور فاخرة.';
      }
      if (k.contains('hieroglyph') && (k.contains('ring') || k.contains('خاتم'))) {
        return 'خاتم ذهبي بنقوش هيروغليفية دقيقة، يضفي لمسة تاريخية راقية ويمنحك حضورًا لافتًا.';
      }
      if (k.contains('hieroglyph')) {
        return 'سوار مذهب بنقوش هيروغليفية دقيقة، يجمع بين الفخامة والرموز التاريخية.';
      }
      if (k.contains('nubian') || (k.contains('clay') && k.contains('nub'))) {
        return 'وعاء فخاري نوبي مصنوع يدويًا بحرفية تقليدية، يتميز بملمس طبيعي وحضور تراثي دافئ يناسب الاستخدام أو العرض.';
      }
      if (k.contains('nefertiti')) {
        return 'حقيبة توت نيفرتيتي بتصميم عصري مستوحى من الجمال المصري القديم، عملية وأنيقة للاستخدام اليومي.';
      }
      if (k.contains('isis')) {
        return 'حقيبة يد إيزيس بتفاصيل فاخرة ولمسات تراثية، تعكس الأناقة والهوية المصرية في تصميم واحد.';
      }
      if (k.contains('egypt') && k.contains('map')) {
        return 'عقد خريطة مصر الذهبي، قطعة رمزية راقية تجمع بين الفخامة والانتماء الوطني.';
      }
      if (k.contains('camel') && k.contains('scroll')) {
        return 'مخطوطة مصرية يدوية بنقوش الجمل والتراث الشعبي، مصنوعة بحرفية عالية وتناسب العرض كقطعة فنية مميزة.';
      }

      return description;
    }
    return description;
  }
}