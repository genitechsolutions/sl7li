/// مستندات دورة حياة الطلب (اتفاق، تنفيذ، إنجاز، إعادة فتح) بنفس شكل الموقع.
class GqlJobLifecycle {
  const GqlJobLifecycle._();

  static const updateJobStatus = r'''
mutation UpdateJobStatusSecure($jobId: String!, $status: String!, $updateType: String!) {
  updateJobStatusSecure(jobId: $jobId, status: $status, updateType: $updateType) {
    job
    error
  }
}''';

  static const claimProfessionalSelected = r'''
mutation ClaimProfessionalSelectedSecure($jobId: String!, $proposalId: String!) {
  claimProfessionalSelectedSecure(jobId: $jobId, proposalId: $proposalId) {
    proposal
    error
  }
}''';

  static const claimJobCompleted = r'''
mutation ClaimJobCompletedSecure($jobId: String!, $proposalId: String!, $actualEarnings: Int!, $earningsCurrency: String!, $actualEarningsIncludeMaterial: Boolean, $materialCost: Int, $userRating: Int!, $jobAccuracy: String!, $notes: String, $recommendClient: Boolean!, $completedAt: String!) {
  claimJobCompletedSecure(jobId: $jobId, proposalId: $proposalId, actualEarnings: $actualEarnings, earningsCurrency: $earningsCurrency, actualEarningsIncludeMaterial: $actualEarningsIncludeMaterial, materialCost: $materialCost, userRating: $userRating, jobAccuracy: $jobAccuracy, notes: $notes, recommendClient: $recommendClient, completedAt: $completedAt) {
    proposal
    error
  }
}''';

  static const resolveProposalClaim = r'''
mutation ResolveProposalClaimSecure($proposalId: String!, $decision: String!) {
  resolveProposalClaimSecure(proposalId: $proposalId, decision: $decision) {
    proposal
    error
  }
}''';

  static const markJobManualAccepted = r'''
mutation MarkJobManualAcceptedSecure($jobId: String!, $proposalId: String, $professionalId: String, $acceptedProName: String, $acceptedProPhone: String) {
  markJobManualAcceptedSecure(jobId: $jobId, proposalId: $proposalId, professionalId: $professionalId, acceptedProName: $acceptedProName, acceptedProPhone: $acceptedProPhone) {
    job
    error
  }
}''';

  static const reopenJobSelection = r'''
mutation ReopenJobSelectionSecure($jobId: String!) {
  reopenJobSelectionSecure(jobId: $jobId) {
    job
    error
  }
}''';

  static const completionEarningsForCustomer = r'''
query GetJobCompletionEarningsForCustomerSecure($jobId: String!) {
  getJobCompletionEarningsForCustomerSecure(jobId: $jobId) {
    completion
    error
  }
}''';
}
