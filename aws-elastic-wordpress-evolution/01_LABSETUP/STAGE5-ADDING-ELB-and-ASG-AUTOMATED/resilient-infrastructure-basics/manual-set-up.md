# AWS Environment Setup Guide for Beginners

This guide provides detailed instructions for setting up a scalable and accessible web application infrastructure on AWS.

## Prerequisites
- AWS Account
- Basic understanding of AWS services

## STEP 1 - Create a Custom VPC

1. **Navigate to VPC Dashboard**: Open the VPC console at https://console.aws.amazon.com/vpc/.
2. **Create VPC**:
   - Click `Create VPC`.
   - Set `Name tag` to `Custom-VPC`.
   - Enter the `IPv4 CIDR block`, e.g., `10.0.0.0/16`.
   - Check `Enable DNS hostname`.
   - Click `Create`.

## STEP 2 - Create Subnets

1. **Create three public subnets**:
   - For each subnet (in `us-east-1a`, `us-east-1b`, `us-east-1c`):
     - Click `Subnets` > `Create subnet`.
     - Set `Name tag`, e.g., `Public-Subnet-1a`.
     - Select `Custom-VPC`.
     - Set the `IPv4 CIDR block`, e.g., `10.0.1.0/24` for `us-east-1a`.
     - Click `Create`.

## STEP 3 - Set Up an Internet Gateway

1. **Create Internet Gateway**:
   - Click `Internet Gateways` > `Create internet gateway`.
   - Set `Name tag` to `Custom-IGW`.
   - Click `Create`.
2. **Attach to VPC**:
   - Select the created IGW.
   - Click `Actions` > `Attach to VPC`.
   - Select `Custom-VPC`.
   - Click `Attach`.

## STEP 4 - Configure Route Tables

1. **Create Route Table**:
   - Click `Route Tables` > `Create route table`.
   - Set `Name tag` to `Public-Route-Table`.
   - Select `Custom-VPC`.
   - Click `Create`.
2. **Edit Routes**:
   - Select the created route table.
   - Click `Routes` > `Edit routes`.
   - Click `Add route`.
   - Enter `0.0.0.0/0` for Destination, select the Internet Gateway for Target.
   - Click `Save changes`.
3. **Associate Subnets**:
   - Click `Subnet Associations` > `Edit subnet associations`.
   - Select all three public subnets.
   - Click `Save`.

## STEP 5 - Create a Security Group

1. **Create Security Group**:
   - Navigate to the EC2 Dashboard.
   - Click `Security Groups` > `Create security group`.
   - Set `Security group name`, e.g., `WebApp-SG`.
   - Set `Description`.
   - Select `Custom-VPC`.
   - Add Inbound rules:
     - Type: `SSH`, Protocol: `TCP`, Port: `22`, Source: `0.0.0.0/0`
     - Type: `HTTP`, Protocol: `TCP`, Port: `80`, Source: `0.0.0.0/0`
   - Click `Create`.

## STEP 6 - Create a Launch Template

1. **Create Launch Template**:
   - Navigate to `Launch Templates` > `Create launch template`.
   - Set `Launch template name`, e.g., `MyWebApp-LT`.
   - Select `Amazon Linux 2 AMI`.
   - Instance type: `t2.micro`.
   - Under Network settings, select `WebApp-SG`.
   - Click `Create launch template`.

## STEP 7 - Create a Target Group

1. **Create Target Group**:
   - Navigate to `EC2` > `Load Balancing` > `Target Groups`.
   - Click `Create target group`.
   - Select `Instances` for Target type.
   - Set `Name`, e.g., `MyWebApp-TG`.
   - Protocol: `HTTP`, Port: `80`.
   - VPC: `Custom-VPC`.
   - Register targets later.
   - Click `Create`.

## STEP 8 - Create a Load Balancer

1. **Create Load Balancer**:
   - Click `Load Balancers` > `Create Load Balancer`.
   - Choose `Application Load Balancer`.
   - Set `Name`, e.g., `MyWebApp-LB`.
   - Scheme: `internet-facing`.
   - Add listeners for HTTP on port 80.
   - Select the three public subnets.
   - Click `Create`.

## STEP 9 - Set Up Auto Scaling Group

1. **Create Auto Scaling Group**:
   - Navigate to `Auto Scaling` > `Auto Scaling Groups`.
   - Click `Create Auto Scaling Group`.
   - Name it, e.g., `MyWebApp-ASG`.
   - Select the launch template `MyWebApp-LT`.
   - Set instance purchase options and advanced configurations.
   - Set VPC and subnet details.
   - Set scaling policies: Desired: 2, Min: 1, Max: 4.
   - Click `Create Auto Scaling Group`.

# Deletion Steps

To delete the setup without errors, follow these steps in reverse order, ensuring that dependencies are removed before the resources relying on them:

1. **Delete Auto Scaling Group**: Ensure all instances are terminated.
2. **Delete Load Balancer**: Wait for deregistration of instances.
3. **Delete Target Group**: Ensure it's not associated with any services.
4. **Delete Launch Template**: Make sure no dependencies.
5. **Delete Security Group**: Ensure no dependencies.
6. **Unassociate and Delete Route Table**: Remove associations with subnets first.
7. **Detach and Delete Internet Gateway**: Detach from VPC first.
8. **Delete Subnets**: Ensure no resources are using them.
9. **Delete VPC**: Ensure all sub-resources are deleted.

##end##