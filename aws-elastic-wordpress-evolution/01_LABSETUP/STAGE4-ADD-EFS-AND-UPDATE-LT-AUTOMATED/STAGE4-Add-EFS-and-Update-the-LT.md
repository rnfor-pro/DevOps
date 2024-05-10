# Advanced Demo - Web App - Single Server to Elastic Evolution

![Stage4 - PNG](https://github.com/acantril/learn-cantrill-io-labs/blob/master/aws-elastic-wordpress-evolution/02_LABINSTRUCTIONS/STAGE4%20-%20SPLIT%20OUT%20EFS.png)

Welcome back, in stage 4 of this demo series you will be creating an EFS file system designed to store the wordpress locally stored media. This area stores any media for posts uploaded when creating the post as well as theme data.  By storing this on a shared file system it means that the data can be used across all instances in a consistent way, and it lives on past the lifetime of the instance.  

# STAGE 4A - Create EFS File System

## File System Settings

Alreay done using terraform
---

## Network Settings
Alreay done using terraform

Note down the `fs-XXXXXXXX ` or `DNS name ` (either will work) once visible at the top of this screen, you will need it in the next step.  
---


# STAGE 4B - Add an fsid to parameter store

Now that the file system has been created, you need to add another parameter store value for the file system ID so that the automatically built instance(s) can load this safely.

Go back to your terraform code, locate the `ssm parameters block and add the code block below `

```bash
resource "aws_ssm_parameter" "file_system_id" {
  name        = "/A4L/Wordpress/EFSFSID"
  description = "Wordpress DBRoot Password"
  type        = "SecureString"
  value       = "fs-XXXXXXX"
  key_id      = "alias/aws/ssm"  
}
```
for Value set the file system ID fs-XXXXXXX which you just noted down (use your own file system ID)

#############

# STAGE 3C - Migrate WordPress data from MariaDB to RDS

Open the EC2 Console https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Home:  
Click `Instances`  
Locate the `WordPress-LT` instance, right click, `Connect` and choose `Session Manager` and then click `Connect`  
Type `sudo bash`  
Type `cd`  
Type `clear`  

## Populate Environment Variables

You're going to do an export of the SQL database running on the local ec2 instance

First run these commands to populate variables with the data from Parameter store, it avoids having to keep locating passwords  
```
DBPassword=$(aws ssm get-parameters --region us-east-1 --names /A4L/Wordpress/DBPassword --with-decryption --query Parameters[0].Value)
DBPassword=`echo $DBPassword | sed -e 's/^"//' -e 's/"$//'`

DBRootPassword=$(aws ssm get-parameters --region us-east-1 --names /A4L/Wordpress/DBRootPassword --with-decryption --query Parameters[0].Value)
DBRootPassword=`echo $DBRootPassword | sed -e 's/^"//' -e 's/"$//'`

DBUser=$(aws ssm get-parameters --region us-east-1 --names /A4L/Wordpress/DBUser --query Parameters[0].Value)
DBUser=`echo $DBUser | sed -e 's/^"//' -e 's/"$//'`

DBName=$(aws ssm get-parameters --region us-east-1 --names /A4L/Wordpress/DBName --query Parameters[0].Value)
DBName=`echo $DBName | sed -e 's/^"//' -e 's/"$//'`

DBEndpoint=$(aws ssm get-parameters --region us-east-1 --names /A4L/Wordpress/DBEndpoint --query Parameters[0].Value)
DBEndpoint=`echo $DBEndpoint | sed -e 's/^"//' -e 's/"$//'`

```

## Take a Backup of the local DB

To take a backup of the database run

```
mysqldump -h $DBEndpoint -u $DBUser -p$DBPassword $DBName > a4lWordPress.sql
```
** in production you wouldnt put the password in the CLI like this, its a security risk since a ps -aux can see it .. but security isnt the focus of this demo its the process of rearchitecting **

## Restore that Backup into RDS

Move to the RDS Console https://console.aws.amazon.com/rds/home?region=us-east-1#databases:  
Click the `a4lWordPressdb` instance  
Copy the `endpoint` into your clipboard  
Move to the Parameter store https://console.aws.amazon.com/systems-manager/parameters?region=us-east-1  
Check the box next to `/A4L/Wordpress/DBEndpoint` and click `Delete` (please do delete this, not just edit the existing one)  
Click `Create Parameter`  

<!-- Under `Name` enter `/A4L/Wordpress/DBEndpoint`  
Under `Descripton` enter `WordPress DB Endpoint Name`  
Under `Tier` select `Standard`    
Under `Type` select `String`  
Under `Data Type` select `text`  
Under `Value` enter the RDS endpoint endpoint you just copied  
Click `Create Parameter`   -->

Go back to your terraform code, locate the `ssm parameters block and add the code block below `

```hcl
resource "aws_ssm_parameter" "db_endpoint" {
  name        = "/A4L/Wordpress/DBEndpoint"
  description = "Wordpress Endpoint Name"
  type        = "String"
  value       = "a4lwordpress.cdiaord7vlsf.us-east-1.rds.amazonaws.com" 
}
```


Run 
```hcl
terraform apply -auto-approve
```

Go back to `EC2 Console`
Update the DbEndpoint environment variable with 

```
DBEndpoint=$(aws ssm get-parameters --region us-east-1 --names /A4L/Wordpress/DBEndpoint --query Parameters[0].Value)
DBEndpoint=`echo $DBEndpoint | sed -e 's/^"//' -e 's/"$//'`
```

Restore the database export into RDS using

```
mysql -h $DBEndpoint -u $DBUser -p$DBPassword $DBName < a4lWordPress.sql 
```

## Change the WordPress config file to use RDS

this command will substitute `localhost` in the config file for the contents of `$DBEndpoint` which is the RDS instance

```
sudo sed -i "s/'localhost'/'$DBEndpoint'/g" /var/www/html/wp-config.php
```


# STAGE 3D - Stop the MariaDB Service

```
sudo systemctl disable mariadb
sudo systemctl stop mariadb
```


# STAGE 3E - Test WordPress

Move to the EC2 Console https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Instances:sort=desc:tag:Name  
Select the `WordPress-LT` Instance  
copy the `IPv4 Public IP` into your clipboard  
Open the IP in a new tab  
You should see the blog, working, even though MariaDB on the EC2 instance is stopped and disabled
Its now running using RDS  

############


# STAGE 4C - Connect the file system to the EC2 instance & copy data

Open the EC2 console and go to running instances https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Instances:sort=desc:tag:Name  
Select the `Wordpress-LT` instance, right click, `Connect`, Select `Session Manager` and click `Connect`  
type `sudo bash` and press enter   
type `cd` and press enter  
type `clear` and press enter  

First we need to install the amazon EFS utilities to allow the instance to connect to EFS. EFS is based on NFS which is standard but the EFS tooling makes things easier.  

```
sudo dnf -y install amazon-efs-utils
```

next you need to migrate the existing media content from wp-content into EFS, and this is a multi step process.

First, copy the content to a temporary location and make a new empty folder.

```
cd /var/www/html
sudo mv wp-content/ /tmp
sudo mkdir wp-content
```

then get the efs file system ID from parameter store

```
EFSFSID=$(aws ssm get-parameters --region us-east-1 --names /A4L/Wordpress/EFSFSID --query Parameters[0].Value)
EFSFSID=`echo $EFSFSID | sed -e 's/^"//' -e 's/"$//'`
```

Next .. add a line to /etc/fstab to configure the EFS file system to mount as /var/www/html/wp-content/

```
echo -e "$EFSFSID:/ /var/www/html/wp-content efs _netdev,tls,iam 0 0" >> /etc/fstab
```

```
mount -a -t efs defaults
```

now we need to copy the origin content data back in and fix permissions

```
mv /tmp/wp-content/* /var/www/html/wp-content/
```

```
chown -R ec2-user:apache /var/www/

```

# STAGE 4D - Test that the wordpress app can load the media

run the following command to reboot the EC2 wordpress instance
```
reboot
```

Once it restarts, ensure that you can still load the wordpress blog which is now loading the media from EFS.  

# STAGE 4E - Update the launch template with the config to automate the EFS part

Next you will update the launch template so that it automatically mounts the EFS file system during its provisioning process. This means that in the next stage, when you add autoscaling, all instances will have access to the same media store ...allowing the platform to scale.

Go to the EC2 console https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Home:  
Click `Launch Templates`  
Check the box next to the `Wordpress` launch template, click `Actions` and click `Modify Template (Create New Version)`  
for `Template version description` enter `App only, uses EFS filesystem defined in /A4L/Wordpress/EFSFSID`  
Scroll to the bottom and expand `Advanced Details`  
Scroll to the bottom and find `User Data` expand the entry box as much as possible.  

After `#!/bin/bash -xe` position cursor at the end & press enter twice to add new lines
paste in this

```
EFSFSID=$(aws ssm get-parameters --region us-east-1 --names /A4L/Wordpress/EFSFSID --query Parameters[0].Value)
EFSFSID=`echo $EFSFSID | sed -e 's/^"//' -e 's/"$//'`

```

Find the line which says `dnf install wget php-mysqlnd httpd php-fpm php-mysqli mariadb105-server php-json php php-devel stress -y`
after `stress` add a space and paste in `amazon-efs-utils`  
it should now look like `dnf install wget php-mysqlnd httpd php-fpm php-mysqli mariadb105-server php-json php php-devel stress amazon-efs-utils -y`  

## DO NOT DO THIS NEXT STAGE.
locate `systemctl start httpd` position cursor at the end & press enter twice to add new lines  

paste in the following

```
mkdir -p /var/www/html/wp-content
chown -R ec2-user:apache /var/www/
echo -e "$EFSFSID:/ /var/www/html/wp-content efs _netdev,tls,iam 0 0" >> /etc/fstab
mount -a -t efs defaults
```

Scroll down and click `Create template version`  
Click `View Launch Template`  
Select the template again (dont click)
Click `Actions` and select `Set Default Version`  
Under `Template version` select `3`  
Click `Set as default version`  



# STAGE 4 - FINISH  

This configuration has several limitations :-

- ~~The application and database are built manually, taking time and not allowing automation~~ FIXED  
- ~~^^ it was slow and annoying ... that was the intention.~~ FIXED  
- ~~The database and application are on the same instance, neither can scale without the other~~ FIXED  
- ~~The database of the application is on an instance, scaling IN/OUT risks this media~~ FIXED  
- ~~The application media and UI store is local to an instance, scaling IN/OUT risks this media~~ FIXED  

- Customer Connections are to an instance directly ... no health checks/auto healing
- The IP of the instance is hardcoded into the database ....


You can now move onto STAGE 5