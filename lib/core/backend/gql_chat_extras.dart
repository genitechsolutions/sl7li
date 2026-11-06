/// مستندات إضافات الدردشة وتجاهل الطلبات (نفس شكل الموقع).
class GqlChatExtras {
  const GqlChatExtras._();

  static const validateImageCount = r'''
query ValidateConversationImageCount($conversationId: String!, $newImageCount: Int!) {
  validateConversationImageCount(conversationId: $conversationId, newImageCount: $newImageCount) {
    canAttach
    currentImageCount
    maxAllowed
    error
  }
}''';

  static const deleteMessage = r'''
mutation DeleteMessage($input: DeleteMessageInput!) {
  deleteMessage(input: $input) {
    id
  }
}''';

  static const assignedWhatsApp = r'''
query GetJobAssignedProfessionalWhatsAppSecure($jobId: String!) {
  getJobAssignedProfessionalWhatsAppSecure(jobId: $jobId) {
    whatsappNumber
    professionalId
    error
  }
}''';

  static const unignoreJob = r'''
mutation UnignoreJobForProfessionalSecure($jobId: String!) {
  unignoreJobForProfessionalSecure(jobId: $jobId) {
    success
    error
  }
}''';

  static const listIgnoredJobIds = r'''
query ListIgnoredJobIdsForProfessionalSecure($professionalId: String!) {
  listIgnoredJobIdsForProfessionalSecure(professionalId: $professionalId) {
    jobIds
    error
  }
}''';
}
