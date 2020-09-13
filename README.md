# Setup Jenkins server on a new EC2 instance with Terraform

![Setup Jenkins server on a new EC2 instance with Terraform](https://camo.githubusercontent.com/e00ce6c84ed1a2715af9c72c77a94cbcf9a40ab8/68747470733a2f2f62732d75706c6f6164732e746f7074616c2e696f2f626c61636b666973682d75706c6f6164732f626c6f672f61727469636c652f636f6e74656e742f636f7665725f696d6167655f66696c652f636f7665725f696d6167652f31393933322f636f7665722d303232362d5465727261666f726d4a656e6b696e73434943442d57616c64656b5f4e6577736c65747465722d37653437323665353434666463343266626137363835663666363134393238362e706e67)

## Intro
Terraform is great tool to quickly setup your server/infrastructure on any cloud services: AWS, Azure, Google Cloud,... This is a small example using Terraform to setup a Jenkins server on AWS EC2 asap.

This setup follows official document from AWS, please take a look to have understanding what this setup does:

https://d1.awsstatic.com/Projects/P5505030/aws-project_Jenkins-build-server.pdf

## Prerequiresites:
- Be sure that Terraform was installed on your machine: https://www.terraform.io/downloads.html
- You already have an AWS account, an AWS Identity and Access Management (IAM) user name and password
- Create an EC2 key pair: 
Go to your AWS EC2 console and click Key Pairs on the left sidebar. Let name it `terraform_key`.
Store it in secret location that no one knows except you.

## 1. Plan and Apply

### AWS Authentication:
Provide AWS credentials via `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
```
$ export AWS_ACCESS_KEY_ID="anaccesskey"
$ export AWS_SECRET_ACCESS_KEY="asecretkey"
$ terraform plan
```

### This provision will:

1. Create vpc
2. Create internet gateway
3. Create custom Route Table
4. Create a Subnet
5. Associate subnet with Route Table
6. Create a Security Group to allow port 80, 22, 443, 8080
7. Create a Network Interface with an IP in the Subnet that was created in step 4
8. Assign an elastic IP to Network Inteface created in step 7
9. Create an EC2 instance and install/enable Jenkins

### Apply provision:

```
terraform apply
```

## 2. Config Jenkins
- Open Jenkins on browser: your_instance_public_ip:8080
- SSH to your instance: `ssh -i "terraform_key.pem" ec2-user@your_instance_public_ip`
- Copy initial password and continue: `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`

## 3. Clean up
After completing this example, be sure to delete the AWS resources that you created so that you do not continue to accrue charges.
```
terraform destroy
```
