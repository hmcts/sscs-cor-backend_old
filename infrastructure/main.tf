locals {
  app = "sscs-cor-backend"
  create_api = "${var.env != "preview" && var.env != "spreview"}"
}

module "sscs-cor-backend" {
  source       = "git@github.com:contino/moj-module-webapp?ref=master"
  product      = "${var.product}-${local.app}"
  location     = "${var.location}"
  env          = "${var.env}"
  ilbIp        = "${var.ilbIp}"
  subscription = "${var.subscription}"
  is_frontend  = false
  capacity     = "${var.capacity}"
  common_tags  = "${var.common_tags}"

  app_settings = {

  }
}

module "key-vault" {
  source                  = "git@github.com:hmcts/cnp-module-key-vault?ref=master"
  product                 = "${var.product}"
  env                     = "${var.env}"
  tenant_id               = "${var.tenant_id}"
  object_id               = "${var.jenkins_AAD_objectId}"
  resource_group_name     = "${module.recipe-backend.resource_group_name}"
  # dcd_cc-dev group object ID
  product_group_object_id = "38f9dea6-e861-4a50-9e73-21e64f563537"
}
