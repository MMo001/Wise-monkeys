/*-----------------------------------------------------------------------------
Company: Wise Monkeys
This script is provided "AS IS" with no warranties, and confers no rights.
Version 1.0
-----------------------------------------------------------------------------*/
//-----------------------------------------------------------------------------
// Setting the deployment target scope 
//-----------------------------------------------------------------------------

targetScope = 'subscription'

//-----------------------------------------------------------------------------
// Parameter declaration
//-----------------------------------------------------------------------------

@description('Default tags')
param maintagValues object = {
  Customer: 'Wise Monkeys'
  Solution: 'Corp IT Azure Infrastructure'
  createdby: 'IaC'
  environment: env
  }

@description('Extra Tags from the .bicepparam ')
param tagValues object

@description('Azure region for deployment.')
param location string = deployment().location

@description('Application components these resources are part of.')
param component string

@description('Environment for deployment')
@allowed([ 'prod', 'acc', 'tst', 'dev'])
param env string

@description('The managementgroup where these resource are assigned too')
param product string

@description('Dictionary of deployment regions with shortname')
param locationList object

// Parameter declaration Azure Monitor Logs

//@description('Log Analytics Workspace name.')
//param logName  string = 'alz-log-analytics'

@description('Log Analytics Workspace sku name.')
@allowed([ 'CapacityReservation', 'Free', 'LACluster', 'PerGB2018', 'PerNode', 'Premium', 'Standalone', 'Standard' ])
param logSku string

@description('Log Analytics Workspace Capacity Reservation Level. Only used if parLogAnalyticsWorkspaceSkuName is set to CapacityReservation.')
@allowed([ 100, 200, 300, 400, 500, 1000, 2000, 5000 ])
param logCapResLevel int

@description('Number of days of log retention for Log Analytics Workspace.')
@minValue(30)
@maxValue(730)
param LogRetInDays int

@description('Control your costs by applying a cap to the amount of data that you collect per day.')
@minValue(1)
param LogDailyQuotaGb int

@description('Set Parameter to true to use Sentinel Classic Pricing Tiers, following changes introduced in July 2023 as documented here: https://learn.microsoft.com/azure/sentinel/enroll-simplified-pricing-tier.')
param LogUseSentinelClassicPricingTiers bool

@description('Automation account name.')
param LogAutomationAccountName string

@description('Automation Account - use managed identity.')
param LogAutomationAccountUseManagedIdentity bool

@description('Log Analytics Workspace should be linked with the automation account.')
param logLinkAutomationAccount bool

@description('Solutions that will be added to the Log Analytics Workspace.')
@allowed([ 'AgentHealthAssessment', 'AntiMalware', 'ChangeTracking', 'Security', 'SecurityInsights', 'ServiceMap', 'SQLAdvancedThreatProtection', 'SQLVulnerabilityAssessment', 'SQLAssessment', 'Updates', 'VMInsights' ])
param LogSolutions array 

//-----------------------------------------------------------------------------
// Variable declaration
//-----------------------------------------------------------------------------

var locationShortName = locationList[location]
var tags = union(maintagValues,tagValues )

var groupName = '${product}-${component}'
var environmentName = '${groupName}-${env}-${locationShortName}'
var resourceGroupName = 'rg-wl-${environmentName}'
var Log_Name = 'log-${env}-${locationShortName}'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: resourceGroupName
  location: location 
  tags: tags
  properties:{
  }
}

module logAnalytics './modules/AzureMonitorLogs.bicep' = {
  scope: resourceGroup
  name: 'logAnalytics'
    params: {
    location: location
    LogName : Log_Name 
    LogTags: tags
    LogSku: logSku
    LogCapResLevel: logCapResLevel
    LogRetInDays: LogRetInDays
    LogDailyQuotaGb: LogDailyQuotaGb
    LogUseSentinelClassicPricingTiers: LogUseSentinelClassicPricingTiers
    LogAutomationAccountName: LogAutomationAccountName
    LogAutomationAccountUseManagedIdentity: LogAutomationAccountUseManagedIdentity
    logLinkAutomationAccount: logLinkAutomationAccount
    LogSolutions: LogSolutions 
    }
  }

 