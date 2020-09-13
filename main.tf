# Configure the AWS provider
provider "aws" {
  version = "~> 3.0"
  region  = "ap-southeast-1"
}

# resource "aws_vpc" "first-vpc" {
#   cidr_block = "10.0.0.0/16"

#   tags = {
#     Name = "production"
#   }
# }

# resource "aws_subnet" "subnet-1" {
#   vpc_id     = aws_vpc.first-vpc.id
#   cidr_block = "10.0.1.0/24"

#   tags = {
#     Name = "prod-subnet"
#   }
# }

# 1. Create vpc
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

# 2. Create internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

# 3. Create custom Route Table
resource "aws_route_table" "r" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  # route {
  #   ipv6_cidr_block        = "::/0"
  #   egress_only_gateway_id = aws_internet_gateway.gw.id
  # }

  tags = {
    Name = "main"
  }
}

# 4. Create a Subnet
resource "aws_subnet" "subnet-1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-southeast-1a"

  tags = {
    Name = "Prod subnet"
  }
}

# 5. Associate subnet with Route Table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.r.id
}

# 6. Create a Security Group to allow port 80, 22, 443, 8080
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

# 7. Create a Network Interface with an IP in the Subnet that was created in step 4
resource "aws_network_interface" "test" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]

  # attachment {
  #   instance     = aws_instance.test.id
  #   device_index = 1
  # }
}

# 8. Assign an elastic IP to Network Inteface created in step 7
resource "aws_eip" "lb" {
  # instance                  = aws_instance.web.id
  vpc                       = true
  network_interface         = aws_network_interface.test.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.gw]
}

# 9. Create an EC2 instance and install/enable Jenkins
resource "aws_instance" "jenkins-server-instance" {
  ami               = "ami-0b1e534a4ff9019e0"
  instance_type     = "t2.micro"
  availability_zone = "ap-southeast-1a"
  key_name          = "terraform_key"
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.test.id
  }

  user_data = <<-EOF
              #!/bin/bash
              # NOTE: If you change AMI to an image included Java, so no need to install Java.
              sudo yum install java-1.8.0-openjdk -y
              sudo yum update -y
              sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo
              sudo rpm --import http://pkg.jenkins-ci.org/redhat-stable/jenkins-ci.org.key
              sudo yum install jenkins -y
              sudo yum install git -y
              sudo service jenkins start
              EOF

  tags = {
    Name = "Jenkins web server"
  }
}

output "server_public_ip" {
  value = aws_eip.lb.public_ip
}
