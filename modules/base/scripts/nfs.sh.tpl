#!/bin/bash

# Update packages and install necessary tools
sudo yum update -y
sudo yum install -y awscli jq

# Retrieve the region from the instance metadata and save it to a file
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
if [ -z "$REGION" ]; then
  echo "Error: Unable to determine the AWS region from instance metadata."
  exit 1
fi
echo "Retrieved REGION: $REGION"  # Debugging: Print the region
echo "$REGION" > /root/region.txt

# Save the name prefix passed from Terraform
echo "${NAME_PREFIX}" > /root/name-prefix.txt

# Retrieve backend IPs using AWS CLI and save them to a file
INSTANCE_INFO=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=$(cat /root/name-prefix.txt)-*" \
  --query "Reservations[*].Instances[*].PrivateIpAddress" \
  --output text --region "$(cat /root/region.txt)")

if [ $? -ne 0 ]; then
  echo "Error: Failed to retrieve backend IPs. Check AWS CLI configuration and permissions."
  exit 1
fi

# Save backend IPs to a file
echo "$INSTANCE_INFO" > /root/backend-ips.txt

# Remove the instance's own IP from the backend IPs and save it to a file
LOCAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
echo "$LOCAL_IP" > /root/local-ip.txt

# Read the backend IPs from the file and filter out the local IP
> /root/filtered-backend-ips.txt  # Clear the file or create it if it doesn't exist
while IFS= read -r ip; do
  if [ "$ip" != "$LOCAL_IP" ]; then
    echo "$ip" >> /root/filtered-backend-ips.txt
  fi
done < /root/backend-ips.txt

sleep 480

# Define retry settings
RETRY_DELAY=30  # Time to wait between retries (in seconds)
MAX_RETRIES=10  # Number of retries

# Function to perform Weka installation on a given backend
install_weka() {
  local IP=$1
  echo "Starting Weka installation on backend: $IP"

  for ((i=1; i<=MAX_RETRIES; i++)); do
    sudo curl -k "http://$IP:14000/dist/v1/install" -o wekainstall.sh
    sudo chmod +x wekainstall.sh
    sudo ./wekainstall.sh
    if [ $? -eq 0 ]; then
      echo "Weka installation succeeded on $IP"
      return 0
    else
      echo "Weka installation failed on $IP, attempt $i. Retrying in $RETRY_DELAY seconds..."
      sleep $RETRY_DELAY
    fi
  done

  echo "Weka installation failed on $IP after $MAX_RETRIES attempts."
  return 1
}

# Loop through each backend IP and attempt to install Weka with retries
for IP in $(cat /root/filtered-backend-ips.txt); do
  install_weka $IP
done



echo "IyEvYmluL2Jhc2ggLWUKIyBTZXQgYSBjb21tYS1zZXBhcmF0ZWQgbGlzdCBvZiB0aGUgbWFuYWdlbWVudCBJUHMgb2YgYWxsIHRoZSBiYWNrZW5kcwpqb2luaXBzPSQocGFzdGUgLXNkLCAvcm9vdC9iYWNrZW5kLWlwcy50eHQpCgojIEZ1bmN0aW9uIHJldHVybnMgTklDIGluZm8gaW4gZm9ybWF0IGRldi9pcC9tYXNrL2d3CiMgRm9yIGV4YW1wbGU6ICJldGgxLzE3Mi4zMS44OS43OS8yMC8xNzIuMzEuODAuMSIKIyBJZiB0aGVyZSBpcyBtb3JlIHRoYW4gb25lIE5JQyBwYXNzZWQsIGl0IHJldHVybnMgYSBjb21tYS1zZXBhcmF0ZWQgbGlzdApmdW5jdGlvbiBmdW5jX25pY25ldCgpIHsKICAgICAgICBsb2NhbCBuaWNzPSRACiAgICAgICAgZm9yIG5pYyBpbiAke25pY3N9OyBkbwogICAgICAgICAgICAgICAgbG9jYWwgaXBtYXNrPSQoc3VkbyBpcCAtNCBhZGRyIHNob3cgZGV2ICR7bmljfSB8IGhlYWQgLTIgfCB0YWlsIC0xIHwgYXdrICd7cHJpbnQgJDJ9JykKICAgICAgICAgICAgICAgIGxvY2FsIGd3PSQoaXAgLTQgcm91dGUgfCBoZWFkIC0xIHwgYXdrICd7cHJpbnQgJDN9JykKICAgICAgICAgICAgICAgIGVjaG8gIiR7bmljfS8ke2lwbWFza30vJHtnd30iCiAgICAgICAgZG9uZSB8IHBhc3RlIC1zIC1kIiwiCn0KCiMgRGVmaW5lIHRoZSByb2xlIG9mIGVhY2ggTklDIG9uIHRoZSBpbnN0YW5jZQptZ210aXA9JChlY2hvICQoZnVuY19uaWNuZXQgZXRoMCkgfCBhd2sgLUYvICd7cHJpbnQgJDJ9JykKY2xpZW50bmV0PSQoZnVuY19uaWNuZXQgZXRoMSkKCiMgQ29uZmlndXJlIHByb3Rvbm9kZSBjb250YWluZXIKc3VkbyB3ZWthIGxvY2FsIHNldHVwIGNvbnRhaW5lciAtLWZhaWx1cmUtZG9tYWluICQoaG9zdG5hbWUgLXMpIC0tbmFtZSBwcm90b2ZlMCAtLW9ubHktZnJvbnRlbmQtY29yZXMgLS1hbGxvdy1wcm90b2NvbHMgdHJ1ZSAtLWJhc2UtcG9ydCAxNDAwMCAtLW5ldCAkY2xpZW50bmV0IC0tbWFuYWdlbWVudC1pcHMgJHttZ210aXB9IC0tam9pbi1pcHMgJHtqb2luaXBzfSAtLWNvcmVzIDEgLS1jb3JlLWlkcyAxIC0tbWVtb3J5IDJHQgo=" |base64 --decode |bash

