####### BELOW ARE REQUIRED PARAMETERS FOR TERRAFORM SCRIPT #######
# Visit - https://help.sumologic.com/Solutions/AWS_Observability_Solution/03_Set_Up_the_AWS_Observability_Solution#sumo-logic-access-configuration-required

sumologic_environment       = "au"      # Please replace <YOUR SUMO DEPLOYMENT> (including brackets) with au, ca, de, eu, jp, us2, in, fed or us1.

# defined these in _tf_vars_sh to avoid secrets in repo
# sumologic_access_id         = ""
# sumologic_access_key        = ""

sumologic_organization_id   = "00000000005756A4"      # Please replace <YOUR SUMO ORG ID> (including brackets) with your Sumo Logic Organization ID.

# this is required only in source modules
aws_account_alias           = "ricksandbox"      # Please replace <YOUR AWS ACCOUNT ALIAS> with an AWS account alias for identification in Sumo Logic Explorer View, metrics and logs.

# Example: https://api.sumologic.com/api/ Please update with your sumologic api endpoint. Refer, https://help.sumologic.com/APIs/General-API-Information/Sumo-Logic-Endpoints-and-Firewall-Security
sumo_api_endpoint           = "https://api.au.sumologic.com/api/"        #"<YOUR SUMOLOGIC API ENDPOINT>"

# we can define simple on/off type params for collection here
# in some cases more advanced options are available in which case you might want to use main.tf as overide location

# If new to AWSO review the cloudformation version steps 5+ to understand what groups of options are available
# They are in simple order there as cfn params (rather than longer more complex list in terraform)
# Once you know what options you want to configure you can then find equivalent terraform params
# https://help.sumologic.com/docs/observability/aws/deploy-use-aws-observability/deploy-with-aws-cloudformation/#step-5-sumo-logic-aws-cloudwatch-metrics-sources

# Terraform params
# for possible params for source module see: https://github.com/SumoLogic/sumologic-solution-templates/tree/master/aws-observability-terraform/source-module
# and https://github.com/SumoLogic/sumologic-solution-templates/blob/master/aws-observability-terraform/source-module/variables.tf


# AWS CloudWatch Metrics Sources (cloudformation step 5)
# "CloudWatch Metrics Source" - Creates Sumo Logic AWS CloudWatch Metrics Sources.
# "Kinesis Firehose Metrics Source" (Recommended) - cost and performance benefits vs CloudWatch Metrics
# "None" - Skips the Installation of both the Sumo Logic Metric Sources
collect_cloudwatch_metrics = "None"

# AWS ALB Log Source (cloudformation step 6)
# **** high volume source - consider FER/partition config to send some events to infreuqent tier in sumo! ***
# true - Creates a Sumo Logic Log Source that collects application load balancer logs from an existing bucket or a new bucket.
# configure "elb_source_details" details
# false - no collection 
collect_elb_logs = true
auto_enable_access_logs = "Both"

# CloudTrail Source (step 7)
# **** high volume source - consider FER/partition config to send some events to infreuqent tier in sumo! ***
# many customers already collect cloudtrail so would:
# - select false here
# - setup an FER to map accountid for each known account to an account alias
# true - sets up collection, tune with "cloudtrail_source_details" configuration
# set to false if you already collect and want to use FER to tag logs with account field
collect_cloudtrail_logs = true

# AWS CloudWatch logs (step 8)
# **** high volume source - consider FER/partition config to send some events to infreuqent tier in sumo! ***
# logs are pushed to Sumo sources via a subcription on log groups in AWS account
# "Lambda Log Forwarder" - collects CloudWatch logs via a Lambda function.
# "Kinesis Firehose Log Source" - Kinesis Firehose Log Source to collect CloudWatch logs.
# "None" - Skips installation of both sources.
# creates an auto subsciption to apply to log groups
# NOTE: log groups subscription is filtered in auto_enable_logs_subscription_options
collect_cloudwatch_logs = "Kinesis Firehose Log Source"
auto_enable_logs_subscription = "Both"
auto_enable_logs_subscription_options = {
filter = "lambda|RDS"
}

# Sumo Logic Root Cause Explorer Sources (step 9)
# use this option unless you have Xray deployed
collect_root_cause_data = "Inventory Source"

# AWS ELB Classic Log Source (step 10)
# **** high volume source - consider FER/partition config to send some events to infreuqent tier in sumo! ***
collect_classic_lb_logs = true
auto_enable_classic_lb_access_logs = "Both"
