# VPC-webserver Creation Module#
module "vpc_webserver" {
  source              = "./module_VPC-Public"
  vpc_cidr_block      = "10.0.0.0/24"
  public_cidrs1       = ["10.0.0.0/26", "10.0.0.64/26"]
  public_cidrs2       = ["10.0.0.128/26", "10.0.0.192/26"]
  vpc_name            = "Webserver_VPC"
  public_subnet1_name = "Webserver_Public_Subnet"
  public_subnet2_name = "BastionHost_Public_Subnet"
  sg_name1            = "Webserver_sg"
  sg_name2            = "BastionHost_sg"
  gateway_id          = module.IGW_webserver.ig_id
}

module "IGW_webserver" {
  source   = "./module_IGW"
  vpc_id   = module.vpc_webserver.vpc_id
  igw_name = "Webserver_IGW"
}

## Web Server Creation Module ##
module "web_server" {
  source         = "./module_ec2"
  ami_type       = var.web_ami_type
  ec2_count      = var.web_inst_count_tf
  ebs_count      = var.web_inst_count_tf
  instance_type  = var.web_inst_type_tf
  ec2_name       = "Webserver"
  ebs_vol_size   = var.web_ebs_size_tf
  security_group = module.vpc_webserver.security_group
  subnets        = module.vpc_webserver.public_subnets
}

# Bastion Host Creation ##
module "bastion_host" {
  source         = "./Bastion-host"
  ami_type       = var.bastion_ami_type
  b_host_count   = var.b_host_count_tf
  instance_type  = var.b_host_type_tf
  security_group = module.vpc_webserver.security_group
  subnets        = module.vpc_webserver.public_subnets
  b_host_name    = "JumpServer"
}

## webserver loadbalancer Configuration ##
module "nlb" {
  source         = "./nlb"
  vpc_id         = module.vpc_webserver.vpc_id
  inst_id        = module.web_server.instance_id
  web_inst_count = var.web_inst_count_tf
  subnet1        = module.vpc_webserver.subnet1
  subnet2        = module.vpc_webserver.subnet2
}

