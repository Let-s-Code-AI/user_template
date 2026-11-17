# Storage account na logi. Sufiks z random_string.suffix (security.tf).
resource "azurerm_storage_account" "logs" {
  name                            = "stlogs${random_string.suffix.result}"
  resource_group_name             = data.azurerm_resource_group.main.name
  location                        = var.location
  account_kind                    = "StorageV2"
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false
  tags                            = data.azurerm_resource_group.main.tags
}

resource "azurerm_storage_container" "logs" {
  name                  = "logs"
  storage_account_id    = azurerm_storage_account.logs.id
  container_access_type = "private"
}

# Retencja: usuwa bloby z kontenera logs starsze niż var.log_retention_days.
resource "azurerm_storage_management_policy" "logs" {
  storage_account_id = azurerm_storage_account.logs.id

  rule {
    name    = "delete-old-logs"
    enabled = true

    filters {
      prefix_match = ["${azurerm_storage_container.logs.name}/"]
      blob_types   = ["blockBlob"]
    }

    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = var.log_retention_days
      }
    }
  }
}
