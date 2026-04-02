import 'package:dartz/dartz.dart';
import 'package:kemet/core/errors/failures.dart';
import '../entities/profile_entity.dart';

// 🔥 استدعاء الـ entities من الفيتشرز الحقيقية
import 'package:kemet/features/reviews/domain/entities/review.dart';
import 'package:kemet/features/favorite/domain/entities/favorite.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';

/// العقد اللي بيحدد إيه اللي الـ repository لازم يعمله
/// الـ domain layer هي اللي بتنفذه — الـ data layer مش عارف أي حاجة عن الـ API أو الـ local DB
abstract class ProfileRepository {
  /// جيب بيانات البروفايل للـ user الحالي
  Future<Either<Failure, ProfileEntity>> getProfile(String userId);

  /// جيب آخر trips من landmarks feature
  Future<Either<Failure, List<Landmark>>> getRecentTrips(String userId);

  /// جيب الـ reviews بتاعة الـ user من reviews feature
  Future<Either<Failure, List<Review>>> getMyReviews(String userId);

  /// جيب الأماكن المحفوظة من favorite feature
  Future<Either<Failure, List<Favorite>>> getFavoritePlaces(String userId);

  /// تسجيل الخروج
  Future<Either<Failure, void>> logout();
}