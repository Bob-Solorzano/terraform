# terraform
Terraform AWS project

This is a current setup of my AWS environment as configured through Terraform. 
This has EC2 instances and S3 buckets created for various projects. 
Configuration for VPC, Subnets, Routing Tables, and Internet gateway are also configured here. 

main.tf - Contains the base code for driving the creation of the environment.  
    This includes VPC, Subnet (Public), Internet Gateway, Route Table, Route Table Association, ingress and egress rules, 
    EC2 Instances, 1-Amazon Linux, 1-ubuntu Linux for Docker configuration. 
    S3 buckets, 1-Raw data bucket, 1-cleansed data bucket, 1-web accessible bucket. 
    s3 website configuration, 
    s3 bucket policy configuration, 
    key pair association.

IoT_AWS.tf - Manage AWS environment to:
    Define IoT thing along with associated Policies and Certificates. 
    Define DynamoDB table for IoT data. 
    Define necessary Roles and Policies. 

load_balance.tf - This tf includes the components for additional AZ Subnets, additional Amazon Linux instances and the supporting components for the        Application Load Balancer. 
    A subnet was created to support additional Availability Zone(AZ), US_EAST_1B   
    An additional Amazon Linux system was created to match as the existing instance in main.tf, but created in the US_EAST_1B AZ
    amz_userdata.tpl was added at this time to have the Amazon instances created with web services that return the hostname when referenced.
    A target group was defined to include the two Amazon Linux instances. 
    A new security group was defined for the load balancer to allow port 80 for incoming and outgoing traffic. 
    The Load Balancer was defined to include the two subnets (one for each AZ), the new target group and a newly defined listener.
    
datasource.tf - Contains the gathering of the AMI details for the EC2 instances. 

userdata.tpl - Contains bash script to configure the Unbuntu ec2 for docker.  
    The Bash script installs the required software for docker. 

userdata_amz.tpl - Contains a bash script to install a webservice that returns the hostname of the Linux system. 

bat_timestamp.txt - Text file holding a timestamp variable used to be referenced from the tf files. 
    THis allows Terraform to pass a variable string within the code without evaluating it. 

sample-time.txt - Text file holding a timestamp variable used to be referenced from the tf files. 
    THis allows Terraform to pass a variable string within the code without evaluating it. 

output.tf - Contains the following output:
    Arn and name information for the S3 buckets
    Web domain name for the s3 bucket where configured.  
    Arn, Name, Private IPs and Public IPs for EC2 instances. 


