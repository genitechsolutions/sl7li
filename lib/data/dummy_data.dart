import 'chat_data.dart';
import 'my_request.dart';

class ServiceItem {
  const ServiceItem({required this.name, required this.image});

  final String name;
  final String image;
}

class ServiceDetails {
  const ServiceDetails({
    required this.title,
    required this.description,
    required this.image,
    required this.specialties,
  });

  final String title;
  final String description;
  final String image;
  final List<String> specialties;
}

class Offer {
  const Offer({
    required this.title,
    required this.location,
    required this.image,
    required this.discount,
    this.tags = const [],
    this.craftsman,
  });

  final String title;
  final String location;
  final String image;
  final String discount;
  final List<String> tags;
  final Craftsman? craftsman;
}

class Craftsman {
  const Craftsman({
    required this.name,
    required this.location,
    required this.services,
    this.image,
    this.rating,
    this.reviewsCount = 0,
    this.isPro = false,
    this.isVerified = false,
    this.isRecommended = false,
  });

  final String name;
  final String location;
  final List<String> services;
  final String? image;
  final double? rating;
  final int reviewsCount;
  final bool isPro;
  final bool isVerified;
  final bool isRecommended;
}

class OfferDetails {
  const OfferDetails({
    required this.title,
    required this.discount,
    required this.validUntil,
    required this.city,
    required this.description,
    required this.images,
    required this.tags,
    required this.craftsman,
  });

  final String title;
  final String discount;
  final String validUntil;
  final String city;
  final String description;
  final List<String> images;
  final List<String> tags;
  final Craftsman craftsman;
}

const popularServices = [
  ServiceItem(name: 'الدهانات', image: 'assets/images/ic_paint.png'),
  ServiceItem(name: 'التكييف', image: 'assets/images/ic_ac.png'),
  ServiceItem(name: 'الكهرباء', image: 'assets/images/ic_electricity.png'),
  ServiceItem(name: 'السباكة', image: 'assets/images/ic_plumbing.png'),
  ServiceItem(name: 'الدهانات', image: 'assets/images/ic_paint.png'),
  ServiceItem(name: 'التكييف', image: 'assets/images/ic_ac.png'),
  ServiceItem(name: 'الكهرباء', image: 'assets/images/ic_electricity.png'),
];

const specialOffers = [
  Offer(
    title: 'خصم 25% على أعمال النجارة',
    location: 'دمشق وريفها',
    image: 'assets/images/offer_carpentry.jpg',
    discount: 'خصم 25%',
  ),
  Offer(
    title: 'خصم 25% على أعمال النجارة',
    location: 'دمشق وريفها',
    image: 'assets/images/offer_carpentry.jpg',
    discount: 'خصم 25%',
  ),
  Offer(
    title: 'خصم 25% على أعمال النجارة',
    location: 'دمشق وريفها',
    image: 'assets/images/offer_carpentry.jpg',
    discount: 'خصم 25%',
  ),
];

const featuredCraftsmen = [
  Craftsman(
    name: 'مركز قزاز للتكيف والتبريد',
    location: 'دمشق وريفها',
    services: ['تكييف', 'أجهزة منزلية', 'الكهرباء'],
    rating: 4.9,
    reviewsCount: 128,
    image: 'assets/images/craftsman_1.jpg',
    isPro: true,
    isVerified: true,
  ),
  Craftsman(
    name: 'مركز قزاز للتكيف والتبريد',
    location: 'دمشق وريفها',
    services: ['تكييف', 'أجهزة منزلية', 'الكهرباء'],
    image: 'assets/images/craftsman_1.jpg',
    isPro: true,
    isVerified: true,
  ),
  Craftsman(
    name: 'مركز قزاز للتكيف والتبريد',
    location: 'دمشق وريفها',
    services: ['تكييف', 'أجهزة منزلية', 'الكهرباء'],
    rating: 4.9,
    reviewsCount: 128,
    image: 'assets/images/craftsman_1.jpg',
    isPro: true,
    isVerified: true,
  ),
];

