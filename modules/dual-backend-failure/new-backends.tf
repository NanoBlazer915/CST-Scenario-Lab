# Define the EC2 instances
resource "aws_instance" "cst_scenario_new_backend" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  count                       = var.new_instance_count
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.security_group_id]
  key_name                    = var.key_name

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 50
    delete_on_termination = true
  }

  tags = {
    Name        = "New-${var.name_prefix}-${var.random_pet_id}-${count.index + 1}"
    "AutoDestroy" = "true"
    Lab = "CST-Scenario-lab"
  }
}

# Additional network interfaces
resource "aws_network_interface" "private_new_nic_1" {
  count            = var.new_instance_count
  subnet_id        = var.private_subnet_id
  security_groups  = [var.security_group_id]
  description      = "Private NIC 1"
}

resource "aws_network_interface" "private_new_nic_2" {
  count            = var.new_instance_count
  subnet_id        = var.private_subnet_id
  security_groups  = [var.security_group_id]
  description      = "Private NIC 2"
}

resource "aws_network_interface" "private_new_nic_3" {
  count            = var.new_instance_count
  subnet_id        = var.private_subnet_id
  security_groups  = [var.security_group_id]
  description      = "Private NIC 3"
}

# Attach network interfaces
resource "aws_network_interface_attachment" "nic1_new_attachment" {
  count                = var.new_instance_count
  instance_id          = aws_instance.cst_scenario_new_backend[count.index].id
  network_interface_id = aws_network_interface.private_new_nic_1[count.index].id
  device_index         = 1
}

resource "aws_network_interface_attachment" "nic2_new_attachment" {
  count                = var.new_instance_count
  instance_id          = aws_instance.cst_scenario_new_backend[count.index].id
  network_interface_id = aws_network_interface.private_new_nic_2[count.index].id
  device_index         = 2
}

resource "aws_network_interface_attachment" "nic3_new_attachment" {
  count                = var.new_instance_count
  instance_id          = aws_instance.cst_scenario_new_backend[count.index].id
  network_interface_id = aws_network_interface.private_new_nic_3[count.index].id
  device_index         = 3
}

# Output private IPs and hostnames for external processing
output "host_entries" {
  value = [
    for index, ip in aws_instance.cst_scenario_new_backend : "${ip.private_ip} weka${index + 2}"
  ]
}






####
##########3
###########3
output "new-backend-ips" {
  value = [for instance in aws_instance.cst_scenario_new_backend : instance.public_ip]
}

# Create a file with private IPs
resource "local_file" "new_backend" {
  content  = join("\n", [for instance in aws_instance.cst_scenario_new_backend : instance.private_ip])
  filename = "new-backend-ips.txt"
}

