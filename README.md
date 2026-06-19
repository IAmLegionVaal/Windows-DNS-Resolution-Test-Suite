# Windows DNS Resolution Test Suite

A read-only PowerShell toolkit for DNS resolution and response testing.

## Features

- A, AAAA, MX, and TXT record tests
- Multiple DNS targets
- Success, failure, and response-time reporting
- CSV, JSON, and HTML output

## Run

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\Windows_DNS_Resolution_Test_Suite.ps1
```

## Safety

Read-only DNS queries only. No DNS settings are changed.
