# Backend environment (read from the devqa web app bundle, 2026-11-01)

Source: https://devqa.d1rbzpk5f88ird.amplifyapp.com/ (Next.js pages-router app on Amplify Hosting; Arabic/RTL).
Only the public client bundle was read. No API was called, nothing was authenticated.
API keys are intentionally NOT recorded here.

## devqa (what the site uses by default: `REACT_APP_ENV` unset -> "devqa")
- Region: us-east-2
- Auth: Cognito User Pool `us-east-2_GzDE0xy0O`, app client `3237ebmib6230h1fcnc6edadtg`
- Identity pool: `us-east-2:37d044db-0e7b-4c85-b653-d6a645e2a49b` (unauthenticated identities enabled)
- Sign-in: phone number is the username (SMS verification); MFA off; password min 8, no complexity
- AppSync GraphQL: https://khlnguhv6jfa3l476zlirvz7ay.appsync-api.us-east-2.amazonaws.com/graphql
  - default auth: Cognito user pool; also enabled: API key, IAM
- Files: S3 bucket `amplify-d1rbzpk5f88ird-de-salehliuserfilesbucketa2-azqrkmwwggul`, served via https://devqa-resources.salehli.com/<key>
- Table suffix: `zmd2bbr34nforj5avxyz3lz2dy-NONE`

## production (also shipped inside the same bundle)
- API: https://api.salehli.com/graphql (AppSync custom domain), pool `us-east-2_OEcZGOijK`, client `2lbb91hdhssguk5t0o1ggb4ke4`,
  identity pool `us-east-2:a030aaba-6005-4bd8-813f-823450f20167`, resources https://resources.salehli.com/

## Other
- Analytics: Amplitude. Marketing: Meta pixel (fbq).
- Gen2 data models (partial): User, Professional, Manager, Job, JobProposal, JobCompletion, CustomerFeedback, Conversation, Message,
  Notification(+Preferences/Template/Batch), Offer, ProfessionalWallet, WalletTransaction, GovernmentIdVerification, Referral,
  ServiceReport, Institution(+Site/Asset/Bill), AccountDeletionAudit, ...
- Custom queries/mutations are named `*Secure` (getCurrentUserSecure, createJobSecure, createJobProposalSecure, createOfferSecure,
  getSecureUserConversations, generateUploadUrlSecure, deleteAccountSecure, resendOtpSecure, ...).
