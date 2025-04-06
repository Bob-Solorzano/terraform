# Output Variables definitions

output "raw_s3_arn" {
  description = "Arn of the RAW S3 Bucket"
  value = aws_s3_bucket.tf_s3_bucket_raw.arn
}

output "raw_s3_name" {
  description = "Name(id) of the RAW S3 Bucket"
  value = aws_s3_bucket.tf_s3_bucket_raw.id
}

output "clean_s3_arn" {
  description = "Arn of the Clean S3 Bucket"
  value = aws_s3_bucket.tf_s3_bucket_clean.arn
}

output "clean_s3_name" {
  description = "Name(id) of the Clean S3 Bucket"
  value = aws_s3_bucket.tf_s3_bucket_clean.id
}

output "game_s3_arn" {
  description = "Arn of the Game S3 Bucket"
  value = aws_s3_bucket.tf_s3_bucket_game.arn
}

output "game_s3_name" {
  description = "Name(id) of the Game S3 Bucket"
  value       = aws_s3_bucket.tf_s3_bucket_game.id
}

output "game_s3_domain" {
  description = "Domain Name of the Game S3 Bucket"
  value       = aws_s3_bucket.tf_s3_bucket_game.website_domain
}

output "amazon_linux_ec2_arn"{
  description = "ARN of Amazon Linux EC2."
  value = aws_instance.tf_amazon_ec2.arn
}

output "amazon_linux_ec2_name"{
  description = "Name of Amazon Linux EC2."
  value = aws_instance.tf_amazon_ec2.tags.Name
}

output "amazon_linux_ec2_internal_ip"{
  description = "Internal IP of Amazon Linux EC2."
  value = aws_instance.tf_amazon_ec2.private_ip
}

output "amazon_linux_ec2_external_ip"{
  description = "External IP of Amazon Linux EC2."
  value = aws_instance.tf_amazon_ec2.public_ip
}

output "ubuntu_linux_ec2_arn"{
  description = "ARN of Ubuntu Linux EC2."
  value = aws_instance.tf_ubuntu_ec2.arn
}

output "ubuntu_linux_ec2_name"{
  description = "Name of Ubuntu Linux EC2."
  value = aws_instance.tf_ubuntu_ec2.tags.Name
}

output "ubuntu_linux_ec2_internal_ip"{
  description = "Internal IP of Ubuntu Linux EC2."
  value = aws_instance.tf_ubuntu_ec2.private_ip
}

output "ubuntu_linux_ec2_external_ip"{
  description = "External IP of Ubuntu Linux EC2."
  value = aws_instance.tf_ubuntu_ec2.public_ip
}