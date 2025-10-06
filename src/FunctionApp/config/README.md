# Query Configuration

## Purpose

The `queries.yaml` file defines KQL queries that filter ADX data for forwarding to Sentinel. Each query specifies what data should be promoted from your ADX cluster to Log Analytics tables via Data Collection Rules.

## File Structure

```yaml
TableName:
  - name: "Query Display Name"
    description: "What this query filters"
    query: |
      TableName
      | where <filter conditions>
```

## Configuration Elements

**TableName** - ADX source table (must match DCR environment variable suffix)

**name** - Descriptive query identifier

**description** - Explains the query's purpose

**query** - KQL query block (literal multi-line string)

## Example

```yaml
Syslog:
  - name: "Critical Severity Events"
    description: "Syslog events with Critical severity level"
    query: |
      Syslog
      | where SeverityLevel == "Critical"

  - name: "Authentication Failures"
    description: "Failed login attempts"
    query: |
      Syslog
      | where Facility == "auth" and SeverityLevel == "err"
```

## Multiple Queries Per Table

Tables support multiple queries - each runs independently and forwards matching records:

```yaml
SecurityEvent:
  - name: "High Value Logins"
    description: "Admin account logons"
    query: |
      SecurityEvent
      | where EventID == 4624 and AccountType == "Admin"

  - name: "Failed Logins"
    description: "Authentication failures"  
    query: |
      SecurityEvent
      | where EventID == 4625
```

## Schema Notes

- Queries automatically insert time filtering for realtime processing
  
  

# 
