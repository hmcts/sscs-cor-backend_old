output "vaultUri" {
  value = "${module.sscs-cor-backend-key-vault.key_vault_uri}"
}

output "vaultName" {
  value = "${local.vaultName}"
}

output "sscs-output" {
  value = "sscs-output"
}
