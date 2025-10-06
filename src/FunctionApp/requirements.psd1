@{
   # AzTable - Required for managing and querying Azure Storage Tables
   'AzTable' = '2.*'

   # Az.OperationalInsights - Enables querying Azure Monitor and Log Analytics
   'Az.OperationalInsights' = '3.*'

   # Az.Resources - Used for resource management operations in Azure
   'Az.Resources' = '5.*'

   # Az.Storage - Required for managing Azure Storage accounts and blobs
   'Az.Storage' = '5.*'

   # Az.Kusto - For ADX database operations and queries
   'Az.Kusto' = '2.*'

   # Az.Accounts - Core authentication and context management
   'Az.Accounts' = '2.*'

   # powershell-yaml - Required for parsing YAML configuration files
   'powershell-yaml' = '0.4.7'

   # DurableFunctions - Required for Durable Functions orchestrations and activities
   # Note: This is a built-in module provided by the Azure Functions runtime
   # It does NOT need to be in requirements.psd1
}
