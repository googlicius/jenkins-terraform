# Setup Jenkins server on a new EC2 instance with Terraform.

## Intro
Terraform is great tool to quickly setup your server/infrastructure on any cloud services: AWS, Azure, Google Cloud,... This is a small example using Terraform to setup a Jenkins server on AWS EC2 asap.

## 1. Installation
Provide AWS credentials via `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`:
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

### Apply provision:

```
terraform apply
```

## 2. Config Jenkins

- Open Jenkins on browser: instance_public_ip:8080
- Copy initial password and continue: `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`

## 3. Clean up
After completing this example, be sure to delete the AWS resources that you created so that you do not continue to accrue charges.
```
terraform destroy
```