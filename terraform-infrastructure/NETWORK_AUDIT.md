# Network Security Audit

Generated: 2026-06-17
Auditor: Olga Davladova
Account: 657840741348
Region: us-east-1

## Security Group Inventory

### olga-project-dev-alb-sg (Terraform-managed)
Purpose: Controls inbound traffic to the Application Load Balancer
No custom ingress or egress rules. This is correct — default SGs should remain empty.

### alb_sg (ALB Security Group)

| Rule | Direction | Protocol | Port | Source/Dest | Justification |
|------|-----------|----------|------|-------------|---------------|
| 1 | Ingress | TCP | 80 | 0.0.0.0/0 | [WHY does this rule exist?] |
| 2 | Egress | All | All | 0.0.0.0/0 | [WHY does this rule exist?] |

Production improvements:


Add HTTPS (443) ingress with ACM certificate
Redirect HTTP (80) to HTTPS, then remove port 80 entirely
Restrict egress to ECS tasks security group on port 3000 only

### ecs_tasks_sg (ECS Tasks Security Group)

Purpose: Restricts access to ECS containers — only the ALB can reach them

| Rule | Direction | Protocol | Port | Source/Dest | Justification |
|------|-----------|----------|------|-------------|---------------|
| 1 | Ingress | TCP | 3000 | alb_sg | App listens on port 3000; only the ALB should send traffic to it. Using SG reference instead of CIDR ensures only ALB traffic is allowed
| 2 | Egress | All | All | 0.0.0.0/0 | Required for ECR image pulls, CloudWatch Logs delivery, SSM for ECS Exec, and Secrets Manager access

Production improvements:


Create VPC endpoints for ECR, CloudWatch Logs, SSM, and Secrets Manager
Restrict egress to VPC endpoint security groups only — eliminates need for broad internet access
This is the highest-value security improvement available in this architecture

olga-project-dev-default (Terraform-managed)

Purpose: Default VPC security group — managed by Terraform to ensure no rules are added

No custom ingress or egress rules. This is correct — default SGs should remain empty.

EKS-managed security groups (AWS-managed)

These are created and managed by EKS and the AWS Load Balancer Controller. Manual modification is not recommended.

Name                            Purpose
eks-cluster-sg-olga-project-dev Control plane to worker node communication
k8s-default-hellowor-...        K8s LoadBalancer to hello-world service
k8s-traffic-olgaprojectdev-...  Shared backend for K8s load balancer traffic

## VPC Flow Logs

- Log group: /vpc-flow-logs/olga-project-dev
- Retention: 14 days
- Encryption: KMS (key: olga-project-dev-vpc-flow-logs-kms)
- Traffic captured: ALL (accept + reject)

### What Flow Logs capture
- Source/destination IP, ports, protocol
- Accept/reject action
- Bytes, packets, timestamps
- ENI ID, account ID, VPC ID

### What Flow Logs do NOT capture
- Packet payloads (content of traffic)
- IMDS traffic (169.254.169.254)
- DHCP traffic
- Amazon DNS traffic

## CloudWatch Insights — Rejected Traffic Query

fields @timestamp, srcAddr, dstAddr, dstPort, protocol, action
| filter action = "REJECT"
| stats count() as rejects by srcAddr, dstPort
| sort rejects desc
| limit 50

Results

Query executed against /vpc-flow-logs/olga-project-dev. No significant rejected traffic observed during the audit period. This is expected for a lab environment with limited external exposure.

NACL on Private Subnets

Rule    Direction    Action    Protocol      Port        CIDR              Purpose
90      Ingress      DENY      All           All         198.51.100.0/24   Placeholder blocklist (RFC 5737 TEST-NET-2)
100     Ingress      ALLOW     All           All         10.0.0.0/16       VPC internal traffic
110     Ingress      ALLOW     TCP           1024-65535  0.0.0.0/0         Return traffic — NACLs are stateless
100     Egress       ALLOW     All           All         0.0.0.0/0         Outbound traffic

Limitations of NACL blocklists

Static CIDR blocklists in NACLs are not effective at scale — real attackers rotate IPs faster than manual list updates. In production, use AWS WAF with the AWSManagedRulesAmazonIpReputationList managed rule group or AWS Network Firewall with Suricata rules for dynamic threat-feed blocking.

Defense in Depth

Network security uses three independent layers: Security Groups (per-resource, stateful, primary control), NACLs (per-subnet, stateless, backup layer), and VPC design (public/private subnet separation with NAT Gateway). If a security group is accidentally misconfigured, the NACL and subnet isolation still protect private resources. No single layer failing compromises the full stack.