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

## Day 2

### Goal

Provision an EC2 instance using Terraform without SSH keys by using AWS Systems Manager (SSM) Session Manager.

### Completed

- Created Security Group
- Created IAM Role for EC2
- Attached AmazonSSMManagedInstanceCore policy
- Created IAM Instance Profile
- Launched EC2 instance (t2.micro)
- Verified Terraform state tracking
- Connected to EC2 using Session Manager
- Pushed project updates to GitHub

---

### Resources Created

1. aws_security_group.web_sg
2. aws_iam_role.ec2_ssm_role
3. aws_iam_role_policy_attachment.ssm_policy
4. aws_iam_instance_profile.ec2_profile
5. aws_instance.web_server

---

### Challenges Faced

#### Challenge 1 - Running Terraform From Wrong Directory

##### Error

```text
Error: No configuration files
```

##### Root Cause

Terraform was executed from the project root instead of the terraform directory containing the .tf files.

##### Resolution

```powershell
cd terraform
```

##### Learning

Terraform commands must be executed from the directory containing the Terraform configuration files unless a different working directory is specified.

---

#### Challenge 2 - IAM Role Creation Failed

##### Error

```text
AccessDenied: iam:CreateRole
```

##### Root Cause

The terraform IAM user lacked permission to create IAM roles.

##### Resolution

Granted the required IAM permissions and re-ran:

```powershell
terraform apply
```

##### Learning

Terraform does not automatically roll back resources that were successfully created before a failure occurs.

---

### Terraform State Learning

Useful command:

```powershell
terraform state list
```

Current managed objects:

```text
data.aws_ssm_parameter.amazon_linux
aws_iam_instance_profile.ec2_profile
aws_iam_role.ec2_ssm_role
aws_iam_role_policy_attachment.ssm_policy
aws_instance.web_server
aws_security_group.web_sg
```

Learning:

Terraform uses the state file to track managed infrastructure and compare the current state against the desired state.

---

### Resource vs Data Source

#### Resource

Creates and manages infrastructure.

Example:

```hcl
resource "aws_instance" "web_server" {}
```

#### Data Source

Reads information from existing infrastructure without creating it.

Example:

```hcl
data "aws_ssm_parameter" "amazon_linux" {}
```

Learning:

Resources are managed by Terraform. Data sources are read-only.

---

### Dynamic AMI Lookup

Instead of hardcoding an AMI ID:

```hcl
ami = "ami-123456"
```

Use:

```hcl
ami = data.aws_ssm_parameter.amazon_linux.value
```

Benefits:

- Automatically gets the latest approved AMI
- Easier maintenance
- Better production practice
- Reusable code across environments

---

### IAM Role, Policy and Instance Profile

Relationship:

```text
EC2 Instance
      |
      v
IAM Instance Profile
      |
      v
IAM Role
      |
      v
IAM Policy
```

Explanation:

- Policy defines permissions.
- Role receives policies.
- Instance Profile contains the role.
- EC2 uses the Instance Profile to obtain temporary credentials.

---

### Why Session Manager Instead of SSH?

Traditional Method:

```text
EC2
 |
SSH
 |
PEM Key
```

Modern Method:

```text
EC2
 |
IAM Role
 |
SSM Agent
 |
Session Manager
```

Benefits:

- No PEM file management
- No open port 22
- Improved security
- Common production practice

---

### Terraform Dependency Graph

Terraform automatically creates resources in the correct order based on references.

Example:

```text
EC2 Instance
    |
    +--> Security Group
    |
    +--> Instance Profile
             |
             +--> IAM Role
                       |
                       +--> SSM Policy
```

Learning:

Terraform automatically builds a dependency graph and determines creation order.

---

### Terraform Refresh

Before generating a plan, Terraform refreshes the current state of managed resources.

Example output:

```text
Refreshing state...
```

Purpose:

- Reads actual infrastructure state from AWS
- Compares actual state with desired configuration
- Identifies resources that need to be created, modified, or destroyed

---

### Default VPC Learning

No VPC or subnet was explicitly created.

AWS automatically placed resources inside:

```text
Default VPC
     |
Default Subnet
     |
EC2 Instance
```

Observed:

```text
VPC ID:
vpc-03199c7dc98d3aada

Subnet ID:
subnet-0326ea8ff5363e0a5
```

Learning:

If no VPC or subnet is specified, AWS automatically uses the Default VPC and one of its default subnets.

---

### EC2 Instance Details

