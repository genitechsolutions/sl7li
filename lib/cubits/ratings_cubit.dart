import '../data/repositories/reports_ratings_repository.dart';
import 'load_cubit.dart';

/// تقييمات المهني الواردة.
class RatingsCubit extends LoadCubit<List<ProfessionalRating>> {
  RatingsCubit(this._repo);

  final ProfessionalRatingsRepository _repo;

  @override
  Future<List<ProfessionalRating>> fetch() => _repo.load();
}
