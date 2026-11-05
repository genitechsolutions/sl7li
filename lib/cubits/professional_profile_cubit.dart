import '../data/repositories/professional_profile_repository.dart';
import 'load_cubit.dart';

/// الملف المهني الحقيقي (تعديل + صورة + معرض أعمال).
class ProfessionalProfileCubit extends LoadCubit<ProfessionalProfile> {
  ProfessionalProfileCubit(this._repo);

  final ProfessionalProfileRepository _repo;

  @override
  Future<ProfessionalProfile> fetch() => _repo.load();

  Future<void> save(ProfessionalEdits edits) async {
    final current = state.data;
    if (current == null) return;
    await _repo.save(current, edits);
    await load(force: true);
  }

  Future<void> saveAvatar(String path) async {
    final current = state.data;
    if (current == null) return;
    await _repo.saveAvatar(current, path);
    await load(force: true);
  }

  Future<void> addPortfolio(List<String> paths) async {
    final current = state.data;
    if (current == null) return;
    await _repo.addPortfolio(current, paths);
    await load(force: true);
  }

  Future<void> removePortfolio(String key) async {
    final current = state.data;
    if (current == null) return;
    await _repo.removePortfolio(current, key);
    await load(force: true);
  }
}
