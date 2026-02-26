# GitOps Workflow Guide

## Branch Strategy
- main - Production environment (protected)
- develop - Development environment
- feature/* - Feature branches

## Workflow Rules
1. Never commit directly to main
2. All changes via Pull Requests
3. Require code review before merge
4. All tests must pass
5. Infrastructure as Code only

## Making Changes
1. Create feature branch:
   git checkout -b feature/add-new-resource

2. Make changes to Terraform code

3. Test locally:
   terraform fmt
   terraform validate
   terraform plan

4. Commit and push:
   git add .
   git commit -m "feat: add new S3 bucket for logs"
   git push origin feature/add-new-resource

5. Create Pull Request on GitHub
6. Wait for CI/CD checks to pass
7. Request review from team member
8. After approval, merge to main
9. Monitor the automatic deployment

## Security Checklist
- [ ] No secrets in code
- [ ] All resources tagged
- [ ] Encryption enabled
- [ ] Least privilege IAM
- [ ] Security scans passed
- [ ] Code reviewed
