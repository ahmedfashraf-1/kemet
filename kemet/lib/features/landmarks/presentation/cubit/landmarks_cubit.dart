import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'landmarks_state.dart';

class LandmarksCubit extends Cubit<LandmarksState> {
  LandmarksCubit() : super(LandmarksInitial());
}
