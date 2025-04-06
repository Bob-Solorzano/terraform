# terraform
Terraform AWS project

This is a current setup of my AWS environment as configured through Terraform. 
This has EC2 instances and S3 buckets created for various projects. 

main.tf - contains the base code for driving the creation of the environment.  This includes VPC, Subnet (Public), Internet Gateway, Route Table, Route Table Association, ingress and egress rules, EC2 Instances, S3 buckets, s3 website configuration, s3 bucket policy configuration, and key pair association.

datasource.tf - contains the gathering of the AMI details for the EC2 instances. 

userdata.tpl - contains bash script to configure the Unbuntu ec2 for docker.  This is a work in progress.  Bash script didn't completely install the docker.  I'll revist this at a later time. 

output.tf - contains the output of the arn and name information for the S3 buckets, and web domain name for the bucket so configured.  Arn, Name, Private IPs and Public IPs are presented. 


