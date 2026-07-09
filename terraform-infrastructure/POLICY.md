# Container Image Security Policy

## Vulnerability Threshold

- CRITICAL: Always block — build fails, no exceptions
- HIGH: Block by default — exceptions require documented justification in .trivyignore
- MEDIUM/LOW: Allow — reviewed monthly

## Exception Process

1. Developer identifies a false positive or unfixable CVE
2. Add CVE ID to .trivyignore with justification and review date
3. Review date must be within 30 days
4. Exceptions reviewed in monthly security meeting

## Image Signing

All images pushed to ECR are signed using cosign keyless mode (Sigstore).
Signing identity: GitHub Actions workflow OIDC token.
Verification required before deployment to ECS.

## Base Image Hygiene

- Use minimal base images (alpine or distroless preferred)
- Update base images monthly
- Pin base image versions by digest, not tag

## Scan Cadence

- Every build: Trivy scan in CI/CD pipeline
- Weekly: ECR scan-on-push results reviewed
- Monthly: Full review of .trivyignore exceptions