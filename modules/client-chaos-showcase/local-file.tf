resource "local_file" "bad_os_public_ip" {
  content  = aws_instance.bad_os.public_ip
  filename = "badlinux_chaos_ip.txt"
}

 resource "local_file" "timesync_public_ip" {
   content  = aws_instance.timesync.public_ip
   filename = "timesync_chaos_ip.txt"
 }

 resource "local_file" "memory_public_ip" {
   content  = aws_instance.memory.public_ip
   filename = "memory_chaos_ip.txt"
 }
 resource "local_file" "mtu_public_ip" {
   content  = aws_instance.mtu.public_ip
   filename = "mtu_chaos_ip.txt"
 }
 resource "local_file" "numa_public_ip" {
   content  = aws_instance.numa.public_ip
   filename = "numa_chaos_ip.txt"
 }
