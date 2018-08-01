provider "vault" {
  address = "https://vault.reform.hmcts.net:6200"
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.product}-${var.component}-${var.env}"
  location = "${var.location}"
  tags = "${merge(var.common_tags,
    map("lastUpdated", "${timestamp()}")
    )}"
}

data "vault_generic_secret" "email_mac_secret" {
  path = "secret/${var.infrastructure_env}/sscs/sscs_email_mac_secret_text"
}

data "vault_generic_secret" "sscs_cor_backend_secret" {
  path = "secret/${var.infrastructure_env}/ccidam/service-auth-provider/api/microservice-keys/sscs-cor_backend"
}

data "vault_generic_secret" "idam_api" {
  path = "secret/${var.infrastructure_env}/sscs/idam_api"
}

data "vault_generic_secret" "idam_s2s_api" {
  path = "secret/${var.infrastructure_env}/sscs/idam_s2s_api"
}

data "vault_generic_secret" "idam_uid" {
  path = "secret/${var.infrastructure_env}/sscs/idam_uid"
}

data "vault_generic_secret" "idam_key_sscs" {
  path = "secret/${var.infrastructure_env}/sscs/idam_key_sscs"
}

data "vault_generic_secret" "idam_role" {
  path = "secret/${var.infrastructure_env}/sscs/idam_role"
}

locals {
  aseName       = "${data.terraform_remote_state.core_apps_compute.ase_name[0]}"
  app_full_name = "${var.product}-${var.component}"

  local_env = "${(var.env == "preview" || var.env == "spreview") ? (var.env == "preview" ) ? "aat" : "saat" : var.env}"
  local_ase = "${(var.env == "preview" || var.env == "spreview") ? (var.env == "preview" ) ? "core-compute-aat" : "core-compute-saat" : local.aseName}"

  previewVaultName    = "${var.product}"
  nonPreviewVaultName = "${var.product}-${var.env}"
  vaultName           = "${(var.env == "preview") ? local.previewVaultName : local.nonPreviewVaultName}"
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
    IDAM_API_URL = "${data.vault_generic_secret.idam_api.data["value"]}"

    CCD_SERVICE_API_URL = "${local.ccdApi}"


    SUBSCRIPTIONS_MAC_SECRET = "${data.vault_generic_secret.email_mac_secret.data["value"]}"

  }
}

module "sscs-cor-backend-key-vault" {
  source                  = "git@github.com:hmcts/moj-module-key-vault?ref=master"
  name                    = "${local.vaultName}"
  product                 = "${var.product}"
  env                     = "${var.env}"
  tenant_id               = "${var.tenant_id}"
  object_id               = "${var.jenkins_AAD_objectId}"
  resource_group_name     = "${azurerm_resource_group.rg.name}"
  product_group_object_id = "300e771f-856c-45cc-b899-40d78281e9c1"
}

