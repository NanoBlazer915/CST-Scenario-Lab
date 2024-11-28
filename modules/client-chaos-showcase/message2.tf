output "important_notice" {
  value = <<-EOT
    ==========================================================
                       IMPORTANT NOTICE
    ==========================================================
    - badlinux = Debian
    - Debian username = admin
    - mtu: May rename so it's not so obviously mtu
    - numa: Can I even set NUMA regions in these AWS instances? Maybe need a larger instance.
    - Time sync should be easy enough.
    - Memory configuration should be straightforward.
    ==========================================================
  EOT
}
