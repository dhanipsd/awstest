# AWS Node.js + Nginx + CentOS 7 Deployment (Terraform)

## Features

- Automation application files via Terraform
- Node.js app auto-starts on boot
- Terraform outputs:
  - Public IP
  - HTTPS URL
  - SSH command

## Requirements

- Terraform ≥ 1.3
- AWS credentials configured (`aws configure`)
- AWS CentOS 7 AMI ID
- SSH public & private keys

## Deployment Instructions

Run these commands inside the `awstest/` folder:

### 1. Initialize Terraform

terraform init

### 2. Apply the infrastructure

<pre>terraform apply -var="centos7_ami=ami-xxxxxxxx" -var="public_key_path=~/.ssh/id_rsa.pub" -var="private_key_path=~/.ssh/id_rsa"</pre>

## Access the Application

After deployment Terraform prints:

public_ip = "54.221.xxx.xxx"

Open the application in your browser:

https://public_ip

## SSH Access

Terraform also prints the SSH command:

ssh -i ~/.ssh/id_rsa centos@<EC2_PUBLIC_IP>

Replace with your key path if needed.