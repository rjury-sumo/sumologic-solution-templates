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
1.4 It's highly likely some of the fields already exist in your org and then this will happen (because fields try to create and cannot handle already existing resource with same name)
```
╷
│ Error: {"id":"7GCYS-LGM9Z-8OGMO","errors":[{"code":"field:already_exists","message":"Field with the given name already exists"}]}
│ 
│   with sumologic_field.account,
│   on field.tf line 7, in resource "sumologic_field" "account":
│    7: resource "sumologic_field" "account" {
│
```
to resolve this import the fields into your state file with fields.sh as per 1.4

If you already tried the terrafrom apply and it failed at this point,  don't worry you can run fields.sh and you will get a buch of errors like this below. But it doesn't crash the import script so it will still import the missing ones, it just looks messy in ui.
```
module.sumo-module.data.sumologic_admin_recommended_folder.adminRecoFolder: Read complete after 2s [id=00000000005EB9EE]
╷
│ Error: Resource already managed by Terraform
│ 
│ Terraform is already managing a remote object for sumologic_field.apiname. To import to this address you must first remove the existing object from the state.
```

Or you can create a version of fields.sh just for the overlap delta. ( there are two lists defined as variables)


### Heriarchy collision
You may have this issue if you ever setup AWSO before in your org, or sometimes it happens first time running the project. (not sure why!)
https://help.sumologic.com/docs/observability/aws/deploy-use-aws-observability/deploy-with-terraform/#hierarchy-named-aws-observability-already-exist

easy fix as per above. You could import it but there have been changes in the heirarchy between awso versions in past to removal is probably best option as per docs.
```
curl -s -H 'Content-Type: application/json' --user "$SUMO_ACCESS_ID:$SUMO_ACCESS_KEY" -X GET https://api.au.sumologic.com/api/v1/entities/hierarchies | jq
curl -s -H 'Content-Type: application/json' --user "$SUMO_ACCESS_ID:$SUMO_ACCESS_KEY" -X DELETE https://api.au.sumologic.com/api/v1/entities/hierarchies/0000000000000458
```

If you get an error that an incomplete heirarchy gets created, sometimes (maybe a provider bug??) an incomplete heirarchy is created that then causes an error.
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

skip to step 6
```
terraform validate
terraform plan
terraform apply
```
- 