```text
Instance Type: t2.micro
Region: us-east-1
State: running
Connection Method: Session Manager
SSH Key Pair: Not Used
```

Observed:

```text
Public IP: 54.221.40.188
Private IP: 172.31.22.67
```

Learning:

The EC2 instance received a public IP because it was launched in a default subnet with public IP assignment enabled.

---

### Interview Questions Learned

#### Q: What is the difference between a Resource and a Data Source?

A:

A Resource creates and manages infrastructure. A Data Source reads existing infrastructure information without creating anything.

---

#### Q: Why use SSM Parameter Store for AMI lookup?

A:

To dynamically retrieve the latest approved AMI and avoid hardcoding AMI IDs in Terraform code.

---

#### Q: Why use an IAM Role instead of AWS Access Keys on EC2?

A:

IAM Roles provide temporary credentials securely without storing long-term access keys on the server.

---

#### Q: Why is an Instance Profile required?

A:

EC2 instances cannot directly use IAM Roles. AWS requires an Instance Profile to attach the IAM Role to the EC2 instance.

---

#### Q: How did EC2 receive a subnet when none was specified?

A:

AWS automatically selected a subnet from the Default VPC.

---

#### Q: How do you access the EC2 instance?

A:

Using AWS Systems Manager Session Manager through an IAM Role and Instance Profile without opening port 22 or using SSH keys.

---

#### Q: Why didn't Terraform recreate existing resources during subsequent applies?

A:

Terraform refreshed the current state, compared it with the desired state, and determined that the existing resources already matched the configuration.


## Day 2 - EC2 Bootstrap with User Data

### Goal

Automatically install and configure Apache web server during EC2 launch using Terraform user_data.

### Changes Made

- Added aws_instance resource
- Attached Security Group
- Attached IAM Instance Profile
- Added user_data script to:
  - Update packages
  - Install Apache (httpd)
  - Start Apache service
  - Enable Apache on boot
  - Create index.html

### Issue Faced

Terraform showed the user_data script in the EC2 configuration, but Apache was not installed and the website was not accessible.

### Investigation

Verified:

- Terraform state contained the EC2 instance
- user_data was present in Terraform state
- user_data was available through cloud-init
- Script existed in:
  - /var/lib/cloud/instance/user-data.txt
  - /var/lib/cloud/instance/scripts/part-001

However:

- httpd service was missing
- index.html was not created
- curl localhost failed

### Root Cause

The user_data script was added after the original EC2 instance had already been launched.

Cloud-init executes user_data only during the first boot of an instance. Updating user_data on an already-running instance does not automatically rerun the script.

### Resolution

Marked the EC2 instance as tainted:

terraform taint aws_instance.web_server

Terraform then planned a replacement:

- Destroy old EC2
- Create new EC2
- Execute user_data during first boot

### Verification

Confirmed:

sudo systemctl status httpd

Output:

active (running)

Confirmed:

curl localhost

Output:

<h1>Hello from Terraform</h1>

Confirmed:

sudo cat /var/www/html/index.html

Output:

<h1>Hello from Terraform</h1>

### Learning

Terraform can replace a resource without recreating its dependencies.

During EC2 replacement:

- Security Group was reused
- IAM Role was reused
- Policy Attachment was reused
- Instance Profile was reused

Only the EC2 instance was destroyed and recreated.

### Key Concept

user_data is a bootstrap script executed by cloud-init during the first boot of an EC2 instance.

Changing user_data later updates the EC2 metadata but does not automatically rerun the script.



# Day 3 - Introduction to Ansible

## Goal

Learn Ansible basics and understand how it differs from Terraform.

Terraform provisions infrastructure.

Ansible manages configuration inside servers.

Example:

Terraform creates an EC2 instance.

Ansible installs and manages Apache inside the EC2 instance.

---

## Installing Ansible

Connected to the EC2 instance using AWS Session Manager and installed Ansible.

```bash
sudo dnf install -y ansible-core
```

Verified installation:

```bash
ansible --version
```

---

## Ansible Working Directory

Moved to home directory:

```bash
cd ~
```

Created project directory:

```bash
mkdir ansible-demo
cd ansible-demo
```

Verified location:

```bash
pwd
```

Output:

```text
/home/ssm-user/ansible-demo
```

---

## Inventory File

Created inventory file:

```ini
[web]
localhost ansible_connection=local
```

### Learning

Inventory defines the hosts Ansible will manage.

Normally inventory contains remote servers.

For learning purposes, Ansible was configured to manage the local machine.

---

## Ansible Ad-Hoc Commands

### Ping Test

```bash
ansible web -i inventory.ini -m ping
```

Output:

```text
pong
```

### Learning

Ansible successfully connected to the target host and executed the ping module.

---

### Execute Commands

```bash
ansible web -i inventory.ini -a "uptime"
```

Output displayed server uptime.

### Learning

Ad-hoc commands allow one-time execution of commands without creating playbooks.

Useful for quick checks and troubleshooting.

---

## First Playbook

Created:

```yaml
---
- name: My First Playbook
  hosts: web
  gather_facts: no

  tasks:
    - name: Check uptime
      command: uptime
```

Executed:

```bash
ansible-playbook -i inventory.ini first-playbook.yml
```

### Learning

Playbooks define automation tasks using YAML.

Tasks are executed sequentially.

---

## Understanding gather_facts

By default Ansible gathers system information before executing tasks.

Examples:

- OS information
- Hostname
- IP addresses
- CPU details
- Memory information

This appears as:

```text
TASK [Gathering Facts]
```

Facts can be used later in playbooks for conditional logic and automation.

---

## Apache Playbook

Created:

```yaml
---
- name: Manage Apache Web Server
  hosts: web
  become: yes

  tasks:

    - name: Ensure Apache is installed
      package:
        name: httpd
        state: present

    - name: Ensure Apache is running
      service:
        name: httpd
        state: started
        enabled: yes

    - name: Create custom homepage
      copy:
        content: "<h1>Managed by Ansible</h1>"
        dest: /var/www/html/index.html
```

Executed:

```bash
ansible-playbook -i inventory.ini apache.yml
```

---

## Understanding become

```yaml
become: yes
```

### Learning

Ansible uses sudo privileges when tasks require administrative access.

Equivalent to:

```bash
sudo
```

Without become, Ansible would not be able to:

- Install packages
- Start services
- Modify system files

---

## Understanding Modules

### package module

```yaml
package:
  name: httpd
  state: present
```

Ensures Apache is installed.

### service module

```yaml
service:
  name: httpd
  state: started
  enabled: yes
```

Ensures service is running and starts automatically after reboot.

### copy module

```yaml
copy:
  content: "<h1>Managed by Ansible</h1>"
  dest: /var/www/html/index.html
```

Creates or updates a file with desired content.

---

## Idempotency

### First Run

```text
ok=4
changed=1
```

Reason:

Homepage file was created.

### Second Run

```text
ok=4
changed=0
```

Reason:

Desired state already existed.

No changes were necessary.

### Learning

Ansible is idempotent.

Running the same playbook multiple times produces the same result without making unnecessary changes.

---

## Configuration Drift

Simulated drift:

```bash
sudo sh -c 'echo "<h1>I broke the server 😈</h1>" > /var/www/html/index.html'
```

Verified:

```bash
cat /var/www/html/index.html
```

Output:

```html
<h1>I broke the server 😈</h1>
```

Ran playbook again:

```bash
ansible-playbook -i inventory.ini apache.yml
```

Result:

```text
changed=1
```

Verified:

```bash
cat /var/www/html/index.html
```

Output:

```html
<h1>Managed by Ansible</h1>
```

### Learning

Ansible detected that the actual state differed from the desired state.

It automatically restored the configuration defined in the playbook.

This is called Configuration Drift Remediation.

---

## Terraform vs Ansible

Terraform manages infrastructure.

Examples:

- EC2
- VPC
- Security Groups
- IAM Roles
- Load Balancers

Ansible manages server configuration.

Examples:

- Packages
- Services
- Users
- Files
- Application Configuration

Terraform creates the server.

Ansible configures the server.

---

## Key Interview Concepts Learned

### What is an Inventory?

A file that contains the list of hosts managed by Ansible.

### What is a Playbook?

A YAML file containing automation tasks.

### What is a Module?

A reusable Ansible component that performs a specific action.

Examples:

- package
- service
- copy
- command
- ping

### What is Idempotency?

Running the same automation repeatedly produces the same result without causing unnecessary changes.

### What is Configuration Drift?

A situation where the actual server configuration differs from the desired configuration.

### How does Ansible handle Configuration Drift?

Ansible compares the current state with the desired state and applies only the required changes to restore compliance.

### Difference Between Terraform and Ansible

Terraform:
Infrastructure Provisioning

Ansible:
Configuration Management