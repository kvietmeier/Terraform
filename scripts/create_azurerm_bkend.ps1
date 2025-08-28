###
### Create Azure Storage BackEnd
### https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=powershell
###

$RGroupName='tfstate'
$SAcctName="tfstate$(Get-Random)"
$ContainerName='tfstate'
$Region="westus2"

# Create resource group
New-AzResourceGroup -Name $RGroupName -Location $Region

# Create storage account
$StorageAccount = New-AzStorageAccount -ResourceGroupName $RGroupName -Name $SAcctName -SkuName Standard_LRS -Location eastus -AllowBlobPublicAccess $true

# Create blob container
New-AzStorageContainer -Name $ContainerName -Context $StorageAccount.context -Permission blob

# Get the key - 
$ACCOUNT_KEY=(Get-AzStorageAccountKey -ResourceGroupName $RGroupName -Name $SAcctName)[0].value
$env:ARM_ACCESS_KEY=$ACCOUNT_KEY