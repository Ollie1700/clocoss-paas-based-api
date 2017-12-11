#!/bin/bash

# The user provides a parameter for the name of the sql instance
SQL_NAME="olasfz";

# Assign the instance with an IP
gcloud sql instances patch $SQL_NAME --assign-ip -q;

# Set the database name
DB_NAME="clocoss"

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
gcloud app deploy -q;
