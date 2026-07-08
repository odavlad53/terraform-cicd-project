# Monitoring & Detection

Generated: 2026-06-25
Account: 657840741348
Region: us-east-1

## CloudTrail

- Trail: olga-project-dev-trail
- Multi-region: yes
- Log file validation: enabled
- S3 bucket: olga-project-dev-cloudtrail-657840741348 (KMS encrypted)
- S3 access logging: enabled, delivering to olga-project-dev-cloudtrail-access-logs-657840741348
- CloudWatch Logs delivery: /aws/cloudtrail/olga-project-dev (14-day retention)
- KMS key: olga-project-dev-cloudtrail-cmk (rotation enabled)
- Confused deputy prevention: aws:SourceArn condition on both S3 bucket policy and KMS key policy

## CloudWatch Alarms

| Alarm | CIS Ref | Detects | Why it matters |
|-------|---------|---------|----------------|
| UnauthorizedAPICalls | 4.1 | AccessDenied errors | Credential abuse or misconfigured automation |
| ConsoleLoginWithoutMFA | 4.2 | Console login without MFA (IAMUser only) | Possible credential compromise |
| RootAccountUsage | 4.3 | Any API call by root account | Root should never be used for daily work |
| SecurityGroupChanges | 4.10 | Security group create/modify/delete | Network attack surface changed |

Notification: SNS topic olga-project-dev-security-alerts
Subscribed email: olga.davlad@trustsoft.eu

## GuardDuty

- Detector: enabled
- Protection plans: default (CloudTrail, VPC Flow Logs, DNS)
- Findings: integrated with Security Hub automatically
- Free trial: 30-day trial per account, then usage-based billing

## Organizational Constraints


SNS email notifications blocked by organization SCP — alerts can be monitored via CloudWatch Alarms console and Security Hub findings instead
AWS Config blocked by organization SCP — Security Hub CIS benchmark provides equivalent detective monitoring as a compensating control

## Known Limitations

- ConsoleLoginWithoutMFA scoped to IAMUser to avoid SSO false positives
- Only 4 of ~14 CIS 4.x alarms implemented (remaining 10 are LOW severity, documented in COMPLIANCE_REPORT.md)
- GuardDuty EKS Audit Logs protection not explicitly enabled (verify and enable if needed)
- RootAccountUsage filter excludes invokedBy (service-linked operations) and AwsServiceEvent to reduce noise from AWS internal operations