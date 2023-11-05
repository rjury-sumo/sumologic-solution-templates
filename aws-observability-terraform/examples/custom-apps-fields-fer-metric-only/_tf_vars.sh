# creates vars so I don't have to put these in the repo in ./custom-apps-fields-fer-metric-only/main.auto.tfvars
#sumologic_environment       = "au"      # Please replace <YOUR SUMO DEPLOYMENT> (including brackets) with au, ca, de, eu, jp, us2, in, fed or us1.
export TF_VAR_sumologic_access_id="$SUMO_ACCESS_ID"
export TF_VAR_sumologic_access_key="$SUMO_ACCESS_KEY"

# this will help when you need to do fields.sh file.
export SUMOLOGIC_ENV="au"
export SUMOLOGIC_ACCESSID="$SUMO_ACCESS_ID"
export SUMOLOGIC_ACCESSKEY="$SUMO_ACCESS_KEY"