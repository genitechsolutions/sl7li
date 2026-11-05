import '../data/dummy_data.dart';
import 'feature_cubits.dart';
import 'load_cubit.dart';

/// تفاصيل عرض واحد؛ [offerId] null (بيانات وهمية) ← عينة ثابتة.
class OfferDetailsCubit extends LoadCubit<OfferDetails> {
  OfferDetailsCubit(this._offers, this.offerId);

  final OffersCubit _offers;
  final String? offerId;

  @override
  Future<OfferDetails> fetch() async {
    final details = await _offers.details(offerId);
    _offers.trackDetailView(offerId).ignore();
    return details;
  }
}
