module "base_infrastructure" {
  source      = "git::https://github.com/NanoBlazer915/CST-Scenario-Lab.git//modules/base"
  name_prefix = "Setup-Weka"
}

module "scenario_infrastructure" {
  source      = "git::https://github.com/NanoBlazer915/CST-Scenario-Lab.git//modules/setup-weka"
  name_prefix = "Weka-Installed"
}
