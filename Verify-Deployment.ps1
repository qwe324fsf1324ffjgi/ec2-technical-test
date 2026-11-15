param([string]$Profile = 'ec2-test', [string]$Region = 'eu-north-1')
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot
$failures = 0
New-Item -ItemType Directory -Path .\evidence -Force | Out-Null
$stamp = (Get-Date).ToUniversalTime().ToString('yyyyMMdd-HHmmss')
function Read-TerraformOutput([string]$Name) {
    $text = terraform output -raw $Name
    if ($LASTEXITCODE -ne 0) { throw "Cannot read Terraform output $Name. Initialize the correct backend first." }
    return ($text -join "`n").Trim()
}
function Save-AwsCheck([string]$Name, [string[]]$Arguments) {
    Write-Host "`nCHECK: $Name"
    $result = & aws @Arguments --profile $Profile --region $Region --output json --no-cli-pager
    if ($LASTEXITCODE -ne 0) {
        $script:failures++
        Write-Warning "$Name request failed; it is not a pass."
        return
    }
    $result | Set-Content -LiteralPath ".\evidence\$stamp-$Name.json" -Encoding UTF8
    $result | Out-Host
}
$identityText = aws sts get-caller-identity --profile $Profile --output json --no-cli-pager
if ($LASTEXITCODE -ne 0) { throw 'AWS identity lookup failed.' }
$identity = ($identityText -join "`n") | ConvertFrom-Json
$expected = Read-TerraformOutput 'connected_account_id'
if ($identity.Account -ne $expected) { throw 'Profile account does not match the initialized deployment.' }
$instance = Read-TerraformOutput 'website_instance_id'
$policy = Read-TerraformOutput 'disk_backup_policy_id'
$detector = Read-TerraformOutput 'guardduty_detector_id'
Save-AwsCheck 'alarms' @('cloudwatch','describe-alarms','--alarm-name-prefix','ec2-test-','--query','MetricAlarms[].{Name:AlarmName,State:StateValue}')
Save-AwsCheck 'patch-state' @('ssm','describe-instance-patch-states','--instance-ids',$instance)
Save-AwsCheck 'guardduty' @('guardduty','get-detector','--detector-id',$detector)
$volumeText = aws ec2 describe-instances --profile $Profile --region $Region --instance-ids $instance --query 'Reservations[0].Instances[0].{Root:RootDeviceName,Mappings:BlockDeviceMappings}' --output json --no-cli-pager
if ($LASTEXITCODE -ne 0) { throw 'Root-volume lookup failed.' }
$disk = ($volumeText -join "`n") | ConvertFrom-Json
$rootVolumes = @($disk.Mappings | Where-Object { $_.DeviceName -eq $disk.Root })
if ($rootVolumes.Count -ne 1) { throw 'Could not uniquely identify current root volume.' }
$volume = $rootVolumes[0].Ebs.VolumeId
Save-AwsCheck 'dlm-root-snapshots' @('ec2','describe-snapshots','--owner-ids','self','--filters',"Name=volume-id,Values=$volume", "Name=tag:aws:dlm:lifecycle-policy-id,Values=$policy",'--query','Snapshots[].{Snapshot:SnapshotId,State:State,Started:StartTime,Volume:VolumeId,Encrypted:Encrypted}')
Save-AwsCheck 'website-alarm-history' @('cloudwatch','describe-alarm-history','--alarm-name','ec2-test-website-failure','--max-records','10')
Write-Host "`nRequest failures: $failures. Evidence saved under evidence/."
Write-Host 'Review all results. A completed DLM snapshot of the current root disk is required; empty results are not success.'
Write-Host 'MFA, recipient inbox receipt, costs and second-account deployment require separate verification.'
if ($failures -gt 0) { throw 'One or more evidence requests failed.' }
