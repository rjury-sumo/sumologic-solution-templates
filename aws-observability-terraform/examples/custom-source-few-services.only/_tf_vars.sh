# creates vars so I don't have to put these in the repo in ./custom-apps-fields-fer-metric-only/main.auto.tfvars
#sumologic_environment       = "au"      # Please replace <YOUR SUMO DEPLOYMENT> (including brackets) with au, ca, de, eu, jp, us2, in, fed or us1.
export TF_VAR_sumologic_access_id="$SUMO_ACCESS_ID"
export TF_VAR_sumologic_access_key="$SUMO_ACCESS_KEY"
