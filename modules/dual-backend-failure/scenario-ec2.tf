# Define the EC2 instance
resource "aws_instance" "cst_scenario_specialty" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
#  count                       = 1
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.security_group_id]
  key_name                    = var.key_name

  # Attach the IAM instance profile
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile_special.name


  # Use the template file for user data
  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    private_key_pem = var.private_key_pem
    key_name        = var.key_name
    NAME_PREFIX     = "${var.name_prefix}-${var.random_pet_id}"# Pass the generated pet name
    WEKA_VERSION    = var.weka_version
    instance_ids = join(" ", slice(var.backend_instance_ids, 0, 2))  
    region       = var.aws_region                                   
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
    Name         = "${var.name_prefix}-${var.random_pet_id}-1"
    "AutoDestroy" = "true"
    Lab          = "CST-Scenario-lab"
  }
}

# Additional network interfaces (one per NIC)
resource "aws_network_interface" "private_nic1" {
  subnet_id       = var.private_subnet_id
  security_groups = [var.security_group_id]
  description     = "Private NIC 1"
}

resource "aws_network_interface" "private_nic2" {
  subnet_id       = var.private_subnet_id
  security_groups = [var.security_group_id]
  description     = "Private NIC 2"
}

resource "aws_network_interface" "private_nic3" {
  subnet_id       = var.private_subnet_id
  security_groups = [var.security_group_id]
  description     = "Private NIC 3"
}

# Attach network interfaces
resource "aws_network_interface_attachment" "nic1_attachment" {
  instance_id          = aws_instance.cst_scenario_specialty.id
  network_interface_id = aws_network_interface.private_nic1.id
  device_index         = 1
}

resource "aws_network_interface_attachment" "nic2_attachment" {
  instance_id          = aws_instance.cst_scenario_specialty.id
  network_interface_id = aws_network_interface.private_nic2.id
  device_index         = 2
}

resource "aws_network_interface_attachment" "nic3_attachment" {
  instance_id          = aws_instance.cst_scenario_specialty.id
  network_interface_id = aws_network_interface.private_nic3.id
  device_index         = 3
}

output "scenario_handler_public_ip" {
  value = aws_instance.cst_scenario_specialty.private_ip
}

variable "backend_instance_ids" {
  description = "List of backend instance IDs"
  type        = list(string)
}

# # Use the backend_instance_ids variable passed from main.tf
# output "instance_ids" {
#   value = var.backend_instance_ids
# }
# 
# # Use the instance IDs for destruction
# locals {
#   instances_to_destroy = slice(var.backend_instance_ids, 0, 2)
# }
# 
# # Use a null_resource to run a local-exec provisioner to terminate instances
# resource "null_resource" "delayed_destruction" {
#   provisioner "local-exec" {
#     command = "sleep 460 && aws ec2 stop-instances --instance-ids ${join(" ", local.instances_to_destroy)}"
#   }
# 
#   # Ensure the provisioner waits until everything is ready
#   depends_on = [var.backend_instance_ids]
# }
