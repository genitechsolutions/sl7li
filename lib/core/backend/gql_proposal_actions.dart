/// مستندات سحب العرض وتقييم الزبون (نفس شكل الموقع).
class GqlProposalActions {
  const GqlProposalActions._();

  static const withdrawProposal = r'''
mutation UpdateProposalStatusSecure($proposalId: String!, $status: String!, $customerResponse: String, $isWithdrawal: Boolean) {
  updateProposalStatusSecure(proposalId: $proposalId, status: $status, customerResponse: $customerResponse, isWithdrawal: $isWithdrawal) {
    proposal
    error
  }
}''';

  static const recordFeedback = r'''
mutation RecordCustomerFeedback($jobId: String!, $proposalId: String, $professionalId: String, $overallRating: Int!, $priceRating: Int!, $qualityRating: Int!, $ontimeRating: Int!, $responsivenessRating: Int!, $platformRating: Int!, $actualPrice: Int!, $priceCurrency: String!, $actualPriceIncludesMaterial: Boolean, $materialCost: Int, $writtenFeedback: String, $recommendProfessional: Boolean!, $jobAccuracyCustomer: String!, $submittedAt: String!) {
  recordCustomerFeedback(jobId: $jobId, proposalId: $proposalId, professionalId: $professionalId, overallRating: $overallRating, priceRating: $priceRating, qualityRating: $qualityRating, ontimeRating: $ontimeRating, responsivenessRating: $responsivenessRating, platformRating: $platformRating, actualPrice: $actualPrice, priceCurrency: $priceCurrency, actualPriceIncludesMaterial: $actualPriceIncludesMaterial, materialCost: $materialCost, writtenFeedback: $writtenFeedback, recommendProfessional: $recommendProfessional, jobAccuracyCustomer: $jobAccuracyCustomer, submittedAt: $submittedAt) {
    feedback
    error
  }
}''';
}
