# Compliance Report — CIS AWS Foundations Benchmark v1.4.0

Generated: 2026-06-25
Account: 657840741348
Region: us-east-1
Auditor: Olga Davladová

## Score

Total findings: 16
Passed: 0
Failed: 15 (1 CRITICAL,14 LOW)
Other: 1

Security Hub enabled: 2026-06-20

## CRITICAL Findings

| Finding | Status | Remediation |
|---------|--------|-------------|
| AWS Config should be enabled | FAILED | Blocked by organization SCP (p-4imjfeof). Config cannot be enabled in this account without org admin approval. Escalated to mentor. |

## LOW Findings — Missing Metric Filter Alarms

These are CIS 4.x controls requiring CloudWatch metric filters that we did not implement. We implemented 4 of the ~14 CIS-recommended alarms.

| Finding | Status | Remediation |
|---------|--------|-------------|
| Log metric filter for AWS Config changes | FAILED | Not implemented — lower priority |
| Log metric filter for S3 bucket policy changes | FAILED | Not implemented — add to alarms.tf |
| Log metric filter for CMK deletion/disabling | FAILED | Not implemented — add to alarms.tf |
| Log metric filter for console auth failures | FAILED | Not implemented — add to alarms.tf |
| Log metric filter for CloudTrail config changes | FAILED | Not implemented — add to alarms.tf |
| Log metric filter for IAM policy changes | FAILED | Not implemented — add to alarms.tf |
| Log metric filter for VPC changes | FAILED | Not implemented — add to alarms.tf |
| Log metric filter for route table changes | FAILED | Not implemented — add to alarms.tf |
| Log metric filter for network gateway changes | FAILED | Not implemented — add to alarms.tf |
| Log metric filter for NACL changes | FAILED | Not implemented — add to alarms.tf |

## What We Implemented (4 alarms)

| Alarm | CIS Ref | Status |
|-------|---------|--------|
| Unauthorized API calls | CIS 4.1 | PASS |
| Console login without MFA | CIS 4.2 | PASS |
| Root account usage | CIS 4.3 | PASS |
| Security group changes | CIS 4.10 | PASS |

## Accepted Risks

1. **AWS Config** — blocked by organization SCP. Compensating control: Security Hub CIS benchmark provides detective monitoring. Escalated to org admin.
2. **Missing metric filter alarms** — 10 additional CIS 4.x alarms not implemented. These are LOW severity. Remediation: add remaining filters to alarms.tf in next sprint. Estimated effort: 2 hours (same pattern as existing 4 alarms).
3. 0 passed findings — Security Hub CIS evaluation coverage is reduced because AWS Config is disabled. Many CIS checks depend on Config data. With Config enabled, the passed count would be significantly higher based on the security controls already in place (KMS encryption, CloudTrail logging, IAM boundaries, VPC Flow Logs)


## Security Controls in Place (Not Reflected in Score)

These controls are deployed and functional but may not appear as Security Hub findings due to Config being disabled:

ControlStatusCloudTrail multi-region with KMS encryptionActiveCloudTrail log file validationActiveCloudTrail S3 bucket — public access blocked, versioned, encryptedActiveVPC Flow Logs with KMS encryptionActiveIAM permission boundary on ec2_roleActiveEKS Pod Security Admission — restricted enforcedActiveEKS RBAC — developer role with read-only accessActiveEKS NetworkPolicy — pod-to-pod traffic restrictedActiveSecrets Manager with KMS — injected to ECS and EKS at runtimeActiveGuardDuty threat detectionActiveS3 buckets — all encrypted, public access blockedActive

## Cost Awareness

Service                          Estimated cost
Security Hub                     ~$0.001 per finding check per day
GuardDuty                        Usage-based, ~$5/month for low-traffic lab
CloudTrail (management events)   Free (1 trail)
CloudWatch Logs                  ~$0.50/GB ingestedKMS keys$1/month per key (6 keys active)

Recommendation: disable Security Hub and GuardDuty when the lab is complete to avoid ongoing charges.

## Next Review

2026-07-25 (30 days)