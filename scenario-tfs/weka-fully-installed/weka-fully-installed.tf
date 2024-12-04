module "base_infrastructure" {
  source      = "git::https://github.com/NanoBlazer915/CST-Scenario-Lab.git//modules/base"
  name_prefix = "Basic-Weka"
  chaos_applied = false 

}
