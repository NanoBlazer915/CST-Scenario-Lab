resource "aws_instance" "nfs" {
  count = var.nfs ? var.nfs_instance_count : 0
  ami                         = var.ami_id
  instance_type               = var.client_instance_type
  subnet_id                   = local.subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [local.security_group_id]
  key_name                    = aws_key_pair.autodestroy_keypair.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name



  user_data = templatefile("${path.module}/scripts/nfs.sh.tpl", {
     NAME_PREFIX     = "${var.name_prefix}-${random_pet.fun-name.id}"# Pass the generated pet name
    # Add variables here as needed for the script
  })

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 50
    delete_on_termination = true
  }

  tags = {
    Name        = "${var.name_prefix}-nfs-instance-${count.index + 1}"
    "AutoDestroy" = "true"
    Lab = "CST-Scenario-lab"
  }
}

# Additional network interfaces for the client
resource "aws_network_interface" "nfs_private_nic1" {
  count = var.nfs ? var.nfs_instance_count : 0
  subnet_id        = var.private_subnet_id
  security_groups  = [var.security_group_id]
  description      = "Private NIC 1"
}

# Attach the network interfaces to the EC2 instances
resource "aws_network_interface_attachment" "nfs_nic1_attachment" {
  count = var.nfs ? var.nfs_instance_count : 0
  instance_id          = aws_instance.nfs[count.index].id
  network_interface_id = aws_network_interface.nfs_private_nic1[count.index].id
  device_index         = 1
}

