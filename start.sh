#!/bin/bash

# The user provides a parameter for the name of the sql instance
SQL_NAME=$1;

# If the parameter isn't provided, exit
if [ -z "$SQL_NAME" ]
then
    echo "Please provide a valid name for your SQL server.";
    exit;
fi

# Install Node
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -;
sudo apt-get install nodejs;

# Create a new cloud SQL instance
gcloud sql instances create $SQL_NAME --tier=D1 --region=europe-west1 -q;

# Create a new user for the new instance
gcloud sql users create $SQL_NAME-user % --instance=$SQL_NAME --password=root -q;

# Assign the instance with an IP
gcloud sql instances patch $SQL_NAME --assign-ip -q;

# Get the IP of the new instance
SQL_IP=`gcloud sql instances describe $SQL_NAME | grep -Pe "(?<=- ipAddress: ).+(?=)" -o`;

# Get the instance name of the new instance
SQL_INSTANCE_NAME=`gcloud sql instances describe $SQL_NAME | grep -Pe "(?<=connectionName: ).+(?=)" -o`;

# Set the database name
DB_NAME="clocoss"

# Generate the yaml file for deployment
cat > app.yaml <<- EOM
comruntime: nodejs
env: flex
service: clocosspaasbasedapi
automatic_scaling:
  min_num_instances: 1
  max_num_instances: 3
env_variables:
  SQL_USER: $SQL_NAME-user
  SQL_PASSWORD: root
  SQL_DATABASE: $DB_NAME
  INSTANCE_CONNECTION_NAME: $SQL_INSTANCE_NAME
beta_settings:
  cloud_sql_instances: $SQL_INSTANCE_NAME
EOM

# Old code
# echo "{\"host\":\"$SQL_IP\",\"user\":\"$SQL_NAME-user\",\"password\":\"root\",\"database\":\"$DB_NAME\"}" > db_vars.json;
# / old code

# Get the IP of this instance
SERVER_IP=`curl -s -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip"`;

# Add this server's IP to the list of whitelisted networks on the SQL instance
gcloud sql instances patch $SQL_NAME --authorized-networks=$SERVER_IP -q;

# Create a new database
ACCESS_TOKEN="$(gcloud auth application-default print-access-token)"
curl --header "Authorization: Bearer ${ACCESS_TOKEN}" \
     --header 'Content-Type: application/json' \
     --data "{\"project\": \"clocoss-2017\", \"instance\": \"$SQL_NAME\", \"name\": \"$DB_NAME\"}" \
     https://www.googleapis.com/sql/v1beta4/projects/clocoss-2017/instances/$SQL_NAME/databases -X POST;

# NPM export vars and install
export SQL_USER="$SQL_NAME-user";
export SQL_PASSWORD="root";
export SQL_DB="$DB_NAME";
npm install;

# Deploy
gcloud app deploy;
