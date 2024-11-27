resource "null_resource" "important_message" {
  triggers = {
    always_run = timestamp() # Forces re-execution every time `terraform apply` runs
  }

  provisioner "local-exec" {
    command = <<EOT
echo -e "\033[1;31m==========================================================\033[0m"
echo -e "\033[1;33m                   IMPORTANT NOTICE\033[0m"
echo -e "\033[1;31m==========================================================\033[0m"
echo -e "\033[1;32mbadlinux = Debian\033[0m"
echo -e "\033[1;34mDebian username = admin\033[0m"
echo -e "\033[1;36m_______________________\033[0m"
echo -e "\033[1;35mmtu = May rename so it's not so obviously mtu\033[0m"
echo -e "\033[1;35mnuma = can I even set numa regions in these aws's maybe need a crazy big instance\033[0m"
echo -e "\033[1;35mtime sync should be easy enough\033[0m"
echo -e "\033[1;35mmemory should be easy enough\033[0m"
echo -e "\033[1;31m==========================================================\033[0m"
EOT
  }
}
