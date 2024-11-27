module "base_infrastructure" {
  source      = "git::https://github.com/NanoBlazer915/CST-Scenario-Lab.git//modules/base"
  name_prefix = "Dual-Backend-Failure"
}

module "scenario_infrastructure" {
  source = "git::https://github.com/NanoBlazer915/CST-Scenario-Lab.git//modules/dual-backend-failure"
  name_prefix = "Dual-Backend-Failure"

  subnet_id         = module.base_infrastructure.subnet_id
  private_subnet_id = module.base_infrastructure.private_subnet_id
  security_group_id = module.base_infrastructure.security_group_id
  key_name          = module.base_infrastructure.keypair_name
  random_pet_id     = module.base_infrastructure.random_pet_id
  private_key_pem = module.base_infrastructure.private_key_pem
  other_private_ips = module.base_infrastructure.instance_private_ips
  other_public_ips  = module.base_infrastructure.instance_public_ips
  backend_instance_ids = module.base_infrastructure.instance_ids
  iam_role_name            = module.base_infrastructure.ec2_instance_role_name
  iam_policy_arn           = module.base_infrastructure.describe_instances_policy_arn
  iam_instance_profile_name = module.base_infrastructure.ec2_instance_profile_name




}

