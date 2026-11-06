/// مستندات علامات القراءة وعدّاد الإشعارات (نفس شكل الموقع).
class GqlNotificationExtras {
  const GqlNotificationExtras._();

  static const markNotificationAsRead = r'''
mutation MarkNotificationAsRead($notificationId: String!, $userId: String!) {
  markNotificationAsRead(notificationId: $notificationId, userId: $userId)
}''';

  static const markNotificationsByConversation = r'''
mutation MarkNotificationsByConversation($conversationId: String!, $userId: String!) {
  markNotificationsByConversation(conversationId: $conversationId, userId: $userId)
}''';

  static const getUnreadNotificationCount = r'''
query GetUnreadNotificationCount($category: String, $userId: String!) {
  getUnreadNotificationCount(category: $category, userId: $userId)
}''';
}
