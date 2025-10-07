# Permissions Reference

This document outlines all required permissions for the ADX to Sentinel data pipeline solution. The deployment uses a **User-Assigned Managed Identity** which requires specific role assignments on various Azure resources.

## Overview

The solution requires a single User-Assigned Managed Identity with permissions to:

- Query Azure Data Explorer
- Write to Log Analytics via Data Collection Rules
- Send data to Event Hub (optional)
- Access Query Packs via REST API (optional)

## Required Permissions

### User-Assigned Managed Identity

**Created before deployment:** The managed identity must exist before running the Bicep deployment.

---

## Azure Data Explorer Permissions

### Required Role: Database User (or higher)

The managed identity needs **Database User** role on the target ADX database to execute KQL queries.

**Grant via Azure Portal:**

1. Navigate to your ADX cluster → Databases → Select database
2. Click "Permissions" → "Add" → "Database User"
3. Search for your managed identity name
4. Click "Select"

---

## Data Collection Rules (DCR) Permissions

### Required Role: Monitoring Metrics Publisher

**Automatically assigned by Bicep deployment** to the Data Collection Endpoint.

**Role Definition ID:** `3913510d-42f4-4e42-8a64-420c390055eb`

**What it allows:**

- Publish metrics and logs to Data Collection Rules
- Ingest data into Log Analytics workspaces via DCR

---

## Event Hub Permissions (Optional)

### Required Role: Azure Event Hubs Data Sender

**Automatically assigned by Bicep deployment** when `EventHubResourceID` parameter is provided.

**Role Definition ID:** `2b629674-e913-4c01-ae53-ef4638d8f975`

**What it allows:**

- Send events to the specified Event Hub
- Required only if using Event Hub as alternate data destination

---

## Query Pack Permissions (Optional)

### Required Role: Log Analytics Contributor

**Automatically assigned by Bicep deployment** when `QueryPackID` parameter is provided.

**Role Definition ID:** `92aaf0da-9dab-42b6-94a3-d43ce8d16293`

**Why Contributor and not Reader?**

Query Packs are an older Azure service where:

- **Reader role** allows viewing and running queries in the Azure Portal
- **Log Analytics Contributor role** is required for REST API access to queries

The Function App accesses queries via REST API, so Contributor is necessary despite not modifying queries.

**What it allows:**

- Read saved queries from Query Packs via REST API
- Execute queries defined in the Query Pack
- API access to query pack resources

**Note:** The identity will not modify queries; Contributor is only needed for API access permissions on this legacy service.

---

## Function App Permissions

### System Requirements

The Function App itself requires:

- **Storage Account access** (automatically configured via connection string)
- **Application Insights** (automatically configured)
- **User-Assigned Managed Identity assignment** (configured in Bicep)

---

## Permission Summary Table

| Resource                 | Role                         | Assignment Method         | Required               | Notes                           |
| ------------------------ | ---------------------------- | ------------------------- | ---------------------- | ------------------------------- |
| ADX Database             | Database User                | Manual (Kusto CLI/Portal) | ✅ Yes                  |                                 |
| Data Collection Endpoint | Monitoring Metrics Publisher | Automatic (Bicep)         | ✅ Yes                  |                                 |
| Event Hub                | Azure Event Hubs Data Sender | Automatic (Bicep)         | ⚠️ If using Event Hub  |                                 |
| Query Pack               | Log Analytics Contributor    | Automatic (Bicep)         | ⚠️ If using Query Pack | API access requires Contributor |
| Storage Account          | Connection String            | Automatic (Bicep)         | ✅ Yes                  |                                 |
| Application Insights     | InstrumentationKey           | Automatic (Bicep)         | ✅ Yes                  |                                 |

---

## Pre-Deployment Checklist

**Before running Bicep deployment:**

- [ ] User-Assigned Managed Identity created
- [ ] Managed Identity granted **Database User** role on ADX database
- [ ] ADX cluster accessible from Azure network
- [ ] Log Analytics workspace exists with target tables
- [ ] (Optional) Event Hub created if using alternate destination
- [ ] (Optional) Query Pack created if using saved queries

**After deployment:**

- [ ] Verify DCE role assignment in Azure Portal
- [ ] Verify Event Hub permissions (if applicable)
- [ ] Verify Query Pack permissions (if applicable)
- [ ] Test ADX connectivity via Function App logs
- [ ] Wait 10 minutes for permission propagation

---

**Last Updated:** October 2025  
**Version:** 2.0 (Updated Query Pack permissions to Log Analytics Contributor for API access)
