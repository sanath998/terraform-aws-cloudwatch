variable "create_iam_role" {
 type = bool
 default = false
 description = "Whether to create an IAM role which is able to write logs to the CloudWatch Logs log group"
}

variable "iam_additional_permissions" {
 type = list(string)
 default = []
 description = "Additional permissions granted to the created IAM role. Only used when `create_iam_role` is `true`"
}

variable "iam_principals" {
 type = map(any)
 default = {}
 description = <<-EOT
 Map of principals able to assume created IAM role, for example:
 <pre>iam_principals = {
 Service = ["ec2.amazonaws.com"]
 }</pre>
 Required when `create_iam_role` is `true`, otherwise it will error "An IAM assume role policy must be present!"
 EOT
}

variable "kms_key_arn" {
 type = string
 default = null
 description = <<-EOT
 The ARN of the KMS Key to use when encrypting log data.
 Please note, after the AWS KMS CMK is disassociated from the log group, AWS CloudWatch Logs stops encrypting newly ingested data for the log group.
 All previously ingested data remains encrypted, and AWS CloudWatch Logs requires permissions for the CMK whenever the encrypted data is requested.
 EOT
}

variable "log_group_class" {
 type = string
 default = "STANDARD"
 description = <<EOT
 Specify the log class of the log group. Possible values are: `STANDARD` or `INFREQUENT_ACCESS`. 
 After a log group is created, its log class can't be changed. 
 See https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CloudWatch_Logs_Log_Classes.html and https://aws.amazon.com/blogs/aws/new-amazon-cloudwatch-log-class-for-infrequent-access-logs-at-a-reduced-price/ for further information.
 EOT

 validation {
 condition = var.log_group_class == "STANDARD" || var.log_group_class == "INFREQUENT_ACCESS"
 error_message = "Invalid value. Please select either 'STANDARD' or 'INFREQUENT_ACCESS'"
 }
}

variable "log_group_name" {
 type = string
 default = null
 description = "Use this to override the default log group name."
}

variable "logs_source" {
 type = string
 default = null
 description = "Source of the CloudWatch Log Group (e.g., `lambda`, `vpc`), used for naming your cloud resources"

 validation {
 condition = var.logs_source == null ? true : can(regex("^[a-z0-9-_]+$", var.logs_source))
 error_message = "The logs_source variable must only have lowercase alphanumeric, underscore and hyphen characters"
 }
}

variable "logs_context" {
 type = string
 default = null
 description = "Arbitrary name of the context of the CloudWatch Log Group (e.g., `deletesnapshots`, `sendnotification`), used for naming your cloud resources"

 validation {
 condition = var.logs_context == null ? true : can(regex("^[a-z0-9-_]+$", var.logs_context))
 error_message = "The logs_context variable must only have lowercase alphanumeric, underscore and hyphen characters"
 }
}

variable "name_prefix" {
 type = string
 default = null
 description = "Optional prefix for the naming your cloud resources. If not specified, then account naming construct will be used, please see README.md for details"

 validation {
 condition = (can(regex("^[a-z0-9-_]+$", var.name_prefix)) || var.name_prefix == null)
 error_message = "The name_prefix variable must only have lowercase alphanumeric, underscore and hyphen characters"
 }
}

variable "resource_policy_principals" {
 type = map(any)
 default = {}
 description = <<-EOT
 Map of principals to add to optional CloudWatch log resource policy, for example:
 <pre>resource_policy_principals = {
 Service = ["ec2.amazonaws.com"]
 }</pre>
 If not provided, no log resource policy is created. See [AWS Docs](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/iam-access-control-overview-cwl.html) for details
 EOT
}

variable "retention_in_days" {
 type = number
 default = 90
 description = "Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If value is 0 the events in the log group are always retained and never expire"

 validation {
 condition = contains([0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.retention_in_days)
 error_message = "Invalid value. Please select one of [0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653]"
 }
}

variable "stream_names" {
 type = list(string)
 default = []
 description = "A list of log stream names to create"
}

variable "tags" {
 type = map(string)
 default = {}
 description = "Tags for AWS resources. See https://pages.experian.com/pages/viewpage.action?pageId=400041906 for all available tags"
}

variable "disable_org_check" {
 type = bool
 default = false
 description = "Set this to true to remove the Deny permission in the trust policy which stops services from outside the  Organization from assuming the role"
}