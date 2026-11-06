/// تعديل طلب مفتوح (updateJob = موديل الطلب مباشرة، المالك بس).
class GqlJobEdit {
  GqlJobEdit._();

  static const updateJob = r'''
mutation UpdateJob($input: UpdateJobInput!) {
  updateJob(input: $input) {
    job_id
    title
    description
    urgency
    city_code
    status
    share_whatsapp_with_professionals
  }
}''';
}
