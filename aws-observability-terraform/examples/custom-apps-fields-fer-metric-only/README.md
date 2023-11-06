# This is a custom example to install JUST the core AWSO infrastructure
Much of AWS on sumo side should only be created ONCE.

If using multiple terraform projects to deploy AWSO this creates problems for a single sumo org as there are collisions in the objects that are shared like fields etc.

for example you can only create the AWSO heirarchy once.
```
│ Error: {"id":"976QJ-0DVKL-IQOMT","errors":[{"code":"hierarchy:duplicate","message":"hierarchy named 'AWS Observability' already exist"}]}
│ 
│   with module.sumo-module.sumologic_hierarchy.awso_hierarchy,
│   on ../../app-modules/main.tf line 271, in resource "sumologic_hierarchy" "awso_hierarchy":
│  271: resource "sumologic_hierarchy" "awso_hierarchy" {
```

You may also just want to pipeline the sumo AWSO apps etc and just keep this in it's own pipeline seperate from collection (sources module).

This example shows how to have a terraform deployment just of the sumo side back end stuff for your sumo org in the apps module. So it has no sources module.

## Why do this Once only?
You may want to maintain multiple tf deployment pipelines for aws obserability such as:
- master account (apps / sources): This is setup first to create one time apps + source for first account/region
- other account/region: sources only


## What's in the apps module
These things are in the app module and only need to exist ONCE for all AWSO deployments:
- create heirarchy api call
- fields
- custom FERs: to relabel certain AWS logs
- metrics rules: alias certain key metric tags to new tag name
- awso app: dashboards for each service in Library which appear in Explore
- awso apps location (personal or admin recommended)
- awso apps sharing setting
- demo aws monitors folder and alerts for each service (imported but disable by default)
- custom notifications settings group for above if configured (none by default)

### Customized FERS
FERs in this project in field.tf are also customized in scope section.
The reason for this to:
- demonstrate how tweak FER scope if necessary in a rule
- support centralized cloudtrail collection (see topic below)


## What issues will happen if you include apps in more than one tf project?
Creating or pre-existence of some items cause issues if you include in multiple tf projects.
- heirarchy should only exist once or tf will error
- tf provider does not have a datasource for fields - they are created again each time. so if a field exists tf will get error for pre-existing. Hence the workaround in deployment guide to import any existin fields/fers wiht fields.sh
- same is true for fers (in fields.sh)
- same is true for metric rules - this is not in the fields.sh for some reason??
- awso app - you cannot install 2x into same folder location. installing multiple times will create duplicates in UI
- cannot import same monitor folder 2x in same location.

## Deployment
- do step 1 from https://help.sumologic.com/docs/observability/aws/deploy-use-aws-observability/deploy-with-terraform/#step-1-set-up-the-terraform-environment
- read step 2. review and edit ./main.auto.tfvars and set deployment/env region correctly
- 1.1 presumably you have your own repo if you got this far!
- 1.2 terraform init
- 1.3 in this example config is a mix of secrets  defined via TF_VAR_ in shell script (Review if this is appropriate for your env.) and the main.auto.tfvars file.

### step 1.4 fields import
Re 1.4 it's **highly likely some of the fields already exist** in your org and this will cause errors with deployment, as the field already exists. You will get error below for each field already existing (or FER)
- 
```
╷
│ Error: {"id":"7GCYS-LGM9Z-8OGMO","errors":[{"code":"field:already_exists","message":"Field with the given name already exists"}]}
│ 
│   with sumologic_field.account,
│   on field.tf line 7, in resource "sumologic_field" "account":
│    7: resource "sumologic_field" "account" {
│
```

To resolve this import the fields into your state file with fields.sh as per 1.4

Don't worry you can run fields.sh and you will get a bunch of errors like this below. It doesn't crash the import script so it will still import the missing ones, it just looks messy in ui. End result is your state will be a nice merge of both.
```
module.sumo-module.data.sumologic_admin_recommended_folder.adminRecoFolder: Read complete after 2s [id=00000000005EB9EE]
╷
│ Error: Resource already managed by Terraform
│ 
│ Terraform is already managing a remote object for sumologic_field.apiname. To import to this address you must first remove the existing object from the state.
```

### Heiriarchy collision
The Heirarchy api is a hidden back end component that creates explore. It can only exist ONCE.

You may have this issue if you ever setup AWSO before in your org, or sometimes it happens first time running the project via terraform (not sure why!)
https://help.sumologic.com/docs/observability/aws/deploy-use-aws-observability/deploy-with-terraform/#hierarchy-named-aws-observability-already-exist

You can try the delete suggested by docs.
```
curl -s -H 'Content-Type: application/json' --user "$SUMO_ACCESS_ID:$SUMO_ACCESS_KEY" -X GET https://api.au.sumologic.com/api/v1/entities/hierarchies | jq
curl -s -H 'Content-Type: application/json' --user "$SUMO_ACCESS_ID:$SUMO_ACCESS_KEY" -X DELETE https://api.au.sumologic.com/api/v1/entities/hierarchies/0000000000000458
```
If this still doesn't work (it gets recreated then errors) you can import it. (maybe a provider bug?? - an incomplete heirarchy is created that then causes an error.)
```
{
      "name": "AWS Observability",
      "level": {
        "entityType": "account",
        "nextLevelsWithConditions": [],
        "nextLevel": {
          "entityType": "region",
          "nextLevelsWithConditions": [],
          "nextLevel": {
            "entityType": "namespace",
            "nextLevelsWithConditions": [],
            "nextLevel": {
              "entityType": "entity",
              "nextLevelsWithConditions": [],
              "nextLevel": null
            }
          }
        }
      },
      "filter": null,
      "id": "0000000000001354"
    }
```

Use curl as above to get id then import it:
```
terraform import module.sumo-module.sumologic_hierarchy.awso_hierarchy 0000000000001354
```

## Final Deployment
skip to step 6 in origional docs and deploy. You may need to backtrack to import for fields or heirarchy above to get one clean deploy.
```
terraform validate
terraform plan
terraform apply
```

## Custom Cloudtrail / Watch /ALB FERs
This project includes custom FERs in field.tf that are compatible with both AWSO created or existing cloudtrail sources (provided ```_sourcecategory=*cloudtrail*```). You can see the modified FERs in field.tf and further edit if necessary.

For a customer with existing centralized cloudtrail collection it's better to scope to ```_sourcecategory=*cloudtrail* ``` instead of ```account=* region=*```.

This is because the account field does not exist in cloudtrails where a customer already has existing collection. Using this workaround will create a FER contention (because they run in random order): https://help.sumologic.com/docs/observability/aws/other-configurations-tools/integrate-control-tower-accounts/#step-3-create-field-extraction-rule. 

In such a config the user could include this extra central FER for cloudtrails in as an additional FER in this project if necessary. (see "DEMONSTRATION CENTRAL FER FOR EXISTING SINGLE BUCKET CLOUDTRAILS" in field.tf)