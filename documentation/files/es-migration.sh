#!/bin/bash

SRC_USERNAME=
SRC_PASSWORD=
SRC_HOST=
SRC_PORT=
SRC_CERT=hri-documentstore-source.crt

DEST_USERNAME=
DEST_PASSWORD=
DEST_HOST=
DEST_PORT=
DEST_CERT=hri-documentstore-destination.crt

COS_ENDPOINT=s3.private.us.cloud-object-storage.appdomain.cloud
BUCKET=
ACCESS_KEY=
SECRET_KEY=

echo "Registering COS BUCKET with source instance"
CURL_CA_BUNDLE=$SRC_CERT curl -sS -f -X POST -u $SRC_USERNAME:$SRC_PASSWORD https://$SRC_HOST:$SRC_PORT/_snapshot/migration \
-H 'Content-Type: application/json' -d'
{
  "type": "s3",
  "settings": {
    "endpoint": "'$COS_ENDPOINT'",
    "bucket": "'$BUCKET'",
    "access_key": "'$ACCESS_KEY'",
    "secret_key": "'$SECRET_KEY'"
  }
}
'

echo
echo "Registering COS BUCKET with destination instance"
CURL_CA_BUNDLE=$DEST_CERT curl -sS -f -X POST -u $DEST_USERNAME:$DEST_PASSWORD https://$DEST_HOST:$DEST_PORT/_snapshot/migration \
-H 'Content-Type: application/json' -d'
{
  "type": "s3",
  "settings": {
    "readonly": true,
    "endpoint": "'$COS_ENDPOINT'",
    "bucket": "'$BUCKET'",
    "access_key": "'$ACCESS_KEY'",
    "secret_key": "'$SECRET_KEY'"
  }
}
'

echo
echo "Getting Existing indices to be migrated"
indices=$(CURL_CA_BUNDLE=$SRC_CERT curl -sS -f -X GET -u $SRC_USERNAME:$SRC_PASSWORD https://$SRC_HOST:$SRC_PORT/_cat/indices/*-batches | awk '{ print $3 }') 

indices=$(echo "${indices[*]}" | tr '\n' ',' | awk 'gsub(/,$/,x)')
echo $indices

echo "Creating snapshot"
CURL_CA_BUNDLE=$SRC_CERT curl -sS -f -X PUT -u $SRC_USERNAME:$SRC_PASSWORD "https://$SRC_HOST:$SRC_PORT/_snapshot/migration/backup-2?wait_for_completion=true" \
   -H 'Content-Type: application/json' -d '{"include_global_state": false}'

echo
echo "Restoring snapshot"
CURL_CA_BUNDLE=$DEST_CERT curl -sS -f -X POST -u $DEST_USERNAME:$DEST_PASSWORD "https://$DEST_HOST:$DEST_PORT/_snapshot/migration/backup-2/_restore?wait_for_completion=true" \
   -H 'Content-Type: application/json' -d '{"include_global_state": false, "indices": "'$indices'"}'

echo
echo "Listing restored indices"
CURL_CA_BUNDLE=$DEST_CERT curl -sS -f -X GET -u $DEST_USERNAME:$DEST_PASSWORD https://$DEST_HOST:$DEST_PORT/_cat/indices/*-batches

