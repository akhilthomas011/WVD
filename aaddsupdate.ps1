Param (
    [string]
    $domainName 
)

$resourceGroupName = "AVD-RG"
$VnetName = "aadds-vnet"
$userName = "odl_user_12345@$domainName"
$password = "D0m@!nAdm!n2021"

Install-Module AzureAD -Force

#Update Virtual Network DNS servers 
$Vnet = Get-AzVirtualNetwork -Name $VnetName -ResourceGroupName $resourceGroupName 
$Vnet.DhcpOptions.DnsServers = @() 
$NICs = Get-AzResource -ResourceGroupName $resourceGroupName -ResourceType "Microsoft.Network/networkInterfaces" -Name "aadds*" 
ForEach($NIC in $NICs){ 
$Nicip = (Get-AzNetworkInterface -Name $($NIC.Name) -ResourceGroupName $resourceGroupName).IpConfigurations[0].PrivateIpAddress
 ($Vnet.DhcpOptions.DnsServers).Add($Nicip) 

} 

$Vnet | Set-AzVirtualNetwork    

#Reset user password  
$securePassword = $password | ConvertTo-SecureString -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $userName, $SecurePassword
Connect-AzureAD -Credential $cred | Out-Null
Set-AzureADUserPassword -ObjectId (Get-AzADUser -UserPrincipalName $userName).Id -Password $securePassword