const sampleServiceDetails = ServiceDetails(
  title: 'إصلاح الإلكترونيات و الأجهزة الطبية',
  description: 'هنا يكتب وصف الخدمة، هنا يكتب وصف الخدمة، هنا يكتب وصف الخدمة، هنا يكتب وصف الخدمة، هنا يكتب وصف الخدمة،',
  image: 'assets/images/offer_carpentry.jpg',
  specialties: [
    'إصلاح الهواتف المحمولة',
    'إصلاح السخانات الليزرية',
    'إصلاح شاشات التلفزيون وأجهزة التحكم',
    'إصلاح اللابتوب',
    'تركيب وإصلاح راوترات الواي فاي المنزلية',
    'إصلاح الكاميرات',
    'إصلاح الكاميرات',
    'إصلاح السخانات الليزرية',
    'إصلاح السبيكرات وأنظمة الصوت',
  ],
);

const allOffers = [
  Offer(
    title: 'خصم 25% على أعمال النجارة',
    location: 'دمشق وريفها',
    image: 'assets/images/offer_carpentry.jpg',
    discount: 'خصم 25%',
    tags: ['ديكور', 'نجارة'],
    craftsman: Craftsman(
      name: 'مركز قزاز للتكيف والتبريد',
      location: 'دمشق وريفها',
      services: [],
      rating: 4.9,
      reviewsCount: 128,
      image: 'assets/images/craftsman_1.jpg',
      isPro: true,
      isVerified: true,
    ),
  ),
  Offer(
    title: 'أي صيانة سوفتوير ب 1000 ليرة سورية فقط',
    location: 'دمشق وريفها',
    image: 'assets/images/offer_carpentry.jpg',
    discount: '1000 ل.س',
    tags: ['إصلاح الهواتف المحمولة'],
    craftsman: Craftsman(
      name: 'مركز قزاز للتكيف والتبريد',
      location: 'دمشق وريفها',
      services: [],
      rating: 4.9,
      reviewsCount: 128,
      image: 'assets/images/craftsman_1.jpg',
      isPro: true,
      isVerified: true,
    ),
  ),
];

const sampleOfferDetails = OfferDetails(
  title: 'عنوان العرض يكتب هنا',
  discount: 'خصم 25%',
  validUntil: '25/9/2026',
  city: 'جميع المدن',
  description: 'شرح تفاصيل المشكلة أو العمل المطلوب, شرح تفاصيل المشكلة أو العمل المطلوب, شرح تفاصيل المشكلة أو العمل المطلوب, شرح تفاصيل المشكلة أو العمل المطلوب',
  images: [
    'assets/images/offer_carpentry.jpg',
    'assets/images/offer_carpentry.jpg',
    'assets/images/offer_carpentry.jpg',
    'assets/images/offer_carpentry.jpg',
    'assets/images/offer_carpentry.jpg',
    'assets/images/offer_carpentry.jpg',
    'assets/images/offer_carpentry.jpg',
    'assets/images/offer_carpentry.jpg',
  ],
  tags: [
    'الأنظمة الأمنية و المنزل الذكي',
    'الإصلاحات الكهربائية',
    'الطاقة الشمسية',
  ],
  craftsman: Craftsman(
    name: 'مركز النور للكهرباء',
    location: 'دمشق وريفها',
    services: [],
    rating: 4.9,
    reviewsCount: 128,
    image: 'assets/images/craftsman_1.jpg',
    isPro: true,
    isVerified: true,
    isRecommended: true,
  ),
);

class Review {
  const Review({
    required this.name,
    required this.avatar,
    required this.rating,
    required this.date,
    required this.tag,
    required this.comment,
  });

  final String name;
  final String avatar;
  final int rating;
  final String date;
  final String tag;
  final String comment;
}

class CraftsmanProfile {
  const CraftsmanProfile({
    required this.craftsman,
    required this.bio,
    required this.bioPreviewLength,
    required this.experience,
    required this.tools,
    required this.transport,
    required this.specialties,
    required this.offers,
    required this.works,
    required this.reviews,
  });

  final Craftsman craftsman;
  final String bio;

  /// عدد الأحرف الظاهرة قبل "قراءة المزيد".
  final int bioPreviewLength;
  final String experience;
  final String tools;
  final String transport;
  final List<String> specialties;
  final List<Offer> offers;
  final List<String> works;
  final List<Review> reviews;
}

const _bioPreview =
    '1قسم تسيس واصلاح جميع الاعمال الكهربائية منزلي / مصانع . اصلاح منظومة الطاقةالكهربائية . 2قسم تركيب انظمة كاميرات مراقبة واصلاح تركيب';

