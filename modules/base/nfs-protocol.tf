resource "aws_instance" "nfs_protocol" {
  count = var.nfs_protocol ? var.instance_count : 0

  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  associate_public_ip_address = false
  vpc_security_group_ids      = [var.security_group_id]
  key_name                    = aws_key_pair.autodestroy_keypair.key_name

  user_data = <<-EOF
    #!/bin/bash
    # Run SMB-specific container setup script
    sudo /tmp/smb-container-setup.sh
  EOF

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
    Name        = "${var.name_prefix}-smb-backend-${count.index + 1}"
    "AutoDestroy" = "true"
    Lab = "CST-Scenario-lab"
  }
}