# VPC-appserver Creation Module#
/*
module "vpc_appserver" {
  source              = "./module_VPC-Private"
  vpc_cidr_block      = "10.1.0.0/24"
  private_cidrs       = ["10.1.0.128/26", "10.1.0.192/26"]
  vpc_name            = "Appserver_VPC"
  private_subnet_name = "Appserver_Private_Sunbet"
  sg_name             = "Appserver_sg"
}

## CoreAuth Server Creation Module ##
module "Auth_server" {
  source         = "./module_ec2"
  ami_type       = var.Auth_ami_type
  ec2_count      = var.Auth_inst_count_tf
  ebs_count      = var.Auth_inst_count_tf
  instance_type  = var.Auth_inst_type_tf
  ec2_name       = "Auth"
  ebs_vol_size   = var.Auth_ebs_size_tf
  security_group = module.vpc_appserver.security_group
  subnets        = module.vpc_appserver.private_subnets
}

## CoreIssue Server Creation Module ##
module "ISSU_server" {
  source         = "./module_ec2"
  ami_type       = var.ISSU_ami_type
  ec2_count      = var.ISSU_inst_count_tf
  ebs_count      = var.ISSU_inst_count_tf
  instance_type  = var.ISSU_inst_type_tf
  ec2_name       = "ISSU"
  ebs_vol_size   = var.ISSU_ebs_size_tf
  security_group = module.vpc_appserver.security_group
  subnets        = module.vpc_appserver.private_subnets
}

## TNP Server Creation Module ##
module "TNP_server" {
  source         = "./module_ec2"
  ami_type       = var.TNP_ami_type
  ec2_count      = var.TNP_inst_count_tf
  ebs_count      = var.TNP_inst_count_tf
  instance_type  = var.TNP_inst_type_tf
  ec2_name       = "TNP"
  ebs_vol_size   = var.TNP_ebs_size_tf
  security_group = module.vpc_appserver.security_group
  subnets        = module.vpc_appserver.private_subnets
}

## Services AppServer - SVCE Server Creation Module ##
module "SVCE_server" {
  source         = "./module_ec2"
  ami_type       = var.SVCE_ami_type
  ec2_count      = var.SVCE_inst_count_tf
  ebs_count      = var.SVCE_inst_count_tf
  instance_type  = var.SVCE_inst_type_tf
  ec2_name       = "SVCE"
  ebs_vol_size   = var.SVCE_ebs_size_tf
  security_group = module.vpc_appserver.security_group
  subnets        = module.vpc_appserver.private_subnets
}

## WKF- Workflow Server Creation Module ##
module "WKF_server" {
  source         = "./module_ec2"
  ami_type       = var.WKF_ami_type
  ec2_count      = var.WKF_inst_count_tf
  ebs_count      = var.WKF_inst_count_tf
  instance_type  = var.WKF_inst_type_tf
  ec2_name       = "WKF"
  ebs_vol_size   = var.WKF_ebs_size_tf
  security_group = module.vpc_appserver.security_group
  subnets        = module.vpc_appserver.private_subnets
}

# File Processing Workflow Server Creation Module ##
module "BAT_server" {
  source         = "./module_ec2"
  ami_type       = var.BAT_ami_type
  ec2_count      = var.BAT_inst_count_tf
  ebs_count      = var.BAT_inst_count_tf
  instance_type  = var.BAT_inst_type_tf
  ec2_name       = "BAT"
  ebs_vol_size   = var.BAT_ebs_size_tf
  security_group = module.vpc_appserver.security_group
  subnets        = module.vpc_appserver.private_subnets
}

# ## WCF Server Creation Module ##
module "WCF_server" {
  source         = "./module_ec2"
  ami_type       = var.WCF_ami_type
  ec2_count      = var.WCF_inst_count_tf
  ebs_count      = var.WCF_inst_count_tf
  instance_type  = var.WCF_inst_type_tf
  ec2_name       = "WCF"
  # ebs_vol_size   = var.WCF_ebs_size_tf
  security_group = module.vpc_appserver.security_group
  subnets        = module.vpc_appserver.private_subnets
}

## Report Server(SSRS/RPTS) & Report Delivery(RPTD) Server Creation Module ##
module "RPTD_server" {
  source         = "./module_ec2"
  ami_type       = var.RPTD_ami_type
  ec2_count      = var.RPTD_inst_count_tf
  ebs_count      = var.RPTD_inst_count_tf
  instance_type  = var.RPTD_inst_type_tf
  ec2_name       = "RPTD"
  ebs_vol_size   = var.RPTD_ebs_size_tf
  security_group = module.vpc_appserver.security_group
  subnets        = module.vpc_appserver.private_subnets
}

## Domain Controller Server Creation Module ##
module "DC_server" {
  source         = "./module_ec2"
  ami_type       = var.DC_ami_type
  ec2_count      = var.DC_inst_count_tf
  ebs_count      = var.DC_inst_count_tf
  instance_type  = var.DC_inst_type_tf
  ec2_name       = "DC"
  ebs_vol_size   = var.DC_ebs_size_tf
  security_group = module.vpc_appserver.security_group
  subnets        = module.vpc_appserver.private_subnets
}


*/
/*
## VPC-KMS Creation Module ##
module "vpc_kms" {
  source              = "./module_VPC-Private"
  vpc_cidr_block      = "10.2.0.0/24"
  private_cidrs       = ["10.2.0.128/26", "10.2.0.192/26"]
  vpc_name            = "KMS_VPC"
  private_subnet_name = "KMS_Private_Sunbet"
  sg_name             = "KMS_sg"
}

## KMS Server Creation Module ##
module "kms_server" {
  source         = "./module_ec2"
  ami_type       = var.KMS_ami_type
  ec2_count      = var.KMS_inst_count_tf
  ebs_count      = var.KMS_inst_count_tf
  instance_type  = var.KMS_inst_type_tf
  ec2_name       = "KMS"
  ebs_vol_size   = var.KMS_ebs_size_tf
  security_group = module.vpc_kms.security_group
  subnets        = module.vpc_kms.private_subnets
}


module "vpc_db" {
  source              = "./module_VPC-Private"
  vpc_cidr_block      = "10.3.0.0/24"
  private_cidrs       = ["10.3.0.128/26", "10.3.0.192/26"]
  vpc_name            = "DB_VPC"
  private_subnet_name = "DB_Private_Sunbet"
  sg_name             = "DB_sg"
}

## DB Server Creation Module ##
module "db_server" {
  source         = "./module_ec2"
  ami_type       = var.DB_ami_type
  ec2_count      = var.DB_inst_count_tf
  ebs_count      = var.DB_inst_count_tf
  instance_type  = var.DB_inst_type_tf
  ec2_name       = "primary_db"
  ebs_vol_size   = var.DB_ebs_size_tf
  security_group = module.vpc_db.security_group
  subnets        = module.vpc_db.private_subnets
}

## Replication DB Server Creation Module ##
module "rpl_db_server" {
  source         = "./module_ec2"
  ami_type       = var.RPLDB_ami_type
  ec2_count      = var.RPLDB_inst_count_tf
  ebs_count      = var.RPLDB_inst_count_tf
  instance_type  = var.RPLDB_inst_type_tf
  ec2_name       = "db"
  ebs_vol_size   = var.RPLDB_ebs_size_tf
  security_group = module.vpc_db.security_group
  subnets        = module.vpc_db.private_subnets
}

## Distribution DB Server Creation Module ##
module "dist_db_server" {
  source         = "./module_ec2"
  ami_type       = var.DIST_DB_ami_type
  ec2_count      = var.DIST_DB_inst_count_tf
  ebs_count      = var.DIST_DB_inst_count_tf
  instance_type  = var.DIST_DB_inst_type_tf
  ec2_name       = "db"
  ebs_vol_size   = var.DIST_DB_ebs_size_tf
  security_group = module.vpc_db.security_group
  subnets        = module.vpc_db.private_subnets
}

*/

