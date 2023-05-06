output "dynamodb_lock_table" {
  value = aws_dynamodb_table.terraform-state-locking.id
}

output "s3_remote_state_bucket" {
  value = aws_s3_bucket.terraform-bucket.id
}