const sampleCraftsmanProfile = CraftsmanProfile(
  craftsman: Craftsman(
    name: 'مركز النور للكهرباء',
    location: 'دمشق وريفها',
    services: [],
    rating: 4.9,
    reviewsCount: 128,
    image: 'assets/images/craftsman_1.jpg',
    isPro: true,
    isVerified: true,
    isRecommended: true,
  ),
  bio:
      '$_bioPreview أنظمة الإنذار والمنزل الذكي. 3قسم تركيب وصيانة منظومات الطاقة الشمسية.',
  bioPreviewLength: _bioPreview.length,
  experience: '7 سنوات',
  tools: 'نعم، أملك جميع الأدوات',
  transport: 'نعم، سيارة خاصة',
  specialties: [
    'الأنظمة الأمنية و المنزل الذكي',
    'الإصلاحات الكهربائية',
    'الطاقة الشمسية',
  ],
  offers: specialOffers,
  works: [
    'assets/images/offer_carpentry.jpg',
    'assets/images/offer_carpentry.jpg',
    'assets/images/offer_carpentry.jpg',
    'assets/images/offer_carpentry.jpg',
    'assets/images/offer_carpentry.jpg',
    'assets/images/offer_carpentry.jpg',
  ],
  reviews: [
    Review(
      name: 'فلان الفلاني',
      avatar: 'assets/images/craftsman_1.jpg',
      rating: 5,
      date: 'منذ 3 أيام',
      tag: 'الأنظمة الأمنية و المنزل الذكي',
      comment: 'ماشاء الله فوق التقييم ما بيصعب عليه شي الله يرزقه',
    ),
    Review(
      name: 'فلان الفلاني',
      avatar: 'assets/images/craftsman_1.jpg',
      rating: 3,
      date: '٢١ ديسمبر ٢٠٢٥',
      tag: 'الأنظمة الأمنية و المنزل الذكي',
      comment: '1قسم تسيس واصلاح جميع الاعمال الكهربائية منزلي / مصانع . اصلاح منظومة الطاقةالكهربائية',
    ),
    Review(
      name: 'فلان الفلاني',
      avatar: 'assets/images/craftsman_1.jpg',
      rating: 5,
      date: 'منذ أسبوع',
      tag: 'الإصلاحات الكهربائية',
      comment: 'شغل نظيف ومواعيد مضبوطة',
    ),
    Review(
      name: 'فلان الفلاني',
      avatar: 'assets/images/craftsman_1.jpg',
      rating: 4,
      date: 'منذ شهر',
      tag: 'الطاقة الشمسية',
      comment: 'ركّب المنظومة بسرعة وشرح كل شي',
    ),
  ],
);

const recentSearches = [
  'الأنظمة الأمنية و المنزل الذكي',
  'الأنظمة الأمنية و المنزل الذكي',
  'الأنظمة الأمنية و المنزل الذكي',
];

const popularSearches = [
  'الأنظمة الأمنية و المنزل الذكي',
  'الأنظمة الأمنية و المنزل الذكي',
  'الأنظمة الأمنية و المنزل الذكي',
];

const searchResults = [...featuredCraftsmen, ...featuredCraftsmen];

const requestServiceTypes = [
  'الدهانات',
  'التكييف',
  'الكهرباء',
  'السباكة',
  'النجارة',
  'إصلاح الإلكترونيات و الأجهزة الطبية',
];

const requestCities = [
  'دمشق',
  'ريف دمشق',
  'حلب',
  'حمص',
  'حماة',
  'اللاذقية',
  'طرطوس',
];

const sampleRequestPhoto = 'assets/images/offer_carpentry.jpg';

const requestPreferredDates = [
  'مستعجل - خلال ال 24 ساعة القادمة',
  'خلال 3 أيام',
  'خلال أسبوع',
  'مرن - بدون موعد محدد',
];

const requestPreferredTimes = [
  'مرن - أي وقت من النهار',
  'صباحاً (8 - 12)',
  'ظهراً (12 - 4)',
  'مساءً (4 - 8)',
];

const _targetCraftsman = Craftsman(
  name: 'مركز قزاز للتكيف والتبريد',
  location: 'دمشق وريفها',
  services: [],
  rating: 4.9,
  reviewsCount: 128,
  image: 'assets/images/craftsman_1.jpg',
  isPro: true,
  isVerified: true,
  isRecommended: true,
);

const targetableCraftsmen = [
  _targetCraftsman,
  _targetCraftsman,
  _targetCraftsman,
  _targetCraftsman,
  _targetCraftsman,
];

// ── تسجيل الدخول ──

/// مدن "دخول الزبائن" بترتيب التصميم.
const loginCities = [
  'دمشق',
  'حمص',
  'حلب',
  'اللاذقية',
  'درعا',
  'دير الزور',
  'حماة',
  'طرطوس',
  'السويداء',
  'إدلب',
  'الحسكة',
  'الرقة',
  'القنيطرة',
  'ريف دمشق',
];

const loginDistricts = [
  'مركز المدينة',
  'المزة',
  'المالكي',
  'أبو رمانة',
  'كفرسوسة',
  'باب توما',
  'الشعلان',
  'المهاجرين',
  'ركن الدين',
  'برزة',
  'دمر',
  'مشروع دمر',
];

// ── طلباتي ──
const _requestDescription =
    'شرح تفاصيل المشكلة أو العمل المطلوب, شرح تفاصيل المشكلة أو العمل المطلوب';

const sampleActiveRequests = [
  MyRequest(
    date: '5 آب 2026',
    priority: RequestPriority.urgent,
    title: 'طلب خدمة إصلاحات الكهربائية',
    description: _requestDescription,
    stage: 0,
    offersCount: 7,
  ),
  MyRequest(
    date: '5 آب 2026',
    priority: RequestPriority.emergency,
    title: 'طلب خدمة إصلاحات الكهربائية',
    description: _requestDescription,
    stage: 1,
    craftsmanName: 'مركز قزاز للتكيف والتبريد',
    craftsmanRating: '4.9',
    craftsmanReviews: 128,
  ),
  MyRequest(
    date: '5 آب 2026',
    priority: RequestPriority.normal,
    title: 'طلب خدمة إصلاحات الكهربائية',
    description: _requestDescription,
    stage: 2,
    craftsmanName: 'مركز قزاز للتكيف والتبريد',
    craftsmanRating: '4.9',
    craftsmanReviews: 128,
  ),
];

const sampleDoneRequests = [
  MyRequest(
    date: '5 آب 2026',
    priority: RequestPriority.emergency,
    title: 'طلب خدمة إصلاحات الكهربائية',
    description: _requestDescription,
    stage: 4,
    status: RequestStatus.done,
    craftsmanName: 'مركز قزاز للتكيف والتبريد',
    craftsmanRating: '4.9',
    craftsmanReviews: 128,
  ),
  MyRequest(
    date: '5 آب 2026',
    priority: RequestPriority.emergency,
    title: 'طلب خدمة إصلاحات الكهربائية',
    description: _requestDescription,
    stage: 4,
    status: RequestStatus.done,
    rated: true,
    craftsmanName: 'مركز قزاز للتكيف والتبريد',
    craftsmanRating: '4.9',
    craftsmanReviews: 128,
  ),
];

const sampleCanceledRequests = [
  MyRequest(
    date: '5 آب 2026',
    priority: RequestPriority.normal,
    title: 'طلب خدمة إصلاحات الكهربائية',
    description: _requestDescription,
    stage: 0,
    status: RequestStatus.canceled,
    cancelNote: 'تم إلغاء الطلب',
  ),
  MyRequest(
    date: '5 آب 2026',
    priority: RequestPriority.emergency,
    title: 'طلب خدمة إصلاحات الكهربائية',
    description: _requestDescription,
    stage: 0,
    status: RequestStatus.canceled,
    cancelNote: 'لقد انتهت مدة طلبك',
  ),
];

const sampleBestOffer = RequestOffer(
  craftsmanName: 'مركز قزاز للتكيف والتبريد',
  rating: '4.9',
  reviews: 128,
  priceLabel: 'الكلفة الأولية تتراوح بين',
  price: '90 - 100',
  priceUnit: 'ليرة جديدة',
  inspectionFee: 'مجاني',
  materialsFee: '20 ليرة جديدة',
);

const sampleOtherOffers = [
  RequestOffer(
    craftsmanName: 'مركز قزاز للتكيف والتبريد',
    rating: '4.9',
    reviews: 128,
    priceLabel: 'الكلفة الأولية التقديرية',
    price: '100',
    priceUnit: 'ليرة جديدة',
    inspectionFee: 'مجاني',
    materialsFee: '20 ليرة جديدة',
  ),
  RequestOffer(
    craftsmanName: 'مركز قزاز للتكيف والتبريد',
    rating: '4.9',
    reviews: 128,
    priceLabel: 'الكلفة الأولية اليومية',
    price: '100',
    priceUnit: 'ليرة جديدة / يوم',
    inspectionFee: 'مجاني',
    materialsFee: '20 ليرة جديدة',
  ),
];

