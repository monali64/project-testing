output "vpc-id" {
 value ="${data.aws_vpc.appvpc.id}"
}

output "security-groups" {
 value = element(data.aws_security_groups.appsg.ids, 0)
}

output "subnets" {
 value ="${data.aws_subnet_ids.appsubnets.ids}"
}