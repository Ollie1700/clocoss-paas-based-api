#!/bin/bash

# The user provides a parameter for the name of the sql instance
SQL_NAME=$1;

# If the parameter isn't provided, exit
if [ -z "$SQL_NAME" ]
then
    echo "Please provide a valid name for your SQL server.";
    exit;
fi

# Create a new cloud SQL instance
gcloud sql instances create $SQL_NAME --tier=D1 --region=europe-west1;

# Create a new user for the new instance
gcloud sql users create $SQL_NAME-user % --instance=$SQL_NAME --password=root;

# Assign the instance with an IP
gcloud sql instances patch $SQL_NAME --assign-ip;

# Get the IP of the new instance
SQL_IP=`gcloud sql instances describe ollie-sql | grep -Pe "(?<=- ipAddress: ).+(?=)" -o`;

# Set the database name
DB_NAME="clocoss"

# Create the db_vars.json file that our node app requires
echo "{\"host\":\"$SQL_IP\",\"user\":\"$SQL_NAME-user\",\"password\":\"root\",\"database\":\"$DB_NAME\"}" > db_vars.json;

# Get the IP of this instance
SERVER_IP=`curl -s -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip"`;

# Add this server's IP to the list of whitelisted networks on the SQL instance
gcloud sql instances patch $SQL_NAME --authorized-networks=$SERVER_IP;

# Create a new database
ACCESS_TOKEN="$(gcloud auth application-default print-access-token)"
curl --header "Authorization: Bearer ${ACCESS_TOKEN}" \
     --header 'Content-Type: application/json' \
     --data "{\"project\": \"clocoss-2017\", \"instance\": \"$SQL_NAME\", \"name\": \"$DB_NAME\"}" \
     https://www.googleapis.com/sql/v1beta4/projects/clocoss-2017/instances/$SQL_NAME/databases -X POST;

# NPM install
npm install;

# Tell the user we're finished
echo "Cloud SQL and Node/NPM setup completed. Please run the server with 'node server'";
