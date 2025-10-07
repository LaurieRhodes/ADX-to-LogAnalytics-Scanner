# Documentation

This directory contains comprehensive documentation for the ADX to Sentinel continuous data pipeline project.

## Getting Started

**New to this project?** Start here:

1. [Permissions](Permissions.md) - Understand required access and role assignments
2. [Architecture](Architecture.md) - Understand the system design and components
3. [Deployment Guide](Guide%20-%20Deployment.md) - Deploy the solution to your environment
4. [Configuring KQL Queries](Guide%20-%20Configuring%20KQL%20Pipeline%20Queries.md) - Configure queries to filter and forward data

## Documentation Index

### Core Documentation

| Document                                                                                  | Description                                                                            |
| ----------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| [Permissions](Permissions.md)                                                             | **Required permissions, role assignments, and security configuration**                 |
| [Architecture](Architecture.md)                                                           | Software architecture overview, component interaction, and design patterns             |
| [Deployment Guide](Guide%20-%20Deployment.md)                                             | Complete deployment guide with prerequisites, parameters, and production configuration |
| [Configuring KQL Pipeline Queries](Guide%20-%20Configuring%20KQL%20Pipeline%20Queries.md) | How to add and modify KQL queries for data filtering and forwarding                    |
| [Adding New Tables](Guide%20-%20Adding%20New%20Tables.md)                                 | Add support for custom tables with DCR creation and schema mapping                     |

### Integration Guides

| Document                                          | Description                                                         |
| ------------------------------------------------- | ------------------------------------------------------------------- |
| [DCR Integration Guide](DCR_Integration_Guide.md) | Data Collection Rules (DCR) integration details and troubleshooting |
| [Event Hub Integration](Event_Hub_Integration.md) | Configure Event Hub as alternate data destination                   |

### Operations

| Document                              | Description                               |
| ------------------------------------- | ----------------------------------------- |
| [Troubleshooting](Troubleshooting.md) | Common issues, diagnostics, and solutions |

## Quick Reference

### Key Concepts

- **SupervisorFunction**: Manages orchestration lifecycle in 10-minute blocks
- **ContinuousQueueOrchestrator**: Stateful orchestrator processing tables continuously
- **QueueManagerActivity**: Round-robin table selection from queue
- **ADXQueryActivity**: Individual table processing with DCR forwarding
- **Dynamic Discovery**: Tables automatically discovered via `DCR{TableName}` environment variables

### Configuration Files

- `src/FunctionApp/config/queries.yaml` - KQL query definitions
- `infrastructure/parameters.json` - Deployment parameters (ignored by git)
- `infrastructure/example.parameters.json` - Template for parameters
- `src/FunctionApp/host.json` - Function App runtime configuration

### Common Tasks

**Deploy the solution:**

```bash
./deploy.ps1
```

**Add a new table:**

1. Create DCR for the table
2. Add environment variable `DCR{TableName}={DCR-ID}`
3. Add KQL queries to `queries.yaml`
4. Redeploy

**Configure queries:**
Edit `src/FunctionApp/config/queries.yaml` - see [Configuring KQL Pipeline Queries](Guide%20-%20Configuring%20KQL%20Pipeline%20Queries.md)

**Enable continuous processing:**
Edit `src/FunctionApp/TimerTriggerFunction/function.json` schedule to `0 0,10,20,30,40,50 * * * *`

## Architecture Overview

```
┌─────────────────────┐
│  SupervisorFunction │
│   (HTTP/Timer)      │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────────────┐
│ ContinuousQueueOrchestrator │
│  (Durable Orchestrator)     │
└──────────┬──────────────────┘
           │
           ├─► QueueManagerActivity ──► Azure Table Storage (Queue)
           │
           └─► ADXQueryActivity ──┬─► Azure Data Explorer (Query)
                                  │
                                  ├─► Data Collection Rules (Forward)
                                  │
                                  └─► Event Hub (Optional)
```

## Support and Contributing

- **Issues**: Report bugs or request features via GitHub Issues
- **Contributing**: See project root for contribution guidelines
- **License**: MIT License - see [LICENSE](../LICENSE)

## Additional Resources

- [Azure Functions Documentation](https://docs.microsoft.com/en-us/azure/azure-functions/)
- [Durable Functions](https://learn.microsoft.com/en-us/azure/azure-functions/durable/durable-functions-overview)
- [Azure Data Explorer (Kusto)](https://docs.microsoft.com/en-us/azure/data-explorer/)
- [Data Collection Rules](https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/data-collection-rule-overview)
- [Microsoft Sentinel](https://docs.microsoft.com/en-us/azure/sentinel/)
- [Infrastructure Parameters Reference](../infrastructure/Parameters_Reference.md)

---

**Last Updated:** October 2025
