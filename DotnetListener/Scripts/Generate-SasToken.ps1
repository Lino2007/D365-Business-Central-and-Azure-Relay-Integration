# usage example: .\Generate-SasToken.ps1 -URI 'contosorelay.servicebus.windows.net/contosohc' -AccessPolicyName 'RootManageSharedAccessKey' -AccessPolicyKey 'PrimaryKey' -DurationInMinutes 15
Param(
    [string] $URI,
    [string] $AccessPolicyName,
    [string] $AccessPolicyKey,
    [integer] $ExpirationInMinutes = 15
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