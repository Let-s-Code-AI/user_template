output "logs_storage_account_name" {
  value = azurerm_storage_account.logs.name
}

output "logs_container_name" {
  value = azurerm_storage_container.logs.name
}
