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

## Scan Results

Date: 2026-07-10
Image: 657840741348.dkr.ecr.us-east-1.amazonaws.com/olga-project-dev-app:latest
Base image: Alpine 3.23.3
Scanner: Trivy v0.69

### Findings

- CRITICAL: 0
- HIGH: 0

No vulnerabilities found at CRITICAL or HIGH severity. The Alpine base image and Node.js dependencies are current and patched.

### Resolution

No remediation required. Clean scan. The .trivyignore file is empty — no exceptions needed.

### Notes

- Alpine minimal base image keeps the attack surface small (28 packages total)
- Full scan includes both OS packages and Node.js dependencies
- CI/CD pipeline will block future deployments if CRITICAL or HIGH CVEs are introduced