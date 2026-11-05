import '../data/dummy_data.dart';
import '../data/repositories/public_profile_repository.dart';
import 'load_cubit.dart';

/// الصفحة العامة لمهني واحد (cubit لكل صفحة مفتوحة).
class PublicProfileCubit extends LoadCubit<CraftsmanProfile> {
  PublicProfileCubit(this._repo, this.professionalId);

  final PublicProfileRepository _repo;
  final String professionalId;

  @override
  Future<CraftsmanProfile> fetch() => _repo.get(professionalId);
}
