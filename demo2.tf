provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 16
  require_lowercase_characters   = false
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
  max_password_age               = 90
  password_reuse_prevention = 3
}

resource "aws_cloudwatch_metric_alarm" "console_without_mfa" {
  alarm_name          = "console-without-mfa-us-west-2"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ConsoleWithoutMFACount"
  namespace           = "someNamespace"
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Use of the console by an account without MFA has been detected"
  alarm_actions       = ["someTopic"]
}

resource "aws_sns_topic" "security_alerts" {
  name  = "someTopic"
  arn   = "someTopic"

}

resource "aws_cloudtrail" "example" {

  is_multi_region_trail = true

  cloud_watch_logs_group_arn    = "aws:arn::log-group:someLogGroup:"
  event_selector {
    read_write_type = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::Lambda::Function"
      values = ["arn:aws:lambda"]
    }
  }
}



##########

resource "aws_cloudwatch_log_metric_filter" "Root" {
  name           = "console-without-mfa"
  pattern        = "{($.errorCode = \"AccessDenied*\")}"
  log_group_name = "someLogGroup"

  metric_transformation {
    name      = "AccessDenied"
    namespace = "someNamespace"
    value     = "1"
  }
}
















