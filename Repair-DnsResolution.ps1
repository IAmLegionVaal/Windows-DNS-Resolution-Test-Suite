#requires -Version 5.1
<# Created by Dewald Pretorius. Guarded Windows DNS client recovery with verification. #>
[CmdletBinding(SupportsShouldProcess=$true)]
param([ValidateSet('Diagnose','FlushDns','RegisterDns')][string]$Action='Diagnose',[string[]]$Names=@('login.microsoftonline.com','www.microsoft.com'),[string]$OutputPath=(Join-Path ([Environment]::GetFolderPath('Desktop')) 'DNS_Resolution_Repair'))
$ErrorActionPreference='Stop';New-Item -ItemType Directory $OutputPath -Force|Out-Null;$s=Get-Date -Format yyyyMMdd_HHmmss
function Test-Names{foreach($n in $Names){[pscustomobject]@{Name=$n;Resolved=[bool](Resolve-DnsName $n -ErrorAction SilentlyContinue)}}}
$before=@(Test-Names);$before|Export-Csv (Join-Path $OutputPath "before_$s.csv") -NoTypeInformation
if($Action-eq'Diagnose'){exit 0}
try{if($Action-eq'FlushDns'-and$PSCmdlet.ShouldProcess('DNS client cache','Clear')){Clear-DnsClientCache}elseif($Action-eq'RegisterDns'-and$PSCmdlet.ShouldProcess('DNS client registrations','Refresh')){& ipconfig.exe /registerdns;if($LASTEXITCODE-ne 0){throw "ipconfig exited $LASTEXITCODE"}}}catch{Write-Error $_;exit 5}
$after=@(Test-Names);$after|Export-Csv (Join-Path $OutputPath "after_$s.csv") -NoTypeInformation;if(@($after|Where-Object Resolved).Count-eq 0){exit 6};exit 0
