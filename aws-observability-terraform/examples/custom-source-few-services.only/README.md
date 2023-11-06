# Example Source Module Only
This config is an example for deploying *ONLY the source module config*, which is required for each account/region you want to deploy to.
App module is not included as it only needs to be created ONDCE for all accounts and regions - so assumption is you might have another tf project to manage the core AWSO config on sumo side.

There is another example in this repo for the app module see: ../custom-apps-fields-fer-metric-only

there are many options available for the source module:
- docs page: # for possible params for source module see: https://github.com/SumoLogic/sumologic-solution-templates/tree/master/aws-observability-terraform/source-module
- variable config: https://github.com/SumoLogic/sumologic-solution-templates/blob/master/aws-observability-terraform/source-module/variables.tf

# Architecture and High Level Design
AWSO can deploy many sources. Often you might have existing ones (such as cloudtrail / metrics) and this can impact on deployment.

Additionally some sources such as ALB access or cloudwatch logs can be *very large GB*, so you should monitor ingest after setup, and consider setting up a config to route high volume log value logs to infrequent data tier. For example setup Field Extraction Rules and partition scope to route ALB access logs for codes < HTTP4XX to infrequent tier.

For planning, review the cloudformation deployment docs instead, as the options are similar but in a nice orderly format (by service) in steps 5+. Once you know what options you want to configure you can then find equivalent terraform params
https://help.sumologic.com/docs/observability/aws/deploy-use-aws-observability/deploy-with-aws-cloudformation/#step-5-sumo-logic-aws-cloudwatch-metrics-sources

Before deployment make a plan that has for each service:
- is it collected already or not. 
- What config will change with AWSO
- for existing sources what is the migration plan? Tag existing or replace wiht AWSO?
- does that source have a risk of high volume so might need tiering

Then you can create the detailed configuration in terraform to match this deployment

## deployment
- assumes you are setting sumo creds in TF_VAR: 
```
export TF_VAR_sumologic_access_id="$SUMO_ACCESS_ID"
export TF_VAR_sumologic_access_key="$SUMO_ACCESS_KEY"
```
- AWS provider will need the usual suspects (aws cli profile etc)
- set collection params in ./main.auto.tfvars
- ./main.tf has more advanced options for config but they are commented out