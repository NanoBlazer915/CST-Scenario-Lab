#!/bin/bash

cd /root || exit

# Save the PEM key to a file
echo "${private_key_pem}" > /root/${key_name}.pem
chmod 600 /root/${key_name}.pem
chown ec2-user:ec2-user /root/${key_name}.pem

# Install AWS CLI and jq
sudo yum install -y aws-cli jq

# Retrieve the instance's own region
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
echo "Region: $REGION"  # Debugging: Print the region

# Use the full name prefix passed from Terraform
NAME_PREFIX="${NAME_PREFIX}"
WEKA_VERSION="${WEKA_VERSION}"

# Use AWS CLI to describe instances with the specific Name prefix
INSTANCE_INFO=$(aws ec2 describe-instances \
  --region "$REGION" \
  --filters "Name=tag:Name,Values=${NAME_PREFIX}-*" \
  --query "Reservations[].Instances[].{PrivateIp:PrivateIpAddress, PublicIp:PublicIpAddress}" \
  --output json)

# Use jq to extract only valid private and public IPs
PRIVATE_IPS=$(echo "$INSTANCE_INFO" | jq -r '.[] | select(.PrivateIp != null) | .PrivateIp')
PUBLIC_IPS=$(echo "$INSTANCE_INFO" | jq -r '.[] | select(.PublicIp != null) | .PublicIp')

echo "$PRIVATE_IPS" > /root/private-backends.txt
echo "$PUBLIC_IPS" > /root/public-backends.txt
echo "$NAME_PREFIX" > /root/instance-name.txt
echo "$WEKA_VERSION" > /root/weka-version.txt

################################################################################################
################################################################################################
################################################################################################
########################DO NOT CHANGE ABOVE####################################################
################################################################################################
################################################################################################
################################################################################################

for ip in $(cat public-backends.txt); do
  ssh-keyscan -H "$ip" >> ~/.ssh/known_hosts
done

for ip in $(cat private-backends.txt); do
  ssh-keyscan -H "$ip" >> ~/.ssh/known_hosts
done

# Install additional packages and perform Weka setup
sudo amazon-linux-extras install epel -y
sudo yum update -y
sudo yum install git pdsh -y

# Download and extract Weka
curl -LO https://adne06LKcE5bqkGa@get.weka.io/dist/v1/pkg/weka-$(cat weka-version.txt).tar
tar xvf weka-$(cat weka-version.txt).tar
cd weka-$(cat weka-version.txt)
sudo ./install.sh
cd ..

# Set PDSH SSH arguments
export PDSH_SSH_ARGS="-i $(\pwd|ls *.pem) -o StrictHostKeyChecking=no"

# Install Weka on backend nodes
while IFS= read -r ip || [ -n "$ip" ]; do
  echo "Running installation for $ip"

  # Run the SSH command and redirect stdin from /dev/null
  ssh -o StrictHostKeyChecking=no -i ./*.pem ec2-user@$ip \
    "sudo curl -s http://$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4):14000/dist/v1/install | sudo sh" < /dev/null

  # Check if the command was successful
  if [ $? -eq 0 ]; then
    echo "Installation succeeded for $ip"
  else
    echo "Installation failed for $ip"
  fi

  # Sleep for 1 second before moving to the next IP
  sleep 3
done < /root/private-backends.txt

# Set and configure Weka version
pdsh -R ssh -l ec2-user -w ^public-backends.txt "sudo weka version get $(cat weka-version.txt)"
pdsh -R ssh -l ec2-user -w ^public-backends.txt "sudo weka version set $(cat weka-version.txt)"

# Stop and remove the default Weka setup
pdsh -R ssh -l ec2-user -w ^public-backends.txt "sudo weka local stop default"
pdsh -R ssh -l ec2-user -w ^public-backends.txt "sudo weka local rm default -f"

# Download the container-creation script from S3

echo "Decoding and executing base64 command..."
echo "IyEvYmluL2Jhc2gKCiMgUmVhZCB0aGUgcHJpdmF0ZS1iYWNrZW5kcy50eHQgZmlsZSBhbmQgY29uc3RydWN0IHRoZSBqb2luaXBzIHZhcmlhYmxlCmpvaW5pcHM9JChwYXN0ZSAtc2QsIC90bXAvcHJpdmF0ZS1iYWNrZW5kcy50eHQpCgojIFRoaXMgZnVuY3Rpb24gcmV0dXJucyBOSUMgaW5mbyBpbiBmb3JtYXQgZGV2L2lwL21hc2svZ3cKIyBGb3IgZXhhbXBsZTogImV0aDEvMTcyLjMxLjg5Ljc5LzIwLzE3Mi4zMS44MC4xIgojIElmIHRoZXJlIGlzIG1vcmUgdGhhbiBvbmUgTklDIHBhc3NlZCwgaXQgcmV0dXJucyBhIGNvbW1hLXNlcGFyYXRlZCBsaXN0CmZ1bmN0aW9uIGZ1bmNfbmljbmV0KCkgewogICAgbG9jYWwgbmljcz0kQAogICAgZm9yIG5pYyBpbiAke25pY3N9OyBkbwogICAgICAgIGxvY2FsIGlwbWFzaz0kKHN1ZG8gaXAgLTQgYWRkciBzaG93IGRldiAke25pY30gfCBncmVwIC1vUCAnKD88PWluZXRccylcZCsoXC5cZCspezN9L1xkKycpCiAgICAgICAgbG9jYWwgZ3c9JChpcCAtNCByb3V0ZSBsaXN0IGRldiAke25pY30gZGVmYXVsdCB8IGF3ayAne3ByaW50ICQzfScpCiAgICAgICAgZWNobyAiJHtuaWN9LyR7aXBtYXNrfS8ke2d3fSIKICAgIGRvbmUgfCBwYXN0ZSAtcyAtZCIsIgp9CgojIFNldCB0aGUgbWFuYWdlbWVudCBJUCAodXN1YWxseSBldGgwKQptZ210aXA9JChlY2hvICQoZnVuY19uaWNuZXQgZXRoMCkgfCBhd2sgLUYvICd7cHJpbnQgJDJ9JykKCiMgRGVmaW5lIHRoZSByb2xlIG9mIGVhY2ggTklDIG9uIHRoZSBpbnN0YW5jZQojIE9uZSBOSUMgcGVyIERSSVZFIGNvcmUKZHJpdm5ldD0kKGZ1bmNfbmljbmV0IGV0aDEpCiMgT25lIE5JQyBwZXIgQ09NUFVURSBjb3JlCmNvbXBuZXQ9JChmdW5jX25pY25ldCBldGgyIGV0aDMpCgojIENvbmZpZ3VyZSBsb2NhbCBkcml2ZXMwIGNvbnRhaW5lcgpzdWRvIHdla2EgbG9jYWwgc2V0dXAgY29udGFpbmVyIC0tZmFpbHVyZS1kb21haW4gJChob3N0bmFtZSAtcykgLS1uYW1lIGRyaXZlczAgLS1vbmx5LWRyaXZlcy1jb3JlcyAtLWJhc2UtcG9ydCAxNDAwMCAtLW5ldCAkZHJpdm5ldCAtLW1hbmFnZW1lbnQtaXBzICR7bWdtdGlwfSAtLWpvaW4taXBzICR7am9pbmlwc30gLS1jb3JlcyAxIC0tY29yZS1pZHMgMSAtLW1lbW9yeSA0R0IKCiMgQ29uZmlndXJlIGxvY2FsIGNvbXB1dGUwIGNvbnRhaW5lcgpzdWRvIHdla2EgbG9jYWwgc2V0dXAgY29udGFpbmVyIC0tZmFpbHVyZS1kb21haW4gJChob3N0bmFtZSAtcykgLS1uYW1lIGNvbXB1dGUwIC0tb25seS1jb21wdXRlLWNvcmVzIC0tYmFzZS1wb3J0IDE1MDAwIC0tbmV0ICRjb21wbmV0IC0tbWFuYWdlbWVudC1pcHMgJHttZ210aXB9IC0tam9pbi1pcHMgJHtqb2luaXBzfSAtLWNvcmVzIDIgLS1jb3JlLWlkcyAyLDMgLS1tZW1vcnkgOEdCCg==" | base64 --decode > container-creation.sh

# Copy files to backend nodes
while IFS= read -r host || [ -n "$host" ]; do
  rsync -avz -e "ssh -i $(\pwd|ls *.pem)" ./private-backends.txt ./container-creation.sh ec2-user@$host:/tmp
done < public-backends.txt

# Run the container creation script on backend nodes
pdsh -R ssh -l ec2-user -w ^public-backends.txt "cd /tmp && sudo chmod +x container-creation.sh && sudo /tmp/container-creation.sh"

# Create and configure the Weka cluster
weka cluster create $(\cat private-backends.txt|xargs)
sleep 30
weka debug config override clusterInfo.nvmeEnabled false
weka cluster hot-spare 1 && weka cluster update --data-drives 4 --parity-drives 2 && weka cluster update --cluster-name $(cat instance-name.txt)

# Add drives to Weka cluster and start IO
for i in {0..5}; do weka cluster drive add $i /dev/nvme1n1; done
weka cluster start-io

sleep 10

weka fs group create default
weka fs create default default 1TiB

# Check Weka status
WEKA_STATUS=$(weka status)
echo "$WEKA_STATUS"

# Verify if the status is "OK"
if echo "$WEKA_STATUS" | grep -q "status: OK"; then
  echo "Weka setup completed successfully!"
  exit 0
else
  echo "Weka setup failed. Status not OK."
  exit 1
fi
