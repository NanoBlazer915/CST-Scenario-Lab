output "public_ips" {
  value = [for instance in aws_instance.cst_scenario_primary : instance.public_ip]
}

resource "local_file" "scenario_public_ip" {
  content  = join("\n", [for instance in aws_instance.cst_scenario_primary : instance.public_ip])
  filename = "scenario_public_ip.txt"
}

