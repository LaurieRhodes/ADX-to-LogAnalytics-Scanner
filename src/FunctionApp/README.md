## Deployment Guide

### Prerequisites

1. **Azure Resources Setup**:
   
   - Azure Function App (PowerShell 7.x runtime)
   - User-Assigned Managed Identity
   - Event Hub Namespace and Event Hub
   - Application Insights (optional but recommended)

2. **Permissions Configuration**:
   
   ```
   User-Assigned Managed Identity requires:
   - Microsoft Graph: User.Read.All
   - Microsoft Graph: Group.Read.All  
   - Event Hub: Azure Event Hubs Data Sender
   ```

### Deployment Steps

1. **Configure Environment Variables** in Azure Function App:
   
   ```
   CLIENTID=<your-managed-identity-client-id>
   EVENTHUBNAMESPACE=<your-eventhub-namespace>
   EVENTHUBNAME=<your-eventhub-name>
   APPLICATIONINSIGHTS_CONNECTION_STRING=<optional>
   ```

2. **Deploy Function Code**:
   
   - Upload all files maintaining directory structure
   - Ensure `AADExporter` module loads correctly via `profile.ps1`

3. **Test Deployment**:
   
   ```http
   GET https://<function-app>.azurewebsites.net/api/HttpTriggerFunction
   ```

### Troubleshooting

#### Common Issues

1. **"Socket permission error"** - Fixed in v3.0 by removing customHandler configuration

2. **"Module not found"** - Ensure `AADExporter.psm1` exists and `profile.ps1` uses correct paths

3. **"Event Hub 401 error"** - Verify managed identity has "Azure Event Hubs Data Sender" role (can take 24 hours to propagate)

4. **"Parameter binding error"** - Fixed in v3.0 by updating error handling to accept both ErrorRecord and Exception types

#### Diagnostic Commands

```powershell
# Check function status
GET /api/HttpTriggerFunction

# View logs in Application Insights
traces | where customDimensions.ExportId == "<export-id>"

# Monitor Event Hub ingestion
// Check Event Hub metrics in Azure portal
```

## Maintenance

### Regular Tasks

1. **Monitor Performance**: Review Application Insights telemetry for:
   
   - Export duration trends
   - Error rates and types
   - Event Hub throughput

2. **Update Dependencies**: Keep PowerShell modules current in `requirements.psd1`

3. **Review Permissions**: Ensure managed identity permissions remain valid

### Code Maintenance Standards

1. **No Nested Catch Blocks**: Maintain single-level error handling
2. **Comprehensive Testing**: Test both success and failure scenarios  
3. **Telemetry Coverage**: Ensure all operations include appropriate logging
4. **Documentation**: Update inline comments for any logic changes

## Performance Optimization

### Current Optimizations

- **Batch Processing**: Users processed in batches of 999 (Graph API maximum)
- **Event Hub Chunking**: Payloads split to stay under 900KB limit
- **Exponential Backoff**: Intelligent retry with increasing delays
- **Parallel Processing**: Independent export stages

### Monitoring Metrics

Key performance indicators to track:

- **Records Per Minute**: Throughput measurement
- **API Call Success Rate**: Graph API reliability
- **Event Hub Success Rate**: Data transmission reliability
- **End-to-End Duration**: Total export time

## Version History

### v3.0 (2025-08-31) - Comprehensive Refactoring

- Renamed module: AZRest → AADExporter
- Eliminated all nested catch blocks
- Streamlined error handling patterns
- Enhanced telemetry and monitoring
- Production-ready architecture

### v2.1 (2025-08-31) - Module Architecture

- Modular export functions
- v1.0 Graph API endpoints
- Enhanced error handling

### v2.0 (Previous) - Beta Implementation

- Initial modular design
- Mixed API endpoint versions
- Basic error handling

## Security Considerations

### Authentication Security

- **Managed Identity**: No stored credentials in code or configuration
- **Least Privilege**: Minimal required permissions only
- **Token Refresh**: Automatic token lifecycle management

### Data Security

- **In-Transit Encryption**: HTTPS for all API calls
- **Event Hub Security**: Bearer token authentication
- **No Data Persistence**: No local storage of exported data

### Compliance

- **Audit Logging**: Comprehensive telemetry for compliance tracking
- **Data Classification**: Handles Azure AD identity data
- **Regional Compliance**: Respects Azure region data residency

## Support

### Logging and Diagnostics

- **Application Insights**: Structured telemetry and performance metrics
- **Function Logs**: Real-time execution logs
- **Correlation IDs**: Track operations across services

### Contact Information

- **Author**: Laurie Rhodes
- **Version**: 3.0
- **Last Updated**: 2025-08-31