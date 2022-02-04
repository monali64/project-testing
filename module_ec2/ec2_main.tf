## Data - Availaibility Zone Section ##
data "aws_availability_zones" "available" {}

## Data - AMI Section ##
data "aws_ami" "Windows" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["801119661308"]
  #owners = ["212335697154"]
}


## EC2 Instance Creation ##
resource "aws_instance" "ec2_instances_final" {
  count = var.ec2_count
  #ami   = data.aws_ami.Windows.id
  ami                    = var.ami_type
  instance_type          = var.instance_type
  key_name               = var.key_name
 // iam_instance_profile = "${aws_iam_instance_profile.ec2_profilenew.name}"
  vpc_security_group_ids = ["${var.security_group}"]
  subnet_id              = element(var.subnets, count.index)
  user_data              = "${var.userdata == "" ? data.template_file.userdata_win.rendered : var.userdata}"
  //get_password_data      = "true"
  tags = {
    Name               = format("%s_%s", var.ec2_name, count.index + 1)
    CreatedByTerraform = "true"
    Environment        = "dev"
  associate_public_ip_address = "false"
  }
}

## EBS Volume Creation ##
resource "aws_ebs_volume" "ebs_volume_final" {
  count             = var.ebs_count
  availability_zone = aws_instance.ec2_instances_final.*.availability_zone[count.index]
  size              = var.ebs_vol_size
  type              = "gp2"
}

## EBS Volume Attachment - Section ##
resource "aws_volume_attachment" "ebs_vol_attach_final" {
  count        = var.ebs_count
  device_name  = "/dev/xvdh"
  instance_id  = aws_instance.ec2_instances_final.*.id[count.index]
  volume_id    = aws_ebs_volume.ebs_volume_final.*.id[count.index]
  force_detach = true
}

## User Data Creation ##


data "template_file" "userdata_win" {
  template = <<EOF
<powershell>
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi
Initialize-AWSDefaultConfiguration -Accesskey AKIATC4BRTUBMRGCNY43 -Secretkey 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 -Region eu-west-1
Copy-S3Object -BucketName test-bucket-june-18-2021 -KeyPrefix CoreAuth_Configuration -LocalFolder C:/
& "C:/master.ps1"
</powershell>
<persist>false</persist>
EOF
}

