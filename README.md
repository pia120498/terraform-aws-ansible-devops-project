# AWS Infrastructure as Code with Terraform

## Project Overview

Production-ready AWS infrastructure automation demonstrating Infrastructure as Code best practices, state management, and cloud monitoring.

**Key Features:**
- Modular VPC architecture with public/private subnets
- EC2 compute with security hardening
- Remote state with S3 backend & DynamoDB locking
- CloudWatch alarms with SNS email notifications
- Production-grade infrastructure automation

---

## Technologies

**Infrastructure:** Terraform, AWS (VPC, EC2, S3, DynamoDB, CloudWatch, SNS, IAM)  
**Compute:** Amazon Linux 2023, Apache Web Server

---

## Project Structure

```
terraform/
├── main.tf                 # Provider & primary config
├── vpc.tf                  # VPC & networking resources
├── iam.tf                  # IAM roles & policies
├── securityGroup.tf        # Security group rules
├── cloudwatch.tf           # Monitoring & alarms
├── sns.tf                  # Alert notifications
├── state-lock.tf           # DynamoDB locking config
├── modules/
│   └── vpc/                # Reusable VPC module
└── backup/                 # State backend configs
    ├── s3-state.tf
    ├── s3-versioning.tf
    └── s3-lifecycle.tf
```

---

## Infrastructure Delivered

- **Networking:** Custom VPC with public/private subnets, IGW, route tables
- **Compute:** EC2 instance with security groups and IAM roles
- **State Management:** S3 backend with versioning & DynamoDB state locking
- **Monitoring:** CloudWatch alarms + SNS email alerts for CPU utilization
- **Modularity:** Reusable VPC module for scalability

---

## Quick Start

### Prerequisites
- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [AWS CLI](https://aws.amazon.com/cli/)
- AWS credentials configured: `aws configure`

### Deploy

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

Access the application via the EC2 public IP output.



---

## Production Features

**State Management:** Remote S3 backend with DynamoDB locking prevents concurrent executions and state corruption.

**Monitoring & Alerts:** CloudWatch monitors EC2 CPU utilization and triggers SNS email notifications when thresholds are exceeded.

**Security:** IAM roles enforce least privilege, security groups restrict traffic, subnets isolate resources.

**Modularity:** Reusable VPC module enables rapid infrastructure scaling.

---

## Key Highlights

✓ **Production-Grade Setup:** Implements best practices for enterprise infrastructure  
✓ **Infrastructure as Code:** Fully version-controlled, repeatable deployments  
✓ **Monitoring & Observability:** Real-time alerts for operational awareness  
✓ **State Locking:** Prevents deployment conflicts in team environments  
✓ **Security Focused:** IAM roles, security groups, and network segmentation

---

## Screenshots

### Terraform Deployment
<img width="1350" height="747" alt="terraform-apply-success" src="https://github.com/user-attachments/assets/92dff01f-3d5f-449c-8ae9-d603e0cb9d4f" />

### EC2 Instance
<img width="1873" height="755" alt="running-ec2-instance" src="https://github.com/user-attachments/assets/16498664-c220-478a-9c97-1272d422c9f3" />

### Web Server Running
<img width="1251" height="432" alt="application-running" src="https://github.com/user-attachments/assets/b07865c7-1537-4525-9eb2-5f16bdc2c9ea" />

### S3 Remote Backend
<img width="1856" height="832" alt="state-file-s3-versioning" src="https://github.com/user-attachments/assets/6e77a7b3-2de4-4955-ab4a-70cd9f532a2c" />

### DynamoDB State Lock
<img width="1870" height="785" alt="dynamodb-lock" src="https://github.com/user-attachments/assets/4b3820f5-4245-4264-aa00-cfbba54d450a" />

### CloudWatch Alarm
<img width="1907" height="595" alt="CloudWatch-alarm-triggered" src="https://github.com/user-attachments/assets/9b991797-4bb2-496a-870f-d9ddaeee5d7a" />

### SNS Email Notification
<img width="1917" height="1012" alt="sns-mail-notification" src="https://github.com/user-attachments/assets/fb378549-b0d6-4e59-962b-8f2beb4c852e" />

---
