$ErrorActionPreference = 'Stop'

function Get-OnDemandRate {
    param([string[]]$ProductFilters, [string]$ExpectedUnit)

    $cliArgs = @('pricing', 'get-products', '--service-code', 'AmazonEC2', '--region', 'us-east-1', '--profile', 'ec2-test', '--filters')
    $cliArgs += $ProductFilters
    $cliArgs += @('--output', 'json', '--no-cli-pager')
    $responseText = & aws @cliArgs
    if ($LASTEXITCODE -ne 0) {
        throw 'AWS pricing lookup failed. Stop here and share the error.'
    }
    $response = ($responseText -join "`n") | ConvertFrom-Json
    $rates = @(
        foreach ($entry in $response.PriceList) {
            $product = $entry | ConvertFrom-Json
            foreach ($term in $product.terms.OnDemand.PSObject.Properties) {
                foreach ($dimension in $term.Value.priceDimensions.PSObject.Properties) {
                    if ($dimension.Value.unit -eq $ExpectedUnit) {
                        [decimal]::Parse($dimension.Value.pricePerUnit.USD, [Globalization.CultureInfo]::InvariantCulture)
                    }
                }
            }
        }
    )
    if ($rates.Count -ne 1) {
        throw "Expected one price in units of $ExpectedUnit, but AWS returned $($rates.Count). Stop here and share this message."
    }
    return $rates[0]
}

$computeRate = Get-OnDemandRate -ExpectedUnit 'Hrs' -ProductFilters @(
    'Type=TERM_MATCH,Field=regionCode,Value=eu-north-1',
    'Type=TERM_MATCH,Field=instanceType,Value=t4g.micro',
    'Type=TERM_MATCH,Field=operatingSystem,Value=Linux',
    'Type=TERM_MATCH,Field=tenancy,Value=Shared',
    'Type=TERM_MATCH,Field=preInstalledSw,Value=NA',
    'Type=TERM_MATCH,Field=capacitystatus,Value=Used'
)

$storageRate = Get-OnDemandRate -ExpectedUnit 'GB-Mo' -ProductFilters @(
    'Type=TERM_MATCH,Field=regionCode,Value=eu-north-1',
    'Type=TERM_MATCH,Field=productFamily,Value=Storage',
    'Type=TERM_MATCH,Field=volumeApiName,Value=gp3'
)

# Use a 31-day month and the requested 12-hour daily operating window.
$computeCost = $computeRate * 12 * 31
# A retained Elastic IP is billed even while its instance is stopped.
$addressCost = [decimal]0.005 * 24 * 31
$diskCost = $storageRate * 8

[pscustomobject]@{
    Region = 'eu-north-1'
    Instance = 't4g.micro'
    ComputeUSDPerHour = $computeRate
    ComputeUSDPer31Days = [math]::Round($computeCost, 2)
    ElasticIPUSDPer31Days = [math]::Round($addressCost, 2)
    Disk8GiBUSDPerMonth = [math]::Round($diskCost, 2)
    BaseSubtotalUSD = [math]::Round(($computeCost + $addressCost + $diskCost), 2)
} | Format-List

Write-Output 'Base estimate only: excludes snapshots, S3, logs, alarms, threat detection, data transfer, tax, and recovery-test resources.'
Write-Output 'No free-tier credits, temporary trials, or discounts are assumed. No AWS resources were created.'
