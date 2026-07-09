--------------------------------------------------------------------
|                   GetServiceLastAccessedDetails                  |
+------------------------------------+-----------------------------+
|  Amazon Elastic Container Registry |  2026-06-10T21:35:17+00:00  |
|  Amazon CloudWatch Logs            |  2026-06-10T21:35:26+00:00  |
+------------------------------------+-----------------------------+
=== olga-project-dev-ecs-task-role ===
-----------------------------------------------------------------
|                 GetServiceLastAccessedDetails                 |
+---------------------------------+-----------------------------+
|  Amazon Message Gateway Service |  2026-06-20T12:26:21+00:00  |
+---------------------------------+-----------------------------+
=== olga-project-dev-eks-cluster-role ===
---------------------------------------------------------------------
|                   GetServiceLastAccessedDetails                   |
+-------------------------------------+-----------------------------+
|  Amazon EC2                         |  2026-06-20T13:05:05+00:00  |
|  AWS Identity and Access Management |  2026-04-18T16:16:08+00:00  |
|  AWS Key Management Service         |  2026-06-20T13:06:16+00:00  |
+-------------------------------------+-----------------------------+
=== olga-project-dev-eks-nodes-role ===
--------------------------------------------------------------------
|                   GetServiceLastAccessedDetails                  |
+------------------------------------+-----------------------------+
|  Amazon EC2                        |  2026-06-20T12:54:24+00:00  |
|  Amazon Elastic Container Registry |  2026-04-20T15:25:19+00:00  |
+------------------------------------+-----------------------------+
=== olga-project-dev-cloudtrail-cw-role ===
---------------------------------------------------------
|             GetServiceLastAccessedDetails             |
+-------------------------+-----------------------------+
|  Amazon CloudWatch Logs |  2026-06-20T13:09:29+00:00  |
+-------------------------+-----------------------------+
=== olga-project-dev-vpc-flow-logs-role ===
---------------------------------------------------------
|             GetServiceLastAccessedDetails             |
+-------------------------+-----------------------------+
|  Amazon CloudWatch Logs |  2026-06-20T13:11:51+00:00  
ec2_role — never used. The EC2 instance has S3 read permissions but hasn't accessed any AWS service. Either the instance is idle or it doesn't need the role. Recommendation: verify if the EC2 instance is still needed.
ecs_task_execution — SSM/KMS granted, not used recently. These are for Secrets Manager injection (KMS) and ECS Exec (SSM). Acceptable to keep — they're used on-demand, not continuously
ssmmessages actions require Resource: * — AWS does not support resource-level permissions for these actions.

aws iam get-role --role-name olga-project-dev-ec2-role --query 'Role.PermissionsBoundary' --region us-east-1

{
    "PermissionsBoundaryType": "Policy",
    "PermissionsBoundaryArn": "arn:aws:iam::657840741348:policy/olga-project-developer-boundary"
}

Boundary verified attached to ec2_role. Direct assume-role test not possible because trust policy correctly restricts to EC2 service only.


terraform state pull | grep -i "PLACEHOLDER"

"secret_string": "{\"password\":\"PLACEHOLDER_CHANGE_ME\",\"username\":\"appuser\"}",

The initial placeholder secret value appears in the remote state file. In production: (1) rotate the real password via CLI immediately after first apply, (2) lifecycle { ignore_changes } prevents Terraform from overwriting the rotated value, (3) restrict state file access via S3 bucket policy and encryption, (4) never put real credentials in Terraform code.
