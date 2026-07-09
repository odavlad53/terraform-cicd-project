data "aws_iam_policy_document" "developer_boundary" {
  #checkov:skip=CKV_AWS_49:Permission boundary intentionally uses Allow * as ceiling
  #checkov:skip=CKV_AWS_1:Permission boundary intentionally uses Allow * as ceiling
  #checkov:skip=CKV_AWS_110:Permission boundary uses Deny statements to prevent escalation
  #checkov:skip=CKV_AWS_108:Permission boundary uses Deny statements to limit data access
  #checkov:skip=CKV_AWS_107:Permission boundary uses Deny statements to limit credentials
  #checkov:skip=CKV2_AWS_40:Permission boundary intentionally uses Allow * as ceiling
  statement {
    sid       = "AllowEverythingByDefault"
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
  }

  statement {
    sid    = "DenyIAMUserManipulation"
    effect = "Deny"
    actions = [
      "iam:CreateUser",
      "iam:DeleteUser",
      "iam:CreateLoginProfile",
      "iam:CreateAccessKey",
      "iam:UpdateAccessKey",
      "iam:AttachUserPolicy",
      "iam:PutUserPolicy"
    ] # list the IAM actions to block
    resources = ["*"]
  }

  statement {
    sid    = "DenyOrgAndAccountActions"
    effect = "Deny"
    actions = [
      "organizations:*",
      "account:*",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "DenyBoundaryModification"
    effect = "Deny"
    actions = [
      "iam:DeleteRolePermissionsBoundary",
      "iam:PutRolePermissionsBoundary"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "DenyPassRoleToAdmin"
    effect = "Deny"
    actions = [
      "iam:PassRole"
    ]

    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*Admin*"]
  }

  statement {
    sid    = "DenyCreateRoleWithoutBoundary"
    effect = "Deny"
    actions = [
      "iam:CreateRole"
    ]
    resources = ["*"]
    condition {
      test     = "StringNotEquals"
      variable = "iam:PermissionsBoundary"
      values   = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.project_name}-developer-boundary"]
    }
  }

}

resource "aws_iam_policy" "developer_boundary" {
  name   = "${var.project_name}-developer-boundary"
  policy = data.aws_iam_policy_document.developer_boundary.json

  tags = {
    Name        = "${var.project_name}-developer-boundary"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