#VPC Peering vpc_webserver<->vpc_appserver
module "peer_vpc_webserver_appserver" {
  source           = "./module_VPC-Peering"
  peer_owner_id    = "212335697154"
  peer_vpc_id      = module.vpc_appserver.vpc_id
  local_vpc_id     = module.vpc_webserver.vpc_id
  peer_region      = var.region
  vpc_peering_name = "peering_vpc_webserver_appserver"
}

module "peer_vpc_webserver_kmsserver" {
  source           = "./module_VPC-Peering"
  peer_owner_id    = "212335697154"
  peer_vpc_id      = module.vpc_kms.vpc_id
  local_vpc_id     = module.vpc_webserver.vpc_id
  peer_region      = var.region
  vpc_peering_name = "peering_vpc_webserver_appserver"
}

module "peer_vpc_webserver_databaseserver" {
  source           = "./module_VPC-Peering"
  peer_owner_id    = "212335697154"
  peer_vpc_id      = module.vpc_db.vpc_id
  local_vpc_id     = module.vpc_webserver.vpc_id
  peer_region      = var.region
  vpc_peering_name = "peering_vpc_webserver_appserver"
}


#VPC Peering vpc_appserver<->vpc_kms
module "peer_vpc_appserver_kms" {
  source           = "./module_VPC-Peering"
  peer_owner_id    = "212335697154"
  peer_vpc_id      = module.vpc_appserver.vpc_id
  local_vpc_id     = module.vpc_kms.vpc_id
  peer_region      = var.region
  vpc_peering_name = "peering_vpc_appserver_kms"
}

#VPC Peering vpc_appserver<->vpc_db
module "peer_vpc_appserver_db" {
  source           = "./module_VPC-Peering"
  peer_owner_id    = "212335697154"
  peer_vpc_id      = module.vpc_appserver.vpc_id
  local_vpc_id     = module.vpc_db.vpc_id
  peer_region      = var.region
  vpc_peering_name = "peering_vpc_appserver_db"
}

#VPC Peering vpc_kms<->vpc_db
module "peer_vpc_kms_db" {
  source           = "./module_VPC-Peering"
  peer_owner_id    = "212335697154"
  peer_vpc_id      = module.vpc_kms.vpc_id
  local_vpc_id     = module.vpc_db.vpc_id
  peer_region      = var.region
  vpc_peering_name = "peering_vpc_kms_db"
}
