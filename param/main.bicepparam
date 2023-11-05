/*<#-----------------------------------------------------------------------------
Company: Wise Monkeys
Marcel Moreels, Cloud Solution Architect

marcel@wise-monkeys.nl
October, 2023

This script is provided "AS IS" with no warranties, and confers no rights.

Version 1.0
-----------------------------------------------------------------------------*/

using '../main.bicep'

//description('Application components these resources are part of.')
param component = 'log'

//description('Environment for deployment')
param env = 'prod'

//description('The managementgroup where these resource are assigned too')
param product = 'pltf-mgmt'

//description('Dictionary of deployment regions with shortname')
param locationList = {
  northeurope: 'neu'
  westeurope: 'weu'
}

param tagValues = {
  ServiceClass : 'Gold'
  DataClassification : 'General'
  BusinessCriticality : 'Mission-critical'
  BusinessUnit : 'Corp IT'
  OperationsTeam : 'platform management'
  Contact : 'platform-management@wise-monkeys.nl'
  CostCenter :'444'
  DisasterRecovery : 'Mission-critical'
  DisasterRecoveryMethod : 'IaC'
}

//description('Log Analytics Workspace sku name.')
param logSku = 'PerGB2018'

//description('Log Analytics Workspace Capacity Reservation Level. Only used if parLogAnalyticsWorkspaceSkuName is set to CapacityReservation.')
param logCapResLevel = 100

//description('Number of days of log retention for Log Analytics Workspace.')
param LogRetInDays = 365

//description('Control your costs by applying a cap to the amount of data that you collect per day.')
param LogDailyQuotaGb = 1

//description('Set Parameter to true to use Sentinel Classic Pricing Tiers, following changes introduced in July 2023 as documented here: https://learn.microsoft.com/azure/sentinel/enroll-simplified-pricing-tier.')
param LogUseSentinelClassicPricingTiers = false

//description('Automation account name.')
param LogAutomationAccountName = 'aa-log-prod-weu'

//description('Automation Account - use managed identity.')
param LogAutomationAccountUseManagedIdentity = true

//description('Log Analytics Workspace should be linked with the automation account.')
param logLinkAutomationAccount = true

//description('Solutions that will be added to the Log Analytics Workspace.')
param LogSolutions = [ 'AgentHealthAssessment', 'AntiMalware', 'ChangeTracking', 'Security', 'SecurityInsights', 'SQLAdvancedThreatProtection', 'SQLVulnerabilityAssessment', 'SQLAssessment', 'Updates', 'VMInsights' ]