// ── الرسائل ──
const sampleConversations = [
  Conversation(
    name: 'مركز قزاز للتكيف والتبريد',
    lastMessage: 'آخر رسالة تم إرسالها',
    time: '2:24 م',
    sentStatus: MessageStatus.read,
  ),
  Conversation(
    name: 'مركز قزاز للتكيف والتبريد',
    lastMessage: 'آخر رسالة تم استلامها',
    time: '2:24 م',
    verified: true,
    unread: 3,
  ),
  Conversation(
    name: 'مركز قزاز للتكيف والتبريد',
    lastMessage: 'آخر رسالة تم إرسالها',
    time: '2:24 م',
    verified: true,
    sentStatus: MessageStatus.delivered,
  ),
  Conversation(
    name: 'مركز قزاز للتكيف والتبريد',
    lastMessage: 'آخر رسالة تم إرسالها',
    time: '2:24 م',
    isPro: false,
    sentStatus: MessageStatus.sent,
  ),
  Conversation(
    name: 'مركز قزاز للتكيف والتبريد',
    lastMessage: 'آخر رسالة تم إرسالها',
    time: '2:24 م',
    sentStatus: MessageStatus.sending,
  ),
  Conversation(
    name: 'مركز قزاز للتكيف والتبريد',
    lastMessage: 'آخر رسالة تم استلامها',
    time: '2:24 م',
    verified: true,
    unread: 3,
  ),
  Conversation(
    name: 'مركز قزاز للتكيف والتبريد',
    lastMessage: 'آخر رسالة تم إرسالها',
    time: '2:24 م',
    verified: true,
    sentStatus: MessageStatus.read,
  ),
];

const sampleChat = [
  ChatMessage(
    text: 'سأقدم لك عرضا على هذا الطلب ب 100\$',
    time: '2:10 م',
    sent: false,
  ),
  ChatMessage(
    text: 'لقد حصلت على الكثير من العروض أرخص من هذا',
    time: '2:10 م',
    sent: true,
  ),
  ChatMessage(text: 'لماذا اختارك أنت؟', time: '2:10 م', sent: true),
  ChatMessage(text: 'أو أعطني سعرا أقل من هذا', time: '2:10 م', sent: true),
  ChatMessage(
    text: 'بطل بدي اشتغل معك أصلا',
    time: '2:10 م',
    sent: true,
    status: MessageStatus.sent,
  ),
  ChatMessage(
    text: 'هي مثال لإرسال الصورة',
    time: '2:10 م',
    sent: true,
    status: MessageStatus.sent,
    content: ChatContent.image,
    image: 'assets/images/request_photo_2.png',
  ),
];

// ── الإشعارات ──
const _offerBody =
    'تم استلام عرض جديد من Mevora لطلب العمل: طلب خدمة خدمات أخرى';
const _withdrawnBody = 'تم سحب عرض Mevora لطلب العمل: طلب خدمة خدمات أخرى';

const sampleImportantNotifications = [
  NotificationItem(
    kind: NotificationKind.offer,
    title: 'تم استلام عرض جديد',
    body: _offerBody,
    time: 'الآن',
    unread: true,
  ),
  NotificationItem(
    kind: NotificationKind.completion,
    title: 'تأكيد إنجاز الطلب',
    body: 'أبلغ المهني Mevora عن إنجاز طلب "خدمات أخرى", يرجى تأكيد الإنجاز أو الاعتراض',
    time: '2:10 م',
    unread: true,
    actionLabel: 'الانتقال للخدمة',
  ),
  NotificationItem(
    kind: NotificationKind.withdrawn,
    title: 'تم سحب عرض لطلبك',
    body: _withdrawnBody,
    time: '2:10 م',
  ),
];

const sampleTodayNotifications = [
  NotificationItem(
    kind: NotificationKind.message,
    title: 'رسالة جديدة من Mevora',
    body: 'يتم هنا عرض محتوى الرسالة',
    time: 'الآن',
    unread: true,
  ),
  NotificationItem(
    kind: NotificationKind.offer,
    title: 'تم استلام عرض جديد',
    body: _offerBody,
    time: 'الآن',
  ),
];

const sampleLastWeekNotifications = [
  NotificationItem(
    kind: NotificationKind.withdrawn,
    title: 'تم سحب عرض لطلبك',
    body: _withdrawnBody,
    time: '2:10 م',
    unread: true,
  ),
];
