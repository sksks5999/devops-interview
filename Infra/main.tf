##############################
## Azure App Service - Main ##
##############################
###########################
## Azure Provider - Main ##
###########################

# Define Terraform provider
terraform {
  required_version = ">= 0.12"
}

# Configure the Azure provider
provider "azurerm" {
  environment = "public"
  version     = ">= 2.15.0"
  features {}
}

# Create a Resource Group
resource "azurerm_resource_group" "appservice-rg" {
  name     = "accweather-${var.region}-${var.environment}-${var.app_name}-app-service-rg"
  location = var.location

  tags = {
    description = var.description
    environment = var.environment
    owner       = var.owner  
  }
}

# Create the App Service Plan 
resource "azurerm_app_service_plan" "service-plan" {
  name                = "accweather-${var.region}-${var.environment}-${var.app_name}-service-plan"
  location            = azurerm_resource_group.appservice-rg.location
  resource_group_name = azurerm_resource_group.appservice-rg.name
  kind                = "Windows"
  reserved            = true

  sku {
    tier = "PremiumV2"
    size = "P1v2"
  }

  tags = {
    description = var.description
    environment = var.environment
    owner       = var.owner  
  }
}

# Create the App Service
resource "azurerm_app_service" "app-service" {
  name                = "accweather-${var.region}-${var.environment}-${var.app_name}-app-service"
  location            = azurerm_resource_group.appservice-rg.location
  resource_group_name = azurerm_resource_group.appservice-rg.name
  app_service_plan_id = azurerm_app_service_plan.service-plan.id

  site_config {
    dotnet_framework_version = "v3.1"
  }
  
# Create the storage account
resource "azurerm_storage_account" "accweatherstorage" {
  name                     = "accweatherstorage"
  resource_group_name      = azurerm_resource_group.appservice-rg.name
  location                 = azurerm_resource_group.appservice-rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create the storage container
resource "azurerm_storage_container" "accweathercontainer" {
  name                  = "accweathercontainer"
  storage_account_name  = azurerm_storage_account.accweatherstorage.name
  container_access_type = "private"
}

  tags = {
    description = var.description
    environment = var.environment
    owner       = var.owner  
  }
}
