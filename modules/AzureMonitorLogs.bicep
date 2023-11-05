/*<#-----------------------------------------------------------------------------
Company: Wise Monkeys
Marcel Moreels, Cloud Solution Architect

marcel@wise-monkeys.nl
October, 2023

This script is provided "AS IS" with no warranties, and confers no rights.

Version 1.0
-----------------------------------------------------------------------------*/

@description('Automation account name.')
param LogName  string

@description('Azure region for deployment.')
param location string

@description('Log Analytics Workspace sku name.')
param LogSku string

@description('Log Analytics Workspace Capacity Reservation Level. Only used if parLogAnalyticsWorkspaceSkuName is set to CapacityReservation.')
param LogCapResLevel int

@description('Number of days of log retention for Log Analytics Workspace.')
param LogRetInDays int

@description('Control your costs by applying a cap to the amount of data that you collect per day.')
param LogDailyQuotaGb int

@description('Automation Account - use managed identity.')
param LogTags object

@description('Set Parameter to true to use Sentinel Classic Pricing Tiers, following changes introduced in July 2023 as documented here: https://learn.microsoft.com/azure/sentinel/enroll-simplified-pricing-tier.')
param LogUseSentinelClassicPricingTiers bool 

@description('Automation account name.')
param LogAutomationAccountName string

@description('Automation Account - use managed identity.')
param LogAutomationAccountUseManagedIdentity bool

@description('Log Analytics Workspace should be linked with the automation account.')
param logLinkAutomationAccount bool

@description('Solutions that will be added to the Log Analytics Workspace.')
param LogSolutions array

resource resLogAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: LogName
  location: location
  tags: LogTags
    properties: {
      retentionInDays: LogRetInDays
    sku: {
      capacityReservationLevel: LogSku == 'CapacityReservation' ? LogCapResLevel : null
      name: LogSku
    }
    workspaceCapping: {
      dailyQuotaGb: LogDailyQuotaGb
    }
  }
}

resource resLogAnalyticsWorkspaceSolutions 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = [for solution in LogSolutions: {
  name: '${solution}(${resLogAnalyticsWorkspace.name})'
  location: location
  tags: LogTags
  properties: solution == 'SecurityInsights' ? {
    workspaceResourceId: resLogAnalyticsWorkspace.id
    sku: LogUseSentinelClassicPricingTiers ? null : {
      name: 'Unified'
    }
  } : {
    workspaceResourceId: resLogAnalyticsWorkspace.id
  }
  plan: {
    name: '${solution}(${resLogAnalyticsWorkspace.name})'
    product: 'OMSGallery/${solution}'
    publisher: 'Microsoft'
    promotionCode: ''
  }
}]

resource resAutomationAccount 'Microsoft.Automation/automationAccounts@2022-08-08' = {
  name: LogAutomationAccountName
  location: location
  tags: LogTags
  identity: LogAutomationAccountUseManagedIdentity ? {
    type: 'SystemAssigned'
  } : null
  properties: {
    sku: {
      name: 'Basic'
    }
    encryption: {
      keySource: 'Microsoft.Automation'
    }
  }
}

resource resLogAnalyticsLinkedServiceForAutomationAccount 'Microsoft.OperationalInsights/workspaces/linkedServices@2020-08-01' = if (logLinkAutomationAccount) {
  parent: resLogAnalyticsWorkspace
  name: 'Automation'
  properties: {
    resourceId: resAutomationAccount.id
  }
}

output outLogAnalyticsWorkspaceName string = resLogAnalyticsWorkspace.name
output outLogAnalyticsWorkspaceId string = resLogAnalyticsWorkspace.id

