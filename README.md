# 🖥️ Windows System Health Check & Monitoring Automation

A PowerShell-based **Windows System Health Check and Diagnostic Automation** tool designed to assess the overall health, performance, reliability, and basic security posture of a Windows endpoint.

The script automates multiple system-health checks and generates a structured **HTML health report**, making it easier for IT administrators, system engineers, and support teams to identify potential issues before they impact users.

## 🎯 Project Objective

The primary objective of this project is to reduce the amount of manual effort required for routine Windows endpoint health assessments.

Instead of manually checking CPU utilization, memory consumption, disk capacity, Windows services, event logs, system integrity, and network connectivity, this solution consolidates these checks into a single PowerShell automation workflow.

The script evaluates each component and categorizes the results into:

* 🟢 **PASS** – System/component is operating normally
* 🟠 **WARNING** – Potential issue requiring attention
* 🔴 **CRITICAL** – Immediate investigation may be required
* 🔵 **INFO** – Informational system details

## 🔍 Health Checks Performed

### 1. System Information

Collects essential information about the Windows endpoint, including:

* Computer name
* Operating system
* Windows version
* Last system boot time

This provides basic endpoint identification and helps determine system uptime.

### 2. CPU Utilization

The script evaluates current CPU utilization and categorizes the result based on predefined thresholds.

Example:

| CPU Usage | Status   |
| --------- | -------- |
| < 80%     | PASS     |
| 80–90%    | WARNING  |
| > 90%     | CRITICAL |

This helps identify systems experiencing unusually high processor utilization.

### 3. Memory Utilization

The script calculates:

* Total physical memory
* Available memory
* Used memory
* Overall memory utilization percentage

High memory utilization is flagged so that administrators can investigate resource-intensive applications or potential performance problems.

### 4. Disk Space Monitoring

All local fixed disks are scanned automatically.

The script calculates the percentage of available free space and identifies disks approaching capacity.

Example:

| Free Space | Status   |
| ---------- | -------- |
| > 20%      | PASS     |
| 10–20%     | WARNING  |
| < 10%      | CRITICAL |

This is particularly useful because low disk space can cause Windows performance issues, application failures, and update problems.

### 5. Critical Windows Services

The script checks the status of important Windows services, including:

* Windows Management Instrumentation (WMI)
* Windows Event Log
* Background Intelligent Transfer Service (BITS)
* Windows Update
* DHCP Client
* DNS Client

A stopped or unavailable service is reported for further investigation.

### 6. Windows Update Service

The health check verifies whether the Windows Update service is running.

This provides a basic indication of whether the endpoint is capable of communicating with Windows Update mechanisms.

> Note: This check validates the service state; it does not independently prove that the device is fully patch-compliant.

### 7. Network Connectivity

The script performs basic connectivity tests against external targets.

This helps identify potential network connectivity issues affecting the endpoint.

The test can help distinguish between:

* Local endpoint issues
* DNS-related issues
* Internet connectivity problems

### 8. Windows Event Log Analysis

The script reviews **System Event Logs** for recent error-level events.

By default, it examines errors from the previous 24 hours and reports the number of errors discovered.

This provides a quick way to identify recurring system-level problems without manually navigating through Event Viewer.

### 9. System File Integrity

The script uses Windows **System File Checker (SFC)** functionality to verify the integrity of protected Windows system files.

This can help identify potential corruption of critical operating-system components.

### 10. Windows Component Store Health

The script uses **DISM** to perform a basic component-store health check.

This helps identify potential corruption within the Windows component store, which can contribute to Windows servicing and system-repair issues.

---

# 📊 HTML Health Report

One of the key features of this project is automatic report generation.

After completing the health checks, the script generates an HTML report containing:

* System information
* Health-check results
* Status classifications
* Detailed findings
* Timestamp
* Computer name

The report can be opened directly in a web browser and shared with an IT support or operations team.

Example report structure:

```text
Windows System Health Report

Computer: DESKTOP-ABC123
Generated: 2026-09-10

---------------------------------------------------
Category          Check                  Status
---------------------------------------------------
System            Computer Name         INFO
System            Operating System      INFO
Performance       CPU Usage              PASS
Performance       Memory Usage           PASS
Storage           C: Free Space         WARNING
Services          Windows Update         PASS
Network           8.8.8.8                PASS
Event Logs        System Errors          WARNING
System Integrity  SFC Verification       PASS
System Integrity  DISM Health            PASS
---------------------------------------------------
```

# 🏗️ Technical Architecture

The solution follows a simple automation workflow:

```text
              ┌─────────────────────┐
              │  Windows Endpoint   │
              └──────────┬──────────┘
                         │
                         ▼
              ┌─────────────────────┐
              │ PowerShell Script   │
              └──────────┬──────────┘
                         │
        ┌────────────────┼────────────────┐
        │                │                │
        ▼                ▼                ▼
   Performance       Services         Storage
   CPU / RAM         WMI / BITS        Disk Space
        │                │                │
        └────────────────┼────────────────┘
                         │
        ┌────────────────┼────────────────┐
        │                │                │
        ▼                ▼                ▼
    Network          Event Logs       System Integrity
    Connectivity     Errors           SFC / DISM
        │                │                │
        └────────────────┼────────────────┘
                         ▼
              ┌─────────────────────┐
              │ Health Evaluation   │
              └──────────┬──────────┘
                         │
                         ▼
              ┌─────────────────────┐
              │ HTML Health Report  │
              └─────────────────────┘
```

# 🛠️ Technologies Used

* **PowerShell**
* Windows Management Instrumentation / CIM
* Windows Services
* Windows Event Logs
* SFC
* DISM
* PowerShell Objects
* HTML/CSS
* Windows networking utilities

# 🚀 Getting Started

## Prerequisites

* Windows 10 or Windows 11
* PowerShell 5.1 or PowerShell 7+
* Administrator privileges recommended
* Access to Windows system-management commands

## Installation

Clone the repository:

```powershell
git clone <YOUR-GITHUB-REPOSITORY-URL>
```

Navigate to the project directory:

```powershell
cd Windows-System-Health-Check
```

If PowerShell execution policy prevents the script from running, use a process-scoped policy change:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

Run the script:

```powershell
.\SystemHealthCheck.ps1
```

The generated HTML report will be saved to the user's Desktop.

# 📁 Project Structure

```text
Windows-System-Health-Check/
│
├── SystemHealthCheck.ps1
│
├── README.md
│
├── Reports/
│   └── .gitkeep
│
└── Screenshots/
    └── health-report.png
```

# 🔐 Security Considerations

This project is intended for **system administration, endpoint monitoring, and troubleshooting**.

The script performs diagnostic operations and does not intentionally modify system configuration.

However, commands such as SFC and DISM interact with protected Windows components and should be executed with appropriate privileges.

When extending this project with automated remediation, additional safeguards should be implemented to prevent unintended configuration changes.

# 📈 Future Enhancements

This project can be expanded into a more comprehensive endpoint-management solution.

Potential enhancements include:

### 🔹 Security Checks

* Windows Defender status
* Firewall status
* BitLocker encryption status
* Secure Boot status
* Local administrator account detection
* Antivirus health
* Security event-log analysis

### 🔹 Performance Monitoring

* Top CPU-consuming processes
* Top memory-consuming processes
* Disk I/O
* Network utilization
* System uptime
* Application crash detection

### 🔹 Patch Management

* Installed Windows updates
* Missing updates
* Last update installation date
* Reboot-pending detection
* Patch compliance status

### 🔹 Enterprise Automation

* Remote computer health checks
* Bulk endpoint assessment
* CSV reporting
* Centralized reporting
* Scheduled execution
* Email notifications
* Microsoft Teams notifications
* Integration with Microsoft Intune
* Integration with Microsoft Defender

### 🔹 Automated Remediation

Future versions could automatically remediate selected issues, such as:

```text
Detect Issue
     │
     ▼
Determine Severity
     │
     ▼
Attempt Remediation
     │
     ▼
Re-check System
     │
     ▼
Generate Report
```

For example, a future version could detect a stopped non-critical service, attempt to restart it, verify the result, and record the remediation action in the final report.

# 💼 Real-World Use Cases

This project can be used as a foundation for:

* IT help-desk troubleshooting
* Windows endpoint health assessments
* Desktop engineering
* Endpoint management
* System administration
* Proactive monitoring
* Incident troubleshooting
* Device onboarding validation
* Device offboarding validation
* Pre-maintenance health checks
* Post-maintenance validation

# 🎓 Skills Demonstrated

This project demonstrates practical knowledge of:

* PowerShell scripting
* Windows administration
* System diagnostics
* Endpoint monitoring
* Automation
* CIM/WMI
* Windows services
* Event Viewer/Event Logs
* Network troubleshooting
* Windows system integrity
* HTML report generation
* Conditional logic
* Error handling
* IT operations automation

# ⚠️ Disclaimer

This project is intended for educational, testing, and authorized IT administration purposes.

Always test automation scripts in a controlled environment before deploying them across production endpoints.

# 👨‍💻 Author

Adithya A.K.*

This project is part of a practical PowerShell and endpoint-management automation portfolio focused on developing real-world Windows administration and IT automation capabilities.
