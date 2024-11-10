module "eits_vars" {
 source = ""

 module_repo = "eits-tf-aws-cloudwatch-logs"
 tags = var.tags
}

locals {
 prefix = var.name_prefix != null ? var.name_prefix : module.eits_vars.prefix
 name = var.log_group_name != null ? var.log_group_name : "${local.prefix}-${var.logs_source}-${var.logs_context}"
 tags = merge(var.tags, module.eits_vars.tags)
}

resource "aws_cloudwatch_log_group" "this" {
 name = local.name
 retention_in_days = var.retention_in_days
 kms_key_id = var.kms_key_arn
 log_group_class = var.log_group_class
 tags = local.tags
}

resource "aws_cloudwatch_log_stream" "this" {
 for_each = toset(var.stream_names)

 name = each.value
 log_group_name = aws_cloudwatch_log_group.this.name
}

module "iam_role" {
 source = ""
 count = var.create_iam_role ? 1 : 0

 role_name = "_${local.name}"
 role_description = "Cloudwatch log group role for ${local.name}"
 policy_name = "_${local.name}"
 policy_description = "Cloudwatch log group policy for ${local.name}"
 assume_role_policy = length(keys(var.iam_principals)) > 0 ? join("", data.aws_iam_policy_document.assume_role[*].json) : ""
 policy_documents = [data.aws_iam_policy_document.log_agent[0].json]
 disable_org_check = var.disable_org_check

 tags = var.tags

}

data "aws_iam_policy_document" "assume_role" {
 count = var.create_iam_role ? length(keys(var.iam_principals)) : 0

 statement {
 sid = "AssumeCloudwatchLogGroupRole"
 effect = "Allow"
 actions = ["sts:AssumeRole"]

 principals {
 type = element(keys(var.iam_principals), count.index)
 identifiers = var.iam_principals[element(keys(var.iam_principals), count.index)]
 }
 }
}

data "aws_iam_policy_document" "log_agent" {
 count = var.create_iam_role ? 1 : 0

 statement {
 sid = "ReadCloudwatchLogGroup"
 effect = "Allow"
 resources = ["*"]

 actions = [
 "logs:DescribeLogGroups",
 "logs:DescribeLogStreams",
 ]
 }

 statement {
 sid = "UseCloudwatchLogGroup"
 effect = "Allow"
 resources = ["${aws_cloudwatch_log_group.this.arn}:*"]

 actions = concat(var.iam_additional_permissions, [
 "logs:PutLogEvents",
 "logs:CreateLogStream",
 "logs:DeleteLogStream",
 ])
 }
}

# log resource policy document
data "aws_iam_policy_document" "log_resource_policy" {
 count = length(keys(var.resource_policy_principals))

 statement {
 effect = "Allow"
 resources = ["${aws_cloudwatch_log_group.this.arn}:*"]
 actions = [
 "logs:CreateLogStream",
 "logs:PutLogEvents",
 "logs:PutLogEventsBatch"
 ]

 principals {
 type = element(keys(var.resource_policy_principals), count.index)
 identifiers = var.resource_policy_principals[element(keys(var.resource_policy_principals), count.index)]
 }
 }
}

# add resource policy if required
resource "aws_cloudwatch_log_resource_policy" "this" {
 count = length(keys(var.resource_policy_principals)) > 0 ? 1 : 0

 policy_document = join("", data.aws_iam_policy_document.log_resource_policy[*].json)
 policy_name = var.log_group_name != null ? "${var.log_group_name}-resource-policy" : "${var.logs_source}-${var.logs_context}-resource-policy"
}