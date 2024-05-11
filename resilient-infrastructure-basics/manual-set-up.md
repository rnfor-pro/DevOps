# AWS Environment Setup Guide for Beginners

This guide provides detailed instructions for setting up a scalable and accessible web application infrastructure on AWS.

## Prerequisites
- AWS Account
- Basic understanding of AWS services

## STEP 1 - Create a Custom VPC

1. **Navigate to VPC Dashboard**: Open the VPC console at https://console.aws.amazon.com/vpc/.
2. **Create VPC**:
   - Click `Create VPC`.
   - Select `VPC and more`.
   - Set `Name tag auto-generation` to `Custom`.
   - Under `IPv4 CIDR block`, enter, `10.0.0.0/16`.
   - Under `IPv6 CIDR block` check the `No IPv6 CIDR block`
   - Click the dropdown arrow Under `Tenancy` check  `Default`
   - Under `Number of Availability Zones (AZs)` select `3`

## STEP 2 - Create Subnets

1. **Create three public subnets**:
   #- For each subnet (in `us-east-1a`, `us-east-1b`, `us-east-1c`):

   - Under `Number of public subnets` select `3`
   - Under `Number of private subnets` select `0`
   - Click the dropdown arrow under `Customize subnets CIDR blocks`.
   - Under `Public subnet CIDR block in us-east-1a` enter `10.0.1.0/24`
   - Under `Public subnet CIDR block in us-east-1b` enter `10.0.2.0/24`
   - Under `Public subnet CIDR block in us-east-1c` enter `10.0.3.0/24`
   - Under `NAT gateways ($)` select `None`
   - Under `VPC endpoints` select `None`
   - Check boxes under  `DNS options`
   - Click `Create VPC`.
   - Click `View VPC`.
   - Select `Custom-VPC` locate anc click on `Resource map`
   We have our VPC and 3 subnets in 3 different availabilty zones.
   We also have a out table created and an internet gateway.

   - Select `Sunets` locate select the created subnets e.g `Custom-subnet-public2-us-east-1b` click on the dropdown arrow on `Actions` select  `Edit subnet settings` check `Enable auto-assign public IPv4 address` click `Save`
   Repeat this action for the remaining subnets.




   

   

<!-- ## STEP 3 - Set Up an Internet Gateway

1. **Create Internet Gateway**:
   - Click `Internet Gateways` > `Create internet gateway`.
   - Set `Name tag` to `Custom-IGW`.
   - Click `Create`.
2. **Attach to VPC**:
   - Select the created IGW.
   - Click `Actions` > `Attach to VPC`.
   - Select `Custom-VPC`.
   - Click `Attach`. -->

## STEP 4 - Configure Route Tables

1. **Create Route Table**:
   <!-- - Click `Route Tables` > `Create route table`.
   - Set `Name tag` to `Public-Route-Table`.
   - Select `Custom-VPC`.
   - Click `Create`.
2. **Edit Routes**:
   <!-- - Select the created route table.
   - Click `Routes` > `Edit routes`.
   - Click `Add route`.
   - Enter `0.0.0.0/0` for Destination, select the Internet Gateway for Target.
   - Click `Save changes`. --> 
3. **Associate Subnets**:
   <!-- - Click `Subnet Associations` > `Edit subnet associations`.
   - Select all three public subnets.
   - Click `Save`. -->

## STEP 5 - Create a Security Group

1. **Create Security Group**:
   - Navigate to the EC2 Dashboard.
   - Click `Security Groups` under `Network & Security` then `Create security group`.
   - Under `Basic details`
   - Set `Security group name`, e.g., `Custom-SG`.
   - Set `Description` to  `Custom-SG`.
   - Under `VPC` select `Custom-VPC`.
   - Under `inbound rules`, 
     - Click on `Add rule`, then Click on the drop down arrow under `Inbound rules ` > `Type` select `SSH` under `Source` click in the search window and enter `0.0.0.0/0`,
     - Click on `Add rule`, Click on the drop down arrow under `Inbound rules` > `Type` select `HTTP` under `Source` click in the search window and enter `0.0.0.0/0`,
     - Add a tag Key = Name, Value = Custom-SG
     - Scroll all the way down and click on `Create security group`



## STEP 6 - Create a Launch Template

1. **Create Launch Template**:
   - Navigate to `Launch Templates` > `Create launch template`.
   - Set `Launch template name`, e.g., `Custom-LT`.
   - Check the box under `Auto Scaling guidance`
   - Under `Application and OS Images (Amazon Machine Image) - required ` select `Quick start`.
   - Select `Amazon Linux ` AMI , under `Amazon Machine Image (AMI)` select `Amazon Linux 2023 AMI`
   - Under `Instance type` select `t2.micro`.
   - Under Network settings, select `Select existing security group` under `Security groups` click on the drop down arrow and select  `Custom-SG`.
   - Under `Advanced network configuration` select `Add network interface`.
   - On the second row locate `Auto-assign public IP` click on the drop down arrow and select  `Enable`.
   - Scroll all the way down and click on the drop down arrow on `Advanced details`
   - Scroll all the way down and in the box under `User data` eneter the below script.

## Userdata

## Amazon Linux
   <!-- ```bash

      #!/bin/bash

      sudo yum update -y
      sudo yum install -y httpd.x86_64
      sudo systemctl start httpd.service
      sudo systemctl enable httpd.service
      sudo echo "Hello team910 from $(hostname -f)" >> /var/www/html/index.html

   ``` -->


   ## Ubuntu

   ```bash
   #!/bin/bash

      sudo apt update -y
      sudo apt install apache2 -y

   ```

   - Click `Create launch template`.


## STEP 7 - Create a Target Group

1. **Create Target Group**:
   - Navigate to `EC2` > `Load Balancing` > `Target Groups`.
   - Click `Create target group`.
   - Select `Instances` under Choose Target type.
   - Set `Name`, e.g., `Custom-TG`.
   - Protocol: Port: `HTTP`,  `80`
   - IP address type `IPv4`
   - VPC: `Custom-VPC`.
   - `Protocol version` > `HTTP1`
   - `Next`
   - Register targets later.
   - Click `Create target group`.

## STEP 8 - Create a Load Balancer

1. **Create Load Balancer**:
   - Click `Load Balancers` > `Create Load Balancer`.
   - Under `Load balancer types` click on `Create`
   - Choose `Application Load Balancer`.
   - Set `Name`, e.g., `MyWebApp-LB`.
   - Scheme: `internet-facing`.
   - Click on the drop down under `Network mapping` select our `Custom VPC`
   - Under `Mappings` 
   - Under `Security groups` click on the drop down arrow and select the security group we created and uncheck `default`.
   - Under `Listeners and routing` locate `Default action`, click on the drop down arrow and select `the custom-sg` we created. 
   # - Add listeners for HTTP on port 80.
   # - Select the three public subnets.
   - Click `Create load balancer`.

## STEP 9 - Set Up Auto Scaling Group

1. **Create Auto Scaling Group**:
   - Navigate to `Auto Scaling` > `Auto Scaling Groups`.
   - Click `Create Auto Scaling Group`.
   - Name it, e.g., `Custom-ASG`.
   - Under `Launch template ` click on the drop down arrow 
   - Select the launch template `Custom-LT`.
   - Under `Version` selct `Default(1)`
   - `Next`
   - Under `Network ` select the VPC we created.
   - Under `Availability Zones and subnets` select the 3 we set up
   - `Next`
   - Under `Load balancing ` select `Attach existing load balancer`
   - Under `Attach to an existing load balancer` select `Choose from your load balancer target group`
   - Click on the drop down arrow under `Existing load balancer target groups` and select your custom target group.
   - Under `VPC Lattice integration options` select `No VPC Lattice service`
   - Under `Health checks` check the box under `Turn on Elastic Load Balancing health checks`
   - `Next`
   - Under `Group size` set `Desired capacity` to 2, `Min desired capacity` 1, and `Max desired capacity` to 4
   - `Next`
   - `Next`
   - Add Tags: Key = Name, Value = `My WebApp`
   - `Next`
   - `Create Auto Scaling Group`


   - Click `Create Auto Scaling Group`.

# Deletion Steps

To delete the setup without errors, follow these steps in reverse order, ensuring that dependencies are removed before the resources relying on them:

1. **Delete Auto Scaling Group**: Ensure all instances are terminated.
2. **Delete Load Balancer**: Wait for deregistration of instances.
3. **Delete Target Group**: Ensure it's not associated with any services.
4. **Delete Launch Template**: Make sure no dependencies.
9. **Delete VPC**: Ensure all sub-resources are deleted.
