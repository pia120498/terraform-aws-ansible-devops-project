# Terraform AWS Ansible Project Notes

## Day 1

### Goal
Learn Terraform by building infrastructure incrementally.

### Completed
- Installed Terraform
- Configured AWS CLI
- Created S3 bucket using Terraform
- Destroyed S3 bucket
- Configured dynamic AMI lookup using SSM Parameter Store

### Issue Faced
AccessDeniedException for ssm:GetParameters

### Resolution
Updated IAM permissions to allow access to AWS Systems Manager Parameter Store.

### Learning
Terraform data sources read existing information. They do not create resources.

An EC2 instance may need to interact with AWS services such as SSM, S3, CloudWatch, or Secrets Manager. Instead of storing AWS access keys on the server, we attach an IAM Role to the EC2 instance. The permissions granted by the policies attached to that role are provided to the instance through temporary credentials.

Can we attach a policy directly to an EC2 instance? No. Policies are attached to IAM users, groups, or roles. For EC2, we create an IAM Role and attach it to the instance through an IAM Instance Profile.

## Day 1 - Partial Terraform Apply

### Problem

Terraform apply failed while creating an IAM role.

### Error

AccessDenied: iam:CreateRole

### Root Cause

The terraform IAM user lacked permission to create IAM roles.

### Observation

The Security Group was successfully created before the failure.

### Learning

Terraform does not automatically roll back successful resources when a later resource fails. Successfully created resources remain in the Terraform state file and are managed by future terraform apply operations.
