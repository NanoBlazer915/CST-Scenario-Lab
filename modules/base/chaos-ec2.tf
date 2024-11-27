# Define the EC2 instance
resource "aws_instance" "cst_chaos_primary" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  count                       = var.chaos_applied ? 0 : 1
#  count                       = 1  # Only one instance
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.security_group_id]
  key_name                    = aws_key_pair.autodestroy_keypair.key_name

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name


  user_data = templatefile("${path.module}/scripts/backend-build.sh.tpl", {
    private_key_pem = tls_private_key.autodestroy_key.private_key_pem
    key_name        = aws_key_pair.autodestroy_keypair.key_name
    NAME_PREFIX     = "${var.name_prefix}-${random_pet.fun-name.id}"# Pass the generated pet name
    WEKA_VERSION    = var.weka_version

  })

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 50
    delete_on_termination = true
  }

  ebs_block_device {
    device_name           = "/dev/xvdb"
    volume_type           = "gp2"
    volume_size           = 500
    delete_on_termination = true
  }

  tags = {
    Name        = "${var.name_prefix}-${random_pet.fun-name.id}-1"
    "AutoDestroy" = "true"
    Lab = "CST-Scenario-lab"
  }
}

# Additional network interfaces (one per NIC)
resource "aws_network_interface" "chaos_private_nic1" {
  
  count                       = var.chaos_applied ? 1 : 0
  subnet_id        = var.private_subnet_id
  security_groups  = [var.security_group_id]
  description      = "Private NIC 1"
}

resource "aws_network_interface" "chaos_private_nic2" {
  count                       = var.chaos_applied ? 1 : 0
  subnet_id        = var.private_subnet_id
  security_groups  = [var.security_group_id]
  description      = "Private NIC 2"
}

resource "aws_network_interface" "chaos_private_nic3" {
  count                       = var.chaos_applied ? 1 : 0
  subnet_id        = var.private_subnet_id
  security_groups  = [var.security_group_id]
  description      = "Private NIC 3"
}

# Attach network interfaces
resource "aws_network_interface_attachment" "chaos_nic1_attachment" {
  count                       = var.chaos_applied ? 1 : 0
  instance_id          = aws_instance.cst_chaos_primary[count.index].id
  network_interface_id = aws_network_interface.chaos_private_nic1[count.index].id
  device_index         = 1
}

resource "aws_network_interface_attachment" "chaos_nic2_attachment" {
  count                       = var.chaos_applied ? 1 : 0
  instance_id          = aws_instance.cst_chaos_primary[count.index].id
  network_interface_id = aws_network_interface.chaos_private_nic2[count.index].id
  device_index         = 2
}

resource "aws_network_interface_attachment" "chaos_nic3_attachment" {
  count                       = var.chaos_applied ? 1 : 0
  instance_id          = aws_instance.cst_chaos_primary[count.index].id
  network_interface_id = aws_network_interface.chaos_private_nic3[count.index].id
  device_index         = 3
}
