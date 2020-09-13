# Setup Jenkins server on a new EC2 instance with Terraform

## Intro
Terraform is great tool to quickly setup your server/infrastructure on any cloud services: AWS, Azure, Google Cloud,... This is a small example using Terraform to setup a Jenkins server on AWS EC2 asap.

This setup is referenced from official document from AWS:
https://d1.awsstatic.com/Projects/P5505030/aws-project_Jenkins-build-server.pdf

## 1. Installation
### Provide AWS credentials via `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`:
```
$ export AWS_ACCESS_KEY_ID="anaccesskey"
$ export AWS_SECRET_ACCESS_KEY="asecretkey"
$ export AWS_DEFAULT_REGION="us-west-2"

terraform plan
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

### Create an EC2 key pair: 
Go to your AWS EC2 console and click Key Pairs on the left sidebar. Let name it `terraform_key` or whatever.
Store it in secret location that no one knows except you.

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