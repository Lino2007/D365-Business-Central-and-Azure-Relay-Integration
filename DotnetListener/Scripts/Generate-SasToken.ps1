# usage example: .\Generate-SasToken.ps1 -URI 'https://demo-relay.servicebus.windows.net/demo-hc' -AccessPolicyName 'demo-hc-policy' -AccessPolicyKey '<hybrid-connection-primary-key>'
Param(
    [string] $URI,
    [string] $AccessPolicyName,
    [string] $AccessPolicyKey,
    [int] $ExpirationInMinutes = 15
)
[Reflection.Assembly]::LoadWithPartialName("System.Web") | out-null

#Token expires now + ExpirationInMinutes
$Expires=([DateTimeOffset]::Now.ToUnixTimeSeconds())+ (60 * $ExpirationInMinutes)
$SignatureString=[System.Web.HttpUtility]::UrlEncode($URI)+ "`n" + [string]$Expires
$HMAC = New-Object System.Security.Cryptography.HMACSHA256
$HMAC.key = [Text.Encoding]::ASCII.GetBytes($AccessPolicyKey)
$Signature = $HMAC.ComputeHash([Text.Encoding]::ASCII.GetBytes($SignatureString))
$Signature = [Convert]::ToBase64String($Signature)
$SASToken = "SharedAccessSignature sr=" + [System.Web.HttpUtility]::UrlEncode($URI) + "&sig=" + [System.Web.HttpUtility]::UrlEncode($Signature) + "&se=" + $Expires + "&skn=" + $AccessPolicyName
$SASToken