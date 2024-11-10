output "log_group_arn" {
 description = "ARN of the log group"
 value = aws_cloudwatch_log_group.this.arn
}

output "log_group_name" {
 value = aws_cloudwatch_log_group.this.name
 description = "Name of log group"
}

output "role_arn" {
 value = try(module.iam_role[0].role_arn, null)
 description = "The ARN of the IAM role if created"
}

output "role_name" {
 value = try(module.iam_role[0].role_name, null)
 description = "The name of the IAM role if created"
}

output "stream_arns" {
 value = try(aws_cloudwatch_log_stream.this[*].arn, null)
 description = "ARNs of the log streams"
}