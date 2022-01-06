Param (
    [string]
    $domainName 
)

$resourceGroupName = "AVD-RG"
$location = "eastus"  
$VnetName = "aadds-vnet"
$userName = "odl_user_12345@$domainName"
$password = "D0m@!nAdm!n2021"

$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$PasswordProfile.Password = $password
Connect-AzureAD
New-AzureADUser -DisplayName "ODL User 12345" -PasswordProfile $PasswordProfile -UserPrincipalName $userName -AccountEnabled $true -MailNickName "WVDDomainAdmin"

$templateSourceLocation = "https://raw.githubusercontent.com/akhilthomas011/ARMTemplates/main/ADDS/deploy.json"


#Start creating Prerequisites 
#Register the provider 
Register-AzResourceProvider -ProviderNamespace Microsoft.AAD 

if(!($AADDSServicePrincipal = Get-AzADServicePrincipal -ApplicationId "2565bd9d-da50-47d4-8b85-4c97f669dc36")){ 
$AADDSServicePrincipal = New-AzADServicePrincipal -ApplicationId "2565bd9d-da50-47d4-8b85-4c97f669dc36" -ea SilentlyContinue} 

if(!($AADDSGroup = Get-AzADGroup -DisplayName "AAD DC Administrators")) 
{$AADDSGroup = New-AzADGroup -DisplayName "AAD DC Administrators" -Description "Delegated group to administer Azure AD Domain Services" -MailNickName "AADDCAdministrators" -ea SilentlyContinue}  


# Add the user to the 'AAD DC Administrators' group. 
Add-AzADGroupMember -MemberUserPrincipalName $userName -TargetGroupObjectId $($AADDSGroup).Id -ea SilentlyContinue  

New-AzResourceGroup -Name $resourceGroupName -Location $location -Force

$Params = @{ 

    "domainName" = $domainName 

} 

#Deploy the AADDS template 
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri $templateSourceLocation -TemplateParameterObject $Params #Deploy the template #Update Virtual Network DNS servers 

