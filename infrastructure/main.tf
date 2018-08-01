resource "azurerm_resource_group" "rg" {
  name     = "${var.product}-${var.component}-${var.env}"
  location = "${var.location}"
  tags = "${merge(var.common_tags,
    map("lastUpdated", "${timestamp()}")
    )}"
}

locals {
  aseName       = "${data.terraform_remote_state.core_apps_compute.ase_name[0]}"
  app_full_name = "${var.product}-${var.component}"

  local_env = "${(var.env == "preview" || var.env == "spreview") ? (var.env == "preview" ) ? "aat" : "saat" : var.env}"
  local_ase = "${(var.env == "preview" || var.env == "spreview") ? (var.env == "preview" ) ? "core-compute-aat" : "core-compute-saat" : local.aseName}"
}

module "sscs-cor-backend" {
  source       = "git@github.com:hmcts/moj-module-webapp.git?ref=master"
  product      = "${local.app_full_name}"
  location     = "${var.location}"
  env          = "${var.env}"
  ilbIp        = "${var.ilbIp}"
  is_frontend  = false
  subscription = "${var.subscription}"
  capacity     = "${(var.env == "preview") ? 1 : 2}"
  common_tags  = "${var.common_tags}"

  app_settings = {

  }
}
