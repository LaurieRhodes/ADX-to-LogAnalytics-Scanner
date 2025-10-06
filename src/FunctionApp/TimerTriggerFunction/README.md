# TimerTriggerFunction Configuration

## Timer Trigger Schedule

The initial project is configured for testing. The scanning component will run for a 10-minute block when triggered by the SupervisorFunction (HTTP trigger). For production, you should enable automatic continuous processing.

To change to production schedule:

1. Edit `src/FunctionApp/TimerTriggerFunction/function.json`
2. Redeploy the Function App code

**Development (default)**: `0 0 9 * * *` - daily at 9 AM  
**Production**: `0 0,10,20,30,40,50 * * * *` - every 10 minutes

## Example Files

Example Production and Development configurations are included in this directory.

- **`function.json.prod`** : Continuious running schedule, configured to run automatically on startup.

- **`function.json.dev`** : Intended for development and testing.  Scanning occurs in 10 minute blocks after being initiated via the HTTP Trigger Function.

Rename the desired file to `function.json' and deploy the Function App.
