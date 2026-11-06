/// مستندات الإبلاغ وتقييمات المهني (نفس شكل الموقع).
class GqlReportsRatings {
  const GqlReportsRatings._();

  static const eligibility = r'''
query GetServiceReportEligibility($targetType: String!, $targetId: String!) {
  getServiceReportEligibility(targetType: $targetType, targetId: $targetId) {
    canReport
    reportedCategories
    error
  }
}''';

  static const createReport = r'''
mutation CreateServiceReportSecure($input: AWSJSON!) {
  createServiceReportSecure(input: $input) {
    report
    error
  }
}''';

  static const myReports = r'''
query ListMyServiceReports($limit: Int, $nextToken: String) {
  listMyServiceReports(limit: $limit, nextToken: $nextToken) {
    reports
    nextToken
    error
  }
}''';

  static const ratings = r'''
query GetRatingsForProfessional($limit: Int, $nextToken: String) {
  getRatingsForProfessional(limit: $limit, nextToken: $nextToken) {
    ratings
    nextToken
    error
  }
}''';

  static const ratingDetail = r'''
query GetRatingDetail($feedbackId: String!) {
  getRatingDetail(feedbackId: $feedbackId) {
    rating
    error
  }
}''';
}
