# ================================
# Login_Check_Script.ps1
# - 최근 N시간 동안 RDP 로그인 성공/실패 로그 수집
# - 콘솔 출력 + CSV 저장
# ================================

param(
    [int]$HoursBack = 6    # 기본: 최근 6시간
)

$startTime = (Get-Date).AddHours(-$HoursBack)

$filter = @{
    LogName   = 'Security'
    Id        = @(4624, 4625)   # 4624: 성공, 4625: 실패
    #StartTime = $startTime
    StartTime = (Get-Date).AddHours(-6)
}

Get-WinEvent -FilterHashtable $filter |
  Select-Object -First 5 |
  Format-List TimeCreated, Id, Message

# 이벤트 수집 & 파싱
$events = Get-WinEvent -FilterHashtable $filter | ForEach-Object {
    $xml   = [xml]$_.ToXml()
    $data  = $xml.Event.EventData.Data
    $eventId = $xml.Event.System.EventID.'#text'

    $logonType = ($data | Where-Object { $_.Name -eq 'LogonType' }).'#text'

    [pscustomobject]@{
        TimeCreated     = $_.TimeCreated
        EventId         = [int]$eventId
        Result          = if ($eventId -eq 4624) { 'Success' } else { 'Fail' }
        LogonType       = $logonType
        TargetUserName  = ($data | Where-Object { $_.Name -eq 'TargetUserName' }).'#text'
        IpAddress       = ($data | Where-Object { $_.Name -eq 'IpAddress' }).'#text'
        WorkstationName = ($data | Where-Object { $_.Name -eq 'WorkstationName' }).'#text'
        Status          = ($data | Where-Object { $_.Name -eq 'Status' }).'#text'
        SubStatus       = ($data | Where-Object { $_.Name -eq 'SubStatus' }).'#text'
    }
}

# RDP(LogonType 10)만 필터링
$rdpEvents = $events | Where-Object { $_.LogonType -eq '10' }

# =========================
# 1) 최근 RDP 로그인 성공 Top 10
# =========================
Write-Host "===== [RDP Success - Last $HoursBack hours] =====" -ForegroundColor Cyan
$rdpEvents |
    Where-Object { $_.Result -eq 'Success' } |
    Sort-Object TimeCreated -Descending |
    Select-Object -First 10 TimeCreated, TargetUserName, IpAddress, WorkstationName |
    Format-Table -AutoSize

# =========================
# 2) 최근 RDP 로그인 실패 Top 10
# =========================
Write-Host "`n===== [RDP Fail - Last $HoursBack hours] =====" -ForegroundColor Yellow
$rdpEvents |
    Where-Object { $_.Result -eq 'Fail' } |
    Sort-Object TimeCreated -Descending |
    Select-Object -First 10 TimeCreated, TargetUserName, IpAddress, Status, SubStatus |
    Format-Table -AutoSize

# =========================
# 3) 실패 공격 IP Top 10 (브루트포스 의심)
# =========================
Write-Host "`n===== [RDP Fail by IP - Top 10] =====" -ForegroundColor Red
$rdpEvents |
    Where-Object { $_.Result -eq 'Fail' -and $_.IpAddress -and $_.IpAddress -ne '-' } |
    Group-Object IpAddress |
    Sort-Object Count -Descending |
    Select-Object -First 10 @{Name='IpAddress';Expression={$_.Name}}, Count |
    Format-Table -AutoSize

# =========================
# 4) CSV로 전체 RDP 로그 저장
# =========================
$logDir = "C:\sec\logs"
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir | Out-Null
}

$filename = "$logDir\$(Get-Date -Format 'yyyy-MM-dd_HH-mm')_RDP_Login_Log.csv"
$rdpEvents | Export-Csv -NoTypeInformation -Path $filename -Encoding utf8

Write-Host "`n[+] CSV saved to: $filename" -ForegroundColor Green


##cd C:\sec
##.\Login_Check_Script.ps1           # 기본 6시간 기준
##.\Login_Check_Script.ps1 -HoursBack 24   # 최근 24시간으로 보고 싶을 때