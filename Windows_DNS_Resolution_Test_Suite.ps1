#requires -Version 5.1
[CmdletBinding()]
param([string[]]$Names=@('www.microsoft.com','github.com'),[string[]]$Types=@('A','AAAA','MX','TXT'),[string]$OutputPath)
$stamp=Get-Date -Format 'yyyyMMdd_HHmmss'
if([string]::IsNullOrWhiteSpace($OutputPath)){$OutputPath=Join-Path ([Environment]::GetFolderPath('Desktop')) 'DNS_Test_Reports'}
New-Item -ItemType Directory -Path $OutputPath -Force|Out-Null
$rows=@()
foreach($name in $Names){foreach($type in $Types){$sw=[Diagnostics.Stopwatch]::StartNew();try{$answers=Resolve-DnsName -Name $name -Type $type -ErrorAction Stop;$sw.Stop();$rows+=[PSCustomObject]@{Name=$name;Type=$type;Success=$true;ResponseTimeMs=$sw.ElapsedMilliseconds;Result=(($answers|ForEach-Object{$_.IPAddress,$_.NameExchange,$_.Strings}|Where-Object{$_}) -join '; ');Error=$null}}catch{$sw.Stop();$rows+=[PSCustomObject]@{Name=$name;Type=$type;Success=$false;ResponseTimeMs=$sw.ElapsedMilliseconds;Result=$null;Error=$_.Exception.Message}}}}
$rows|Export-Csv (Join-Path $OutputPath "dns_results_$stamp.csv") -NoTypeInformation -Encoding UTF8
$rows|ConvertTo-Json -Depth 6|Set-Content (Join-Path $OutputPath "dns_results_$stamp.json") -Encoding UTF8
$html="<h1>DNS Resolution Test Suite</h1><p>Generated $(Get-Date)</p>$($rows|ConvertTo-Html -Fragment)"
$html|ConvertTo-Html -Title 'DNS Resolution Test Suite'|Set-Content (Join-Path $OutputPath "dns_results_$stamp.html") -Encoding UTF8
$rows|Format-Table -AutoSize
Write-Host "Reports saved to: $OutputPath" -ForegroundColor Green
