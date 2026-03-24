import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'reviews_state.dart';

class ReviewsCubit extends Cubit<ReviewsState> {
  ReviewsCubit() : super(ReviewsInitial());
}
