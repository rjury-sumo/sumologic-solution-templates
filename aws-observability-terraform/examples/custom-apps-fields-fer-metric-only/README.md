# This is a custom example to install JUST the core AWSO infrastructure

If using multiple terraform projects or a custom collection architecture this project will create only the AWSO back end in Sumo not any actual collection.

This means using the app mdule ONLY.

## Why do this Once only?
You may want to maintain multiple tf deployment pipelines for aws obserability such as:
- master account (apps / sources): This is setup first to create one time apps + source for first account/region
- other account/region: sources only

## What's in the apps module
These things are in the app module and only need to exist ONCE for all AWSO deployments:
- create heiriarchy api call
- fields
- custom FERs: to relabel certain AWS logs
- metrics rules: alias certain key metric tags to new tag name
- awso app: dashboards for each service in Library which appear in Explore
- awso apps location (personal or admin recommended)
- awso apps sharing setting
- demo aws monitors folder and alerts for each service (imported but disable by default)
- custom notifications settings group for above if configured (none by default)

## What issues will happen if you include apps in more than one tf project?
Creating or pre-existence of some items cause issues if you include in multiple tf projects.
- herirarchy should only exist once, but overwriting this is probably fine
- tf provider does not have a datasource for fields - they are created again each time. so if a field exists tf will get error for pre-existing. Hence the workaround in deployment guide to import any existin fields/fers wiht fields.sh
- same is true for fers (in fields.sh)
- same is true for metric rules - this is not in the fields.sh for some reason??
- awso app - you cannot install 2x into same folder location. installing multiple times will create duplicates in UI
- cannot import same monitor folder 2x in same location.

## Deployment


- do step 1 from https://help.sumologic.com/docs/observability/aws/deploy-use-aws-observability/deploy-with-terraform/#step-1-set-up-the-terraform-environment
- read step 2. review and edit ./main.auto.tfvars and set deployment/env region correctly
1.1 presumably you have your own repo if you got this far!
1.2 terraform init
1.3 in this example config is a mix of secrets  defined via TF_VAR_ in shell script (Review if this is appropriate for your env.) and the main.auto.tfvars file.

skip to step 6
```
terraform validate
terraform plan
terraform apply
```
- 
