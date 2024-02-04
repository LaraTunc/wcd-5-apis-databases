terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.31.0"
    }
  }
}

variable "AWS_REGION" {}
variable "AWS_PROFILE" {}
variable "KEY_PAIR_NAME" {}
provider "aws" {
    region = var.AWS_REGION 
    profile =  var.AWS_PROFILE 
}

# Create an AWS VPC. 
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/24"

   tags = {
    Name = "eval-5-vpc",
  }
}

# Create an internet gateway and associate it to the VPC.
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "eval-5-igw",
  }
}

# Create one private subnet and one public subnet in the VPC.
resource "aws_subnet" "private-subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.0.0/26"
  
  tags = {
    Name = "eval-5-private-subnet",
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.0.64/26"
  
  tags = {
    Name = "eval-5-public-subnet",
  }
}

# Create a public route table routing 0.0.0.0/0 to the internet gateway.
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "eval-5-public-subnet",
  }
}

# Associate the public subnet to the public route table. 
resource "aws_route_table_association" "public-subnet-association" {
  subnet_id = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-route-table.id
}

# Create Elastic IP
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

# Create NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public-subnet.id
}

# Create Route Table for private subnet which routes all traffic to the NAT Gateway
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "Private Route Table"
  }
}

# Associate Route Table with Private Subnet
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

# Create security groups for the subnets.
# Public subnet security group allows incoming traffic on port 80 and 443 from 0.0.0.0/0 (public internet). 
resource "aws_security_group" "public-subnet-sg" {
  name = "eval-5-public-subnet-sg"
  description = "Allow all incoming traffic from on port 80 and 443 from 0.0.0.0/0 (public internet)"
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "ssh"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http from public internet"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "https from public internet"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }

  tags = {
    Name = "eval-5-public-subnet-sg",
  }
}

# Private subnet security group allows all incoming traffic from the public subnet security group. 
resource "aws_security_group" "private-subnet-sg" {
  name = "eval-5-private-subnet-sg"
  description = "Allow all incoming traffic from public subnet security group"
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "Allow all incoming traffic from public subnet security group"
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = [aws_security_group.public-subnet-sg.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }

  tags = {
    Name = "eval-5-private-subnet-sg",
  }
}

# Create s3 to put the csv file
resource "aws_s3_bucket" "lara-2023-02-03-bucket" {
  bucket = "lara-2023-02-03-bucket"  

  tags = {
    Name = "lara-2023-02-03-bucket"
  }     
}

resource "aws_s3_object" "nhl_stats_csv" {
  bucket = aws_s3_bucket.lara-2023-02-03-bucket.id
  key    = "nhl-stats.csv"
  source = "./data/nhl-stats.csv"
}

# Create IAM role for the EC2 instance 
resource "aws_iam_role" "s3_read_role" {
  name = "s3_read_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Create IAM policy for the EC2 instance
resource "aws_iam_policy" "s3_read_policy" {
  name        = "s3-read-policy"  
  description = "Allows read access to S3 bucket"
  policy      = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Action    = [
          "s3:GetObject", 
          "s3:List*"
        ],
        Resource  = "arn:aws:s3:::lara-2023-02-03-bucket/*"  
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "s3_read_attachment" {
  role       = aws_iam_role.s3_read_role.name
  policy_arn = aws_iam_policy.s3_read_policy.arn
}

# Attach role to an instance profile 
resource "aws_iam_instance_profile" "s3_read_instance_profile" {
  name = "s3_read_instance_profile"
  role = aws_iam_role.s3_read_role.name
}

# Database server - MySql
resource "aws_instance" "database" {
  ami = "ami-0fc5d935ebf8bc3bc"
  instance_type = "t2.small"
  key_name = var.KEY_PAIR_NAME
  vpc_security_group_ids = [aws_security_group.private-subnet-sg.id]
  subnet_id = aws_subnet.private-subnet.id
  associate_public_ip_address = false
  iam_instance_profile = aws_iam_instance_profile.s3_read_instance_profile.name
  user_data = file("./user_data/mysql.sh")

  tags = {
    Name = "database",
  }
}

# API server - FastAPI 
resource "aws_instance" "api" {
  ami = "ami-0fc5d935ebf8bc3bc"
  instance_type = "t2.small"
  key_name = var.KEY_PAIR_NAME
  vpc_security_group_ids = [aws_security_group.public-subnet-sg.id]
  subnet_id = aws_subnet.public-subnet.id
  associate_public_ip_address = true
  user_data = templatefile("./user_data/api.sh", { db_private_ip = aws_instance.database.private_ip })

  tags = {
    Name = "api",
  }
}
