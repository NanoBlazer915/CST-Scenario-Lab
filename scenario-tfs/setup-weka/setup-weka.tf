provider "aws" {
  region = "us-east-1" 
  }

module "scenario_infrastructure" {
  source      = "git::https://github.com/NanoBlazer915/CST-Scenario-Lab.git//modules/setup-weka"
  name_prefix = "Setup-Weka"

