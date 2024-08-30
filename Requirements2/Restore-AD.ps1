#made by Breanna Chase, student ID 011725162

#import the active directory module so the finance OU can be created and deleted
Import-Module ActiveDirectory

#check to see if the finance OU exists by looking for the Finance OU name and storing it in a string variable
Write-host "Checking to see if the Finance OU exists..."
$FinanceOUName = Get-ADOrganizationalUnit -Filter {Name -like "Finance"}

#if the finance OU exists delete it, else just inform the user there is not a finance OU
if ($FinanceOUName) {
    Remove-ADOrganizationalUnit -Identity "OU=Finance" -Recursive
    Write-Host "The Finance OU was found and deleted"
}
else {
    Write-Host "No Finance OU exists"
}

#Create the finance OU
Write-Host "Creating the Finance OU..."
New-ADOrganizationalUnit -Name "Finance"
Write-Host "The Finance OU has been created"





