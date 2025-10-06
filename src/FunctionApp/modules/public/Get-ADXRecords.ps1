function Get-ADXRecords {
    <#
    .SYNOPSIS
        Executes KQL queries against Azure Data Explorer with automatic time filtering
    
    .DESCRIPTION
        Connects to ADX cluster, applies time-based filtering to queries using Convert-Query,
        executes the filtered queries, and returns structured results. This ensures each
        query only retrieves data from the specified time window, preventing duplicates
        and enabling incremental processing.
    
    .PARAMETER QueryDetails
        Array of query objects containing Table, Query, Name, and Description properties
    
    .PARAMETER clientId
        Client ID for Managed Identity authentication
    
    .PARAMETER LastRunTime
        Last execution time for query context (ISO 8601 format)
    
    .PARAMETER CurrentTime
        Current execution time for query context (ISO 8601 format)
    
    .PARAMETER ADXClusterURI
        URI of the ADX cluster
    
    .PARAMETER ADXDatabase
        Name of the ADX database
    
    .OUTPUTS
        Array of objects with table and query (JSON) properties
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [PSObject]$QueryDetails,

        [Parameter(Mandatory=$true)]
        [string]$clientId,

        [Parameter(Mandatory=$true)]
        [string]$LastRunTime,

        [Parameter(Mandatory=$true)]
        [string]$CurrentTime,

        [Parameter(Mandatory=$true)]
        [string]$ADXClusterURI,

        [Parameter(Mandatory=$true)]
        [string]$ADXDatabase
    )

    begin {
        $ErrorActionPreference = 'Stop'
        $InformationPreference = "Continue"

        $resourceURL = "https://kusto.kusto.windows.net"
        $output = @()

        Write-Debug "[Get-ADXRecords] Starting execution with parameters:"
        Write-Debug "  Database: $ADXDatabase"
        Write-Debug "  Cluster URI: $ADXClusterURI"
        Write-Debug "  Time Range: $LastRunTime to $CurrentTime"
        Write-Debug "  Client ID: $($clientId.Substring(0, 8))..."
        Write-Debug "  Query Details Count: $($QueryDetails.Count)"
    }

    process {
        # Validate input parameters
        if ([string]::IsNullOrWhiteSpace($ADXClusterURI) -or -not $ADXClusterURI.StartsWith("https://")) {
            throw "Invalid ADXClusterURI format: $ADXClusterURI"
        }

        try {
            # Get authentication token with explicit error handling
            Write-Debug "[Get-ADXRecords] Requesting authentication token for resource: $resourceURL"
            $token = Get-AzureADToken -resource $resourceURL -clientId $clientId
            if (-not $token) {
                throw "Authentication failed: Unable to obtain token"
            }
            Write-Debug "[Get-ADXRecords] Successfully obtained authentication token (length: $($token.Length))"

            # Prepare headers
            $clientRequestId = [guid]::NewGuid().ToString()
            $authHeader = @{
                'Authorization' = "Bearer $token"
                'Content-Type' = 'application/json'
                'Accept' = 'application/json'
                'Accept-Encoding' = 'gzip, deflate'
                'Connection' = 'Keep-Alive'
                'Host' = $ADXClusterURI.Split('/')[2]
                'x-ms-client-request-id' = $clientRequestId
            }

            Write-Information "[Get-ADXRecords] Prepared headers with client request ID: $clientRequestId"

            # Process each query with improved error handling
            foreach ($alertQuery in $QueryDetails) {
                Write-Debug "[Get-ADXRecords] ==============================="
                Write-Debug "[Get-ADXRecords] Processing query for table: $($alertQuery.Table)"
                Write-Debug "[Get-ADXRecords] Query name: $($alertQuery.Name)"
                Write-Debug "[Get-ADXRecords] Query description: $($alertQuery.Description)"

                if ([string]::IsNullOrWhiteSpace($alertQuery.Query)) {
                    Write-Warning "[Get-ADXRecords] Empty query found for table $($alertQuery.Table). Skipping."
                    continue
                }

                # Log the raw query before time filtering
                Write-Debug "[Get-ADXRecords] STEP 1 - Original query (before time filtering):"
                Write-Debug "--- START ORIGINAL QUERY ---"
                Write-Debug $alertQuery.Query
                Write-Debug "--- END ORIGINAL QUERY ---"

                try {
                    # CRITICAL FIX: Apply time-based filtering to the query using Convert-Query
                    # This is the key functionality that was missing!
                    if (Get-Command -Name "Convert-Query" -ErrorAction SilentlyContinue) {
                        Write-Debug "[Get-ADXRecords] Applying time filtering: $LastRunTime to $CurrentTime"
                        $kqlQuery = Convert-Query -Query $alertQuery.Query -FromDateTime $LastRunTime -ToDateTime $CurrentTime
                        Write-Debug "[Get-ADXRecords] Time filtering applied successfully"
                    } else {
                        Write-Warning "[Get-ADXRecords] Convert-Query function not available - using original query without time filtering"
                        Write-Warning "[Get-ADXRecords] *** THIS WILL CAUSE DUPLICATE DATA AND POOR PERFORMANCE ***"
                        $kqlQuery = $alertQuery.Query
                    }
                    
                    Write-Debug "[Get-ADXRecords] STEP 2 - Time-filtered query (ready for execution):"
                    Write-Debug "--- START TIME-FILTERED QUERY ---"
                    Write-Debug $kqlQuery
                    Write-Debug "--- END TIME-FILTERED QUERY ---"
                    
                    
                    $queryUri = "$($ADXClusterURI)/v2/rest/query"
                    $queryBody = @{
                        "db" = $ADXDatabase
                        "csl" = $kqlQuery
                    }

                    Write-Debug "[Get-ADXRecords] STEP 3 - Final query body for ADX execution:"
                    Write-Debug "--- START FINAL QUERY ---"
                    Write-Debug $queryBody.csl
                    Write-Debug "--- END FINAL QUERY ---"

                    # Convert to JSON and log it
                    $jsonBody = ConvertTo-Json -InputObject $queryBody -Depth 10
                    
                    Write-Debug "[Get-ADXRecords] JSON body after ConvertTo-Json:"
                    Write-Debug $jsonBody

                    # Log the complete request details
                    Write-Debug "[Get-ADXRecords] Request Details:"
                    Write-Debug "  URI: $queryUri"
                    Write-Debug "  Database: $ADXDatabase"
                    Write-Debug "  Client Request ID: $clientRequestId"
                    Write-Debug "  Time Window: $LastRunTime to $CurrentTime"

                    # Execute query with improved retry logic
                    $maxRetries = 1  # Reduce retries for testing
                    $retryCount = 0
                    $retryDelaySeconds = 2
                    $success = $false

                    do {
                        $retryCount++
                        Write-Debug "[Get-ADXRecords] Query attempt $retryCount of $maxRetries"

                        try {
                            $timeoutSeconds = 30
                            Write-Debug "[Get-ADXRecords] Executing REST call with $timeoutSeconds second timeout"

                            $response = Invoke-RestMethod `
                                -Uri $queryUri `
                                -Method Post `
                                -Headers $authHeader `
                                -Body $jsonBody `
                                -TimeoutSec $timeoutSeconds `
                                -DisableKeepAlive `
                                -ErrorAction Stop

                            $success = $true
                            Write-Debug "[Get-ADXRecords] Query executed successfully"
                            break
                        }
                        catch {
                            $errorDetails = @{
                                ErrorMessage = $_.Exception.Message
                                ErrorType = $_.Exception.GetType().Name
                                Response = $_.Exception.Response
                                StatusCode = if ($_.Exception.Response) { $_.Exception.Response.StatusCode.value__ } else { "Unknown" }
                            }

                            Write-Error "[Get-ADXRecords] ======= QUERY FAILURE DETAILS ======="
                            Write-Error "[Get-ADXRecords] Attempt $retryCount failed"
                            Write-Error "[Get-ADXRecords] Error Message: $($errorDetails.ErrorMessage)"
                            Write-Error "[Get-ADXRecords] Error Type: $($errorDetails.ErrorType)"
                            Write-Error "[Get-ADXRecords] Status Code: $($errorDetails.StatusCode)"
                            Write-Error "[Get-ADXRecords] Time-filtered query that failed:"
                            Write-Error $kqlQuery

                            # Try to get response content if available
                            if ($_.Exception.Response) {
                                try {
                                    $responseStream = $_.Exception.Response.GetResponseStream()
                                    $reader = New-Object System.IO.StreamReader($responseStream)
                                    $responseContent = $reader.ReadToEnd()
                                    Write-Error "[Get-ADXRecords] Response content: $responseContent"
                                }
                                catch {
                                    Write-Error "[Get-ADXRecords] Could not read response content: $($_.Exception.Message)"
                                }
                            }

                            Write-Error "[Get-ADXRecords] ======= END FAILURE DETAILS ======="

                            if ($retryCount -lt $maxRetries) {
                                $waitTime = $retryDelaySeconds * [Math]::Pow(2, ($retryCount - 1))
                                Write-Information "[Get-ADXRecords] Waiting $waitTime seconds before retry..."
                                Start-Sleep -Seconds $waitTime
                            }
                            else {
                                Write-Error "Max retries ($maxRetries) exceeded. Last error: $($errorDetails.ErrorMessage)"
                                throw
                            }
                        }
                    } while (-not $success -and $retryCount -lt $maxRetries)

                    # Process response with validation
                    if ($null -eq $response) {
                        throw "No response received from ADX query"
                    }

                    Write-Debug "[Get-ADXRecords] Processing response frames (count: $($response.Count))"
                    foreach ($frame in $response) {
                        if ($null -eq $frame) { continue }

                        Write-Debug "[Get-ADXRecords] Processing frame type: $($frame.FrameType), table kind: $($frame.TableKind)"

                        if ($frame.FrameType -eq "DataTable" -and $frame.TableKind -eq "PrimaryResult") {
                            $columns = $frame.Columns

                            if ($null -eq $columns -or $columns.Count -eq 0) {
                                Write-Warning "[Get-ADXRecords] No columns found in response"
                                continue
                            }

                            Write-Debug "[Get-ADXRecords] Found $($columns.Count) columns: $($columns.ColumnName -join ', ')"
                            Write-Debug "[Get-ADXRecords] Found $($frame.Rows.Count) rows for time window $LastRunTime to $CurrentTime"

                            foreach ($row in $frame.Rows) {
                                $record = @{}
                                for ($i = 0; $i -lt $columns.Count; $i++) {
                                    $record[$columns[$i].ColumnName] = $row[$i]
                                }

                                # Create query result as hashtable
                                $queryResult = @{
                                    table = $alertQuery.Table
                                    query = $(ConvertTo-Json -InputObject $record -Depth 10)
                                }

                                $output += $queryResult
                                Write-Debug "[Get-ADXRecords] Processed record for table $($alertQuery.Table)"
                            }
                        }
                        elseif ($frame.FrameType -eq "DataSetCompletion" -and $frame.HasErrors) {
                            Write-Warning "[Get-ADXRecords] Query completed with errors: $($frame.OneApiErrors | ConvertTo-Json)"
                        }
                    }
                }
                catch {
                    $errorMessage = "[Get-ADXRecords] Error processing query for table $($alertQuery.Table): $($_.Exception.Message)"
                    Write-Error $errorMessage
                    # Continue with next query instead of failing completely
                    continue
                }
            }
        }
        catch {
            $errorMessage = "[Get-ADXRecords] Fatal error occurred: $($_.Exception.Message)"
            if ($_.Exception.InnerException) {
                $errorMessage += " Inner Exception: $($_.Exception.InnerException.Message)"
            }
            Write-Error $errorMessage
            throw
        }
    }

    end {
        Write-Information "[Get-ADXRecords] Function completed. Total records retrieved: $($output.Count)"
        Write-Information "[Get-ADXRecords] Time window processed: $LastRunTime to $CurrentTime"
        return $output
    }
}
