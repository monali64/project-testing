## Ec2 Instance Output variables ##

output "instance1_id" {
  value = element(aws_instance.ec2_instances_final.*.id, 1)
}

output "instance2_id" {
  value = element(aws_instance.ec2_instances_final.*.id, 2)
}

output "server_ip" {
  value = join(",", aws_instance.ec2_instances_final.*.public_ip)
}

output "instance_id" {
  value = aws_instance.ec2_instances_final.*.id
}
