function Format-Query {
    param (
        [string]$query
    )

    # Replace escape sequences
    $query = $query -replace '\\r\\n', "`n"
    $query = $query -replace '\\u0027', "'"

    return $query
}

