## Web Server Creation Module ##

terraform {
  backend "s3" {

    region = var.region
  }
}

data "aws_vpc" "appvpc" {
  filter {
    name   = "tag:Name"
    values = [var.app_vpc_name]
  }
}

data "aws_subnet_ids" "appsubnets" {
  vpc_id = data.aws_vpc.appvpc.id

  filter {
    name   = "tag:Name"
    values = [var.app_snet_name]
  }
}

data "aws_iam_instance_profile" "ec2profile" {

    name   = "EC2S3profilenew"

}


data "aws_security_groups" "appsg" {
  filter {
    name   = "group-name"
    values = [var.app_sg_name]
  }

  filter {
    name   = "vpc-id"
    values = ["${data.aws_vpc.appvpc.id}"]
  }
}

## Domain Controller Server Creation Module ##
module "ADC_server" {
  source         = "../module_ec2"
  ami_type       = var.ADC_ami_type
  ec2_count      = var.ADC_inst_count_tf
  ebs_count      = var.ebs_count
  instance_type  = var.ADC_inst_type_tf
  ec2_name       = "ADC"
  ebs_vol_size   = var.ADC_ebs_size_tf
  ebs_vol_type   = var.ebs_vol_type
  iam_instance_profile = data.aws_iam_instance_profile.ec2profile.name
  security_group = element(data.aws_security_groups.appsg.ids, 0)
  subnets        = data.aws_subnet_ids.appsubnets.ids
  userdata      = data.template_file.service_ADC_userdata_win.rendered
}


data "template_file" "service_ADC_userdata_win" {
	template = <<EOF
<powershell>

net user Administrator "PassWord@corecard"
Copy-S3Object -BucketName test-bucket-june-18-2021-eu-west1 -KeyPrefix ADDC -LocalFolder C:\PS_automation -Force
Powershell.exe -File C:\PS_automation\Master1.ps1
</powershell>
<persist>false</persist>
EOF
}


