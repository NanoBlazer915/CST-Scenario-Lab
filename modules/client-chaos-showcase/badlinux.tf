# Define the EC2 instances
resource "aws_instance" "bad_os"{
  ami                         = "ami-04552bb4f4dd38925"
  instance_type               = var.client_instance_type
 # count                       = 1
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.security_group_id]
  key_name                    = var.key_name

  # User data script for client connection
  user_data = templatefile("${path.module}/scripts/bados.sh.tpl", {
     NAME_PREFIX     = "${var.name_prefix}-${var.random_pet_id}"# 

    # Add variables here as needed for the script
  })

  # Attach the IAM instance profile for permissions
  iam_instance_profile = var.iam_instance_profile_name

  # Define the root block device
  root_block_device {
    volume_type           = "gp2"
    volume_size           = 50
    delete_on_termination = true
  }

  # Tags for the instance
  tags = {
    Name        = "client-badOS-${var.name_prefix}-${var.random_pet_id}"
    "AutoDestroy" = "true"
    Lab         = "CST-Scenario-lab"
  }
}

# Additional network interfaces for the client
resource "aws_network_interface" "clientbados_private_nic1" {
#  count            = 1
  subnet_id        = var.private_subnet_id
  security_groups  = [var.security_group_id]
  description      = "Private NIC 1"
}

# Attach the network interfaces to the EC2 instances
resource "aws_network_interface_attachment" "clientbados_nic1_attachment" {
#  count                = 1
  instance_id          = aws_instance.bad_os.id
  network_interface_id = aws_network_interface.clientbados_private_nic1.id
  device_index         = 1
}
