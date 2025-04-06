terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Block for AWS Provider.
provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "tf_vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "aws_tf_vpc"
  }
}

# Create Subnet - Public
resource "aws_subnet" "tf_public_subnet" {
  vpc_id                  = aws_vpc.tf_vpc.id
  cidr_block              = "10.10.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "dev-public"
  }
}

resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.tf_vpc.id

  tags = {
    Name = "dev_internet_gw"
  }
}

resource "aws_route_table" "tf_public_rt" {
  vpc_id = aws_vpc.tf_vpc.id

  tags = {
    Name = "dev_public_rt"
  }
}

resource "aws_route" "tf_route" {
  route_table_id         = aws_route_table.tf_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gw.id
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.tf_public_subnet.id
  route_table_id = aws_route_table.tf_public_rt.id
}

resource "aws_security_group" "tf_sec_grp" {
  name        = "dev_sec_grp"
  description = "development security group"
  vpc_id      = aws_vpc.tf_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "tf_sg_ingress" {
  security_group_id = aws_security_group.tf_sec_grp.id
  cidr_ipv4         = "0.0.0.0/0" #Add specific IPs for security.  xxx.xxx.xxx.xxx/32
  #  from_port         = 0
  ip_protocol = "-1"
  #  to_port           = 0
}
resource "aws_vpc_security_group_egress_rule" "tf_sg_egress" {
  security_group_id = aws_security_group.tf_sec_grp.id

  cidr_ipv4 = "0.0.0.0/0"
  #  from_port   = 0
  #  to_port     = 0
  ip_protocol = "-1"
}

resource "aws_instance" "tf_amazon_ec2" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.tf_ami.id
  key_name               = aws_key_pair.tf_keypair.key_name
  vpc_security_group_ids = [aws_security_group.tf_sec_grp.id]
  subnet_id              = aws_subnet.tf_public_subnet.id

  tags = {
    Name = "dev_amazon_ec2"
  }
}

resource "aws_instance" "tf_ubuntu_ec2" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.tf_ubuntu_ami.id
  key_name               = aws_key_pair.tf_keypair.key_name
  vpc_security_group_ids = [aws_security_group.tf_sec_grp.id]
  subnet_id              = aws_subnet.tf_public_subnet.id
  user_data = file("userdata.tpl")

  tags = {
    Name = "dev_ubuntu_ec2"
  }
}


resource "aws_s3_bucket" "tf_s3_bucket_raw" {
  bucket = "tf-rawbucket4bob"

  force_destroy = true

  tags = {
    Name        = "tf Raw Data S3 Bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket" "tf_s3_bucket_game" {
  bucket = "tf-gamebucket4bob"

  force_destroy = true

  tags = {
    Name        = "tf Game Data S3 Bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_raw_block_public" {
  bucket = aws_s3_bucket.tf_s3_bucket_game.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.tf_s3_bucket_game.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_policy" "game_policy" {
  bucket        = aws_s3_bucket.tf_s3_bucket_game.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject"
        ]
        Principal = "*"
        Effect   = "Allow"
        Resource = ["arn:aws:s3:::tf-gamebucket4bob/*"]
      }
    ]
  })
}

resource "aws_s3_bucket" "tf_s3_bucket_clean" {
  bucket = "tf-cleanbucket4bob"

  force_destroy = true

  tags = {
    Name        = "tf Clean Data S3 Bucket"
    Environment = "Dev"
  }
}

resource "aws_key_pair" "tf_keypair" {
  key_name   = "tf_key"
  public_key = file("~/.ssh/tf_key.pub")
}