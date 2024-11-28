#!/bin/bash

sudo systemctl stop update-motd
sudo systemctl disable update-motd

echo "======================================================" > /etc/motd
echo "        _____" >> /etc/motd
echo "     _.'_____`._" >> /etc/motd
echo "   .'.-'  12 \`-.`." >> /etc/motd
echo "  /,' 11      1 \`.\\" >> /etc/motd
echo " // 10      /   2 \\\\" >> /etc/motd
echo ";;         /       ::" >> /etc/motd
echo "|| 9  ----O      3 ||" >> /etc/motd
echo "::                 ;;" >> /etc/motd
echo " \\\\ 8           4 //" >> /etc/motd
echo "  \`\\. 7       5 ,'/ " >> /etc/motd
echo "   '.\`-.__6__.-'.'" >> /etc/motd
echo "    ((-._____.-))" >> /etc/motd
echo "    _))       ((_ " >> /etc/motd
echo "   '--'SSt    '--'" >> /etc/motd
echo "=========================" >> /etc/motd
echo "==Welcome to a bad time==" >> /etc/motd
echo "=========================" >> /etc/motd
echo "Try to mount and see what happens" >> /etc/motd

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

# Mount the Weka filesystem
#sudo mkdir -p /mnt/weka
#sudo mount -t wekafs "$(cat /root/filtered-backend-ips.txt|tr '\n' ',' | sed 's/,$//')/default" /mnt/weka

# Define retry settings for mounting
RETRY_DELAY=60  # Time to wait between retries (in seconds)
MAX_RETRIES=15  # Maximum number of retries for mounting

# Create a comma-separated list of backend IPs
BACKEND_IPS=$(cat /root/filtered-backend-ips.txt | tr '\n' ',' | sed 's/,$//')

mkdir /mnt/weka
sudo timedatectl set-ntp false
sudo date -s "2024-01-01 00:00:00"


echo "Things to fix it" >> /opt/answers.txt
echo "sudo timedatectl set-ntp true" >> /opt/answers.txt
echo "sudo systemctl enable chronyd" >> /opt/answers.txt
echo "sudo systemctl start chronyd" >> /opt/answers.txt
