/// مستندات GraphQL (منسوخة حرفياً من استعلامات موقع الويب).
class Gql {
  const Gql._();

  static const listPublicOffers = r'''
query ListPublicOffers($cityCode: String, $serviceCategory: String, $priceMin: Int, $priceMax: Int, $limit: Int, $nextToken: String) {
  listPublicOffers(cityCode: $cityCode, serviceCategory: $serviceCategory, priceMin: $priceMin, priceMax: $priceMax, limit: $limit, nextToken: $nextToken) {
    items
    nextToken
    error
  }
}''';

  static const getUserDashboard = r'''
query GetUserDashboardSecure($userId: String!, $limit: Int, $nextToken: String, $statusFilter: String) {
  getUserDashboardSecure(userId: $userId, limit: $limit, nextToken: $nextToken, statusFilter: $statusFilter) {
    jobs
    nextToken
    error
  }
}''';

  static const getAvailableJobsForProfessional = r'''
query GetAvailableJobsForProfessionalSecure($professionalId: String!) {
  getAvailableJobsForProfessionalSecure(professionalId: $professionalId) {
    error
    jobs
  }
}''';

  static const getCurrentTasksForProfessional = r'''
query GetCurrentTasksForProfessionalSecure($professionalId: String!) {
  getCurrentTasksForProfessionalSecure(professionalId: $professionalId) {
    error
    jobs
  }
}''';

  static const getSecureUserConversations = r'''
query GetSecureUserConversations($isProfessionalMode: Boolean) {
  getSecureUserConversations(isProfessionalMode: $isProfessionalMode) {
    conversations
    error
  }
}''';

  static const getConversationMessages = r'''
query GetSecureConversationMessages($conversationId: String!, $limit: Int, $beforeTimestamp: String) {
  getSecureConversationMessages(conversationId: $conversationId, limit: $limit, beforeTimestamp: $beforeTimestamp) {
    messages
    error
  }
}''';

  static const getUserNotifications = r'''
query GetUserNotifications($category: String, $limit: Int, $nextToken: String, $status: String, $userId: String!) {
  getUserNotifications(category: $category, limit: $limit, nextToken: $nextToken, status: $status, userId: $userId)
}''';

  static const markAllNotificationsAsRead = r'''
mutation MarkAllNotificationsAsRead($category: String, $userId: String!) {
  markAllNotificationsAsRead(category: $category, userId: $userId)
}''';

  static const getCurrentUser = r'''
query GetCurrentUserSecure {
  getCurrentUserSecure {
    user
    error
  }
}''';

  static const getCurrentProfessional = r'''
query GetCurrentProfessionalSecure {
  getCurrentProfessionalSecure {
    professional
    error
  }
}''';

  static const getMyWallet = r'''
query GetMyWalletSecure($nextToken: String) {
  getMyWalletSecure(nextToken: $nextToken) {
    wallet
    transactions
    nextToken
    error
  }
}''';

  static const resendOtp = r'''
mutation ResendOtpSecure($phoneNumber: String!) {
  resendOtpSecure(phoneNumber: $phoneNumber) {
    success
    error
  }
}''';

  static const createJob = r'''
mutation CreateJobSecure($input: AWSJSON!) {
  createJobSecure(input: $input) {
    job
    error
  }
}''';

  static const markMessagesRead = r'''
mutation MarkMessagesAsReadSecure($conversationId: String!) {
  markMessagesAsReadSecure(conversationId: $conversationId) {
    success
    updatedCount
    error
  }
}''';

  static const cancelJob = r'''
mutation CancelJobSecure($jobId: String!, $cancellationReasonCategory: String, $cancellationReason: String) {
  cancelJobSecure(jobId: $jobId, cancellationReasonCategory: $cancellationReasonCategory, cancellationReason: $cancellationReason) {
    job
    error
  }
}''';

  static const ignoreJob = r'''
mutation IgnoreJobForProfessionalSecure($jobId: String!, $ignoreReason: String!, $otherReason: String, $notes: String) {
  ignoreJobForProfessionalSecure(jobId: $jobId, ignoreReason: $ignoreReason, otherReason: $otherReason, notes: $notes) {
    success
    error
  }
}''';
}
