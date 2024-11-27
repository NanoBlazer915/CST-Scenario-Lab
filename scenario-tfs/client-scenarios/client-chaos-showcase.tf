provider "aws" {
  region = "us-east-1" 
  }

module "base_infrastructure" {
  source      = "/Users/jake/terraform/CST-Scenario-Lab/modules/base"
  name_prefix = "LinuxOS-Kernel"
  chaos_applied = false
}

module "scenario_infrastructure" {
  source      = "/Users/jake/terraform/CST-Scenario-Lab/modules/client-chaos-showcase"
  name_prefix = "LinuxOS-Kernel"

  subnet_id         = module.base_infrastructure.subnet_id
  private_subnet_id = module.base_infrastructure.private_subnet_id
  security_group_id = module.base_infrastructure.security_group_id
  key_name          = module.base_infrastructure.keypair_name
  random_pet_id     = module.base_infrastructure.random_pet_id
  private_key_pem = module.base_infrastructure.private_key_pem
  other_private_ips = module.base_infrastructure.instance_private_ips
  other_public_ips  = module.base_infrastructure.instance_public_ips
  iam_role_name            = module.base_infrastructure.ec2_instance_role_name
  iam_policy_arn           = module.base_infrastructure.describe_instances_policy_arn
  iam_instance_profile_name = module.base_infrastructure.ec2_instance_profile_name

}
