# Windows-Security-Check-Script
Windows 엔드포인트 보안 점검용 PowerShell 스크립트입니다.

# Windows Security Healthcheck (PowerShell)

Windows 엔드포인트의 기본 보안 상태를 빠르게 점검하기 위한 PowerShell 스크립트 모음입니다.  
로컬 계정, 관리자 그룹, 방화벽, Microsoft Defender 상태, 보안 이벤트 로그 등을 한 번에 확인할 수 있도록 구성했습니다.

> ⚠️ 주의: 실제 회사 이름, 내부 IP, 서버 호스트명 등은 올리기 전에 반드시 마스킹/제거하세요.

---

## Features

- 📁 Local Users & Admin Group Check  
  - `Get-LocalUser` 로컬 사용자 계정 목록 출력  
  - `Get-LocalGroupMember Administrators` 로컬 관리자 계정 확인

- 🔥 Windows Firewall Profile Check  
  - `Get-NetFirewallProfile` 로 Public / Private / Domain 방화벽 상태 확인

- 🛡 Microsoft Defender Status  
  - `(Get-MpComputerStatus)` 로  
    - `AMServiceEnabled`
    - `AntispywareEnabled`
    - `AntivirusEnabled`
    - `RealTimeProtectionEnabled`
    - `BehaviorMonitorEnabled`  
    등 주요 보안 모듈 상태 확인

- 📜 Security Event Log Quick Review  
  - `Get-WinEvent -LogName Security -MaxEvents 10` 으로 최근 보안 이벤트 확인

- 🌐 Network Ports Overview  
  - `netstat -ano | findstr LISTENING` 으로 리스닝 포트 확인

---

## Files

- `Login_Check_Script.ps1`  
  - 최근 로그인/계정 및 기본 보안 설정 점검 스크립트 (예: 계정, 방화벽, Defender, 이벤트 로그 등)

- `internal_security_scan.ps1` (옵션)  
  - 추가로 nmap, trivy, YARA, osquery 등과 연동해 확장할 수 있는 내부 보안 점검 스크립트 템플릿

파일명은 실제 사용하는 이름에 맞게 수정해주세요.

---

## Usage

```powershell
# 관리자 PowerShell에서 실행
PS C:\sec> .\Login_Check_Script.ps1
