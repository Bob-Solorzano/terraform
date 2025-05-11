# Create Subnet for AZ 1b - Public for Load Balancing.
resource "aws_subnet" "tf_public_subnet_1b" {
  vpc_id                  = aws_vpc.tf_vpc.id
  cidr_block              = "10.10.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags = {
    Name = "dev-public-1b"
  }
}

# add Route table to subnet in AZ 1b.
resource "aws_route_table_association" "a_1b" {
  subnet_id      = aws_subnet.tf_public_subnet_1b.id
  route_table_id = aws_route_table.tf_public_rt.id
}

# Second Amazon EC2 for Load Balance across AZ's
resource "aws_instance" "tf_amazon_ec2_1b" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.tf_ami.id
  key_name               = aws_key_pair.tf_keypair.key_name
  vpc_security_group_ids = [aws_security_group.tf_sec_grp.id]
  subnet_id              = aws_subnet.tf_public_subnet_1b.id
  user_data              = file("userdata_amz.tpl")

  tags = {
    Name = "dev_amazon_ec2_1b"
  }
}

# Security Group for Load Balancer
resource "aws_security_group" "tf_lb_sec_grp" {
  name        = "dev_lb_sec_grp"
  description = "development Load Balancer security group"
  vpc_id      = aws_vpc.tf_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "tf_lb_sg_ingress" {
  security_group_id = aws_security_group.tf_lb_sec_grp.id
  cidr_ipv4         = "0.0.0.0/0" #Add specific IPs for security.  xxx.xxx.xxx.xxx/32
  from_port         = 80
  to_port           = 80
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "tf_lb_sg_egress" {
  security_group_id = aws_security_group.tf_lb_sec_grp.id

  cidr_ipv4 = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}


resource "aws_lb_target_group" "amz_target_grp"{
  name = "amz-target-grp"
  port = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id = aws_vpc.tf_vpc.id
}

resource "aws_lb_target_group_attachment" "amz_target_grp_att"{
  target_group_arn = aws_lb_target_group.amz_target_grp.arn
  target_id = aws_instance.tf_amazon_ec2.id
  port = 80
}

resource "aws_lb_target_group_attachment" "amz_target_grp_att_1b"{
  target_group_arn = aws_lb_target_group.amz_target_grp.arn
  target_id = aws_instance.tf_amazon_ec2_1b.id
  port = 80
}

#Amz Load Balancer
resource "aws_lb" "amz_lb"{
  name = "amz-lb"
  internal = false
  ip_address_type = "ipv4"
  load_balancer_type = "application"
  security_groups = [aws_security_group.tf_lb_sec_grp.id]
  subnets = [aws_subnet.tf_public_subnet.id,aws_subnet.tf_public_subnet_1b.id]
}


# Amz Load Balancer Listener.
resource "aws_lb_listener" "lb_lsnr" {
  load_balancer_arn = aws_lb.amz_lb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.amz_target_grp.arn
  }
}