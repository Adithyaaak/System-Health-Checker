# ============================================================
# Windows System Health Check
# Version: 1.0
# ============================================================

$ComputerName = $env:COMPUTERNAME
$TimeStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$ReportPath = "$env:USERPROFILE\Desktop\System_Health_Report_$TimeStamp.html"

$Results = @()

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "       WINDOWS SYSTEM HEALTH CHECK" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# ------------------------------------------------------------
# 1. System Information
# ------------------------------------------------------------

Write-Host "[1/10] Collecting system information..." -ForegroundColor Yellow

$OS = Get-CimInstance Win32_OperatingSystem
$Computer = Get-CimInstance Win32_ComputerSystem

$Results += [PSCustomObject]@{
    Category = "System"
    Check    = "Computer Name"
    Status   = "INFO"
    Details  = $ComputerName
}

$Results += [PSCustomObject]@{
    Category = "System"
    Check    = "Operating System"
    Status   = "INFO"
    Details  = $OS.Caption
}

$Results += [PSCustomObject]@{
    Category = "System"
    Check    = "OS Version"
    Status   = "INFO"
    Details  = $OS.Version
}

$Results += [PSCustomObject]@{
    Category = "System"
    Check    = "Last Boot Time"
    Status   = "INFO"
    Details  = $OS.LastBootUpTime
}

# ------------------------------------------------------------
# 2. CPU Usage
# ------------------------------------------------------------

Write-Host "[2/10] Checking CPU usage..." -ForegroundColor Yellow

$CPU = Get-CimInstance Win32_Processor |
       Measure-Object -Property LoadPercentage -Average

$CPUUsage = [math]::Round($CPU.Average,2)

if ($CPUUsage -lt 80) {
    $CPUStatus = "PASS"
}
elseif ($CPUUsage -lt 90) {
    $CPUStatus = "WARNING"
}
else {
    $CPUStatus = "CRITICAL"
}

$Results += [PSCustomObject]@{
    Category = "Performance"
    Check    = "CPU Usage"
    Status   = $CPUStatus
    Details  = "$CPUUsage %"
}

# ------------------------------------------------------------
# 3. Memory Usage
# ------------------------------------------------------------

Write-Host "[3/10] Checking memory usage..." -ForegroundColor Yellow

$TotalMemory = [math]::Round($OS.TotalVisibleMemorySize / 1MB,2)
$FreeMemory  = [math]::Round($OS.FreePhysicalMemory / 1MB,2)
$UsedMemory  = [math]::Round($TotalMemory - $FreeMemory,2)

$MemoryUsage = [math]::Round(($UsedMemory / $TotalMemory) * 100,2)

if ($MemoryUsage -lt 80) {
    $MemoryStatus = "PASS"
}
elseif ($MemoryUsage -lt 90) {
    $MemoryStatus = "WARNING"
}
else {
    $MemoryStatus = "CRITICAL"
}

$Results += [PSCustomObject]@{
    Category = "Performance"
    Check    = "Memory Usage"
    Status   = $MemoryStatus
    Details  = "$MemoryUsage % ($UsedMemory GB / $TotalMemory GB)"
}

# ------------------------------------------------------------
# 4. Disk Space
# ------------------------------------------------------------

Write-Host "[4/10] Checking disk space..." -ForegroundColor Yellow

$Disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3"

foreach ($Disk in $Disks) {

    $FreePercent = [math]::Round(
        ($Disk.FreeSpace / $Disk.Size) * 100,2
    )

    if ($FreePercent -gt 20) {
        $DiskStatus = "PASS"
    }
    elseif ($FreePercent -gt 10) {
        $DiskStatus = "WARNING"
    }
    else {
        $DiskStatus = "CRITICAL"
    }

    $Results += [PSCustomObject]@{
        Category = "Storage"
        Check    = "$($Disk.DeviceID) Free Space"
        Status   = $DiskStatus
        Details  = "$FreePercent % free"
    }
}

# ------------------------------------------------------------
# 5. Important Windows Services
# ------------------------------------------------------------

Write-Host "[5/10] Checking critical services..." -ForegroundColor Yellow

$CriticalServices = @(
    "Winmgmt",
    "EventLog",
    "BITS",
    "wuauserv",
    "Dhcp",
    "Dnscache"
)

foreach ($ServiceName in $CriticalServices) {

    $Service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue

    if ($null -eq $Service) {

        $Status = "NOT FOUND"
        $Details = "Service does not exist"

    }
    elseif ($Service.Status -eq "Running") {

        $Status = "PASS"
        $Details = "Running"

    }
    else {

        $Status = "WARNING"
        $Details = "Status: $($Service.Status)"
    }

    $Results += [PSCustomObject]@{
        Category = "Services"
        Check    = $ServiceName
        Status   = $Status
        Details  = $Details
    }
}

# ------------------------------------------------------------
# 6. Windows Update Service
# ------------------------------------------------------------

Write-Host "[6/10] Checking Windows Update..." -ForegroundColor Yellow

$WUService = Get-Service -Name "wuauserv" -ErrorAction SilentlyContinue

if ($WUService.Status -eq "Running") {

    $WUStatus = "PASS"
    $WUDetails = "Windows Update service is running"

}
else {

    $WUStatus = "WARNING"
    $WUDetails = "Windows Update service is not running"
}

$Results += [PSCustomObject]@{
    Category = "Windows Update"
    Check    = "Windows Update Service"
    Status   = $WUStatus
    Details  = $WUDetails
}

# ------------------------------------------------------------
# 7. Network Connectivity
# ------------------------------------------------------------

Write-Host "[7/10] Testing network connectivity..." -ForegroundColor Yellow

$PingTargets = @(
    "8.8.8.8",
    "www.microsoft.com"
)

foreach ($Target in $PingTargets) {

    $Ping = Test-Connection -ComputerName $Target `
                            -Count 2 `
                            -Quiet `
                            -ErrorAction SilentlyContinue

    if ($Ping) {
        $NetStatus = "PASS"
        $NetDetails = "Connectivity available"
    }
    else {
        $NetStatus = "CRITICAL"
        $NetDetails = "Unable to reach target"
    }

    $Results += [PSCustomObject]@{
        Category = "Network"
        Check    = $Target
        Status   = $NetStatus
        Details  = $NetDetails
    }
}

# ------------------------------------------------------------
# 8. Recent System Errors
# ------------------------------------------------------------

Write-Host "[8/10] Checking recent system errors..." -ForegroundColor Yellow

$Errors = Get-WinEvent -FilterHashtable @{
    LogName   = "System"
    Level     = 2
    StartTime = (Get-Date).AddHours(-24)
} -ErrorAction SilentlyContinue

$ErrorCount = ($Errors | Measure-Object).Count

if ($ErrorCount -eq 0) {
    $EventStatus = "PASS"
}
elseif ($ErrorCount -lt 10) {
    $EventStatus = "WARNING"
}
else {
    $EventStatus = "CRITICAL"
}

$Results += [PSCustomObject]@{
    Category = "Event Logs"
    Check    = "System Errors (Last 24 Hours)"
    Status   = $EventStatus
    Details  = "$ErrorCount errors found"
}

# ------------------------------------------------------------
# 9. Windows System File Check
# ------------------------------------------------------------

Write-Host "[9/10] Checking Windows system files..." -ForegroundColor Yellow

$SFCOutput = sfc.exe /verifyonly 2>&1 | Out-String

if ($SFCOutput -match "did not find any integrity violations") {
    $SFCStatus = "PASS"
    $SFCDetails = "No integrity violations detected"
}
else {
    $SFCStatus = "WARNING"
    $SFCDetails = "Review SFC output"
}

$Results += [PSCustomObject]@{
    Category = "System Integrity"
    Check    = "SFC Verification"
    Status   = $SFCStatus
    Details  = $SFCDetails
}

# ------------------------------------------------------------
# 10. DISM Health Check
# ------------------------------------------------------------

Write-Host "[10/10] Checking Windows component health..." -ForegroundColor Yellow

$DISMOutput = DISM.exe /Online /Cleanup-Image /CheckHealth 2>&1 |
              Out-String

if ($DISMOutput -match "No component store corruption detected") {

    $DISMStatus = "PASS"
    $DISMDetails = "Windows component store is healthy"

}
else {

    $DISMStatus = "WARNING"
    $DISMDetails = "Potential component store issue detected"

}

$Results += [PSCustomObject]@{
    Category = "System Integrity"
    Check    = "DISM Health"
    Status   = $DISMStatus
    Details  = $DISMDetails
}

# ------------------------------------------------------------
# Generate HTML Report
# ------------------------------------------------------------

Write-Host ""
Write-Host "Generating report..." -ForegroundColor Green

$HTML = @"
<html>
<head>

<title>Windows System Health Report</title>

<style>

body {
    font-family: Arial;
    margin: 30px;
    background-color: #f4f6f8;
}

h1 {
    color: #1f2937;
}

table {
    border-collapse: collapse;
    width: 100%;
    background: white;
}

th {
    background-color: #1f2937;
    color: white;
    padding: 10px;
}

td {
    padding: 10px;
    border: 1px solid #ddd;
}

.PASS {
    color: green;
    font-weight: bold;
}

.WARNING {
    color: orange;
    font-weight: bold;
}

.CRITICAL {
    color: red;
    font-weight: bold;
}

.INFO {
    color: blue;
    font-weight: bold;
}

</style>

</head>

<body>

<h1>Windows System Health Report</h1>

<p><b>Computer:</b> $ComputerName</p>
<p><b>Generated:</b> $(Get-Date)</p>

<table>

<tr>
<th>Category</th>
<th>Check</th>
<th>Status</th>
<th>Details</th>
</tr>

"@

foreach ($Result in $Results) {

    $HTML += @"
<tr>
<td>$($Result.Category)</td>
<td>$($Result.Check)</td>
<td class="$($Result.Status)">$($Result.Status)</td>
<td>$($Result.Details)</td>
</tr>
"@
}

$HTML += @"

</table>

</body>
</html>
"@

$HTML | Out-File -FilePath $ReportPath -Encoding UTF8

# ------------------------------------------------------------
# Console Summary
# ------------------------------------------------------------

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "          HEALTH CHECK COMPLETE" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

$Results | Format-Table -AutoSize

Write-Host ""
Write-Host "Report saved to:" -ForegroundColor Green
Write-Host $ReportPath -ForegroundColor White

# Open report
Start-Process $ReportPath