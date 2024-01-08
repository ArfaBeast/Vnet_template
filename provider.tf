provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id       = "558e6f55-de36-4f58-ad75-7ffe12916386"
  client_secret   = var.secret-id
  tenant_id       = "55fbec2f-7e2c-4383-9f4a-c07cb7439b90"
}
