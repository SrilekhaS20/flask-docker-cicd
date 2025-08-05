# Root Cause Analysis (RCA) Document

## 1. Error #1: "Error creating Flow Log"

### Missing IAM Role

![Missing IAM Role](https://github.com/SrilekhaS20/flask-docker-cicd/blob/main/screenshots/vpc_flow_log_error1.jpg)

### Situation:

#### The second error may be related to the first, possibly an invalid or incomplete parameter being passed into the flow log creation process, or it may involve an issue with the IAM Role or permissions that were not addressed.


### Root Cause:

#### A common reason for this error is the incorrect or incomplete setup of the IAM role or permissions associated with the flow logs. This could also be caused by the resource missing specific parameters needed to successfully create the flow log.


### Impact:

#### Similar to the first error, it prevents the flow logs from being created, which could impair logging and monitoring, leaving gaps in the ability to troubleshoot issues with traffic flow.


### Solution/Resolution:

#### Step 1: Ensure that the IAM role used for flow logs has the correct permissions, such as AmazonVPCFullAccess or a custom policy that allows flow log creation.

#### IAM Role:
```main.tf
resource "aws_iam_role" "vpc_flow_log_role" {
  name = "${var.vpc_name}-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.vpc_name}-flow-log-role"
    Environment = "Development"
    Owner = "Srilekha"
    Project = "EKS-Fintech-LLM"
    Terraform = "true"
  }
}

resource "aws_iam_role_policy_attachment" "vpc_flow_log_policy_attachment" {
  role       = aws_iam_role.vpc_flow_log_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}
```


#### Step 2: Ensure that the role name and policy ARN are correctly specified, especially if you're using Terraform.

#### Step 3: Verify that the vpc_id is correct and exists in the specified region.


### Lessons Learned:

#### Prevention: Always validate the IAM roles associated with resources to ensure that they have sufficient permissions. When creating log-related resources, ensure that your role includes permissions for creating logs and writing to the log destination.

#### Testing: Use terraform plan to check for any misconfigurations before applying changes to ensure that IAM policies and roles are correctly referenced.

---

## 2. Error #2: EC2: CreateFlowLogs operation error - InvalidParameter: LogDestination can't be empty if LogGroupName is not provided.

### Missing LogGroupName

![Missing LogGroupName](https://github.com/SrilekhaS20/flask-docker-cicd/blob/main/screenshots/vpc_flow_log_error2.jpg)

### Situation:

#### The VPC Flow Log resource was being created in AWS, but the flow log creation failed because the destination for the logs (LogGroupName) was not specified. AWS Flow Logs require that the destination log group is either explicitly specified, or that the log group is created.


### Root Cause:

#### The aws_flow_log resource was misconfigured, and the LogGroupName (for the destination log stream) was not specified in the configuration. AWS Flow Logs require a valid log destination such as a CloudWatch Log Group or S3 Bucket.


### Impact:

#### The flow logs for the VPC couldn’t be created, causing a delay in logging and monitoring traffic flow, which could affect future troubleshooting or analysis.


### Solution/Resolution:

#### Step 1: Check the flow log configuration in Terraform for the missing log_group_name or log_destination.

#### Step 2: Add a valid log_group_name or specify an S3 bucket for the flow log destination.

#### Fix

```main.tf
resource "aws_cloudwatch_log_group" "vpc_flow_log_group" {
  name = "/aws/vpc/flow-logs/${var.vpc_name}"

  retention_in_days = 7

  tags = {
    Name = "${var.vpc_name}-flow-log-group"
    Environment = "Development"
    Owner = "Srilekha"
    Project = "EKS-Fintech-LLM"
    Terraform = "true"
  }
}
```

### Lessons Learned:

#### Prevention: Always ensure a log destination is defined for logging-related resources in AWS, especially for flow logs. In Terraform, use appropriate output configuration and validation for log groups or other destinations.

#### Testing: Before applying changes, validate configurations using terraform validate and test in a staging environment to ensure resources are created as expected.


---

### Summary:

#### The errors are related to missing log destination configuration and possibly misconfigured IAM permissions.

#### Both errors were resolved by ensuring that the log_group_name or destination is specified and that the IAM role has sufficient permissions to create and write logs.
