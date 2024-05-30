#!/bin/bash

set -e

validate_name() {
  local name=$1
  if [[ ! $name =~ ^[a-z0-9\-]{1,63}$ ]]; then
    echo "Invalid name: $name"
    echo "Name must consist of lower case letters, digits, and hyphens, and be no more than 63 characters long."
    return 1
  fi
  return 0
}

create_certificate() {
  DOMAIN_NAME=$1
  CERT_NAME=$(echo "${DOMAIN_NAME}-cert" | tr '.' '-')
  CERT_AUTH_NAME=$(echo "${DOMAIN_NAME}-auth" | tr '.' '-')

  validate_name $CERT_NAME
  validate_name $CERT_AUTH_NAME

  # Step 1: Create SSL cert DNS Auth
  gcloud certificate-manager dns-authorizations create $CERT_AUTH_NAME --domain="$DOMAIN_NAME"

  # Step 2: Get the CNAME value for DNS Auth
  DNS_AUTH_OUTPUT=$(gcloud certificate-manager dns-authorizations describe $CERT_AUTH_NAME --format="yaml(dnsResourceRecord, domain)")

  # Extract the name and data from the output
  NAME=$(echo "$DNS_AUTH_OUTPUT" | grep "^  name:" | awk '{print $2}')
  DATA=$(echo "$DNS_AUTH_OUTPUT" | grep "^  data:" | awk '{print $2}')

  # Save to dns.txt
  echo "$NAME $DATA" >> dns.txt

  # Step 3: Create the SSL cert request
  gcloud certificate-manager certificates create $CERT_NAME --domains="$DOMAIN_NAME" --dns-authorizations="$CERT_AUTH_NAME"

  # Check the status of SSL cert
  gcloud certificate-manager certificates describe $CERT_NAME
}

CERT_NAMES=()
CERT_AUTH_NAMES=()
DOMAIN_NAMES=()

if [[ ! -f domain.txt ]]; then
  echo "The file domain.txt does not exist. Please create the file with domain names, one per line."
  exit 1
fi

while IFS= read -r DOMAIN_NAME; do
  create_certificate $DOMAIN_NAME
  CERT_NAMES+=($CERT_NAME)
  CERT_AUTH_NAMES+=($CERT_AUTH_NAME)
  DOMAIN_NAMES+=($DOMAIN_NAME)
done < domain.txt

# Step 4: Create SSL cert map
while true; do
  echo "Enter the name for the certificate map (lowercase letters, digits, hyphens, max 63 characters):"
  read CERT_MAP_NAME
  validate_name $CERT_MAP_NAME && break
done

gcloud certificate-manager maps create $CERT_MAP_NAME

# Step 5: Associate SSL certs with the cert map
for i in "${!CERT_NAMES[@]}"; do
  CERT_NAME=${CERT_NAMES[$i]}
  DOMAIN_NAME=${DOMAIN_NAMES[$i]}
  MAP_ENTRY_NAME=$(echo $DOMAIN_NAME | sed 's/\./-/g')-entry
  gcloud certificate-manager maps entries create $MAP_ENTRY_NAME --map="$CERT_MAP_NAME" --certificates="$CERT_NAME" --hostname="$DOMAIN_NAME"
done

# Check if the map entries are active before proceeding
for i in "${!CERT_NAMES[@]}"; do
  DOMAIN_NAME=${DOMAIN_NAMES[$i]}
  MAP_ENTRY_NAME=$(echo $DOMAIN_NAME | sed 's/\./-/g')-entry
  
  echo "Checking status for map entry $MAP_ENTRY_NAME..."
  while true; do
    STATUS=$(gcloud certificate-manager maps entries describe $MAP_ENTRY_NAME --map="$CERT_MAP_NAME" --format="value(state)")
    if [[ $STATUS == "ACTIVE" ]]; then
      echo "Map entry $MAP_ENTRY_NAME is ACTIVE."
      break
    else
      echo "Map entry $MAP_ENTRY_NAME is $STATUS. Waiting..."
      for i in {1..60}; do
        echo -n "."
        sleep 1
      done
      echo
    fi
  done
done

# Step 6: Optional - Attach the SSL Map with the Load Balancer
echo "Do you want to attach the SSL map to a load balancer? (y/n):"
read ATTACH_LB
if [[ $ATTACH_LB == "y" ]]; then
  LB_LIST=$(gcloud compute target-https-proxies list --format="value(name)")
  if [[ -z $LB_LIST ]]; then
    echo "There are no eligible load balancers available for SSL map association. Please create a suitable load balancer and try again."
  else
    echo "Available load balancers:"
    echo "$LB_LIST"
    echo "Enter the name of the load balancer target proxy:"
    read LB_TARGET_PROXY_NAME
    gcloud compute target-https-proxies update $LB_TARGET_PROXY_NAME --certificate-map="$CERT_MAP_NAME"
  fi
else
  echo "SSL map creation completed without attaching to a load balancer."
fi

echo "Script execution completed."
