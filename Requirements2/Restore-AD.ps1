<#
made by Breanna Chase, student ID 011725162
#>

#check for the existance of the finance OU
$OUName = "ou=finance,dc=consultingfirm,dc=com"
$OUFinanceExists = Get-ADOrganizationalUnit -Filter {Name -eq "finance"} -ErrorAction SilentlyContinue 
#"ErrorAction SilentlyContinue" will bypass any error if the finance OU does not exist

if ($OUFinanceExists) {
    Write-Host "OU Finance exists"
    Remove-ADOrganizationalUnit -Identity $OUName -Recursive -Confirm:$false
    Write-Host "OU Finance has been deleted"
}
else {
    Write-Host "OU Finance does not exist"
}

#create the finance OU
New-ADOrganizationalUnit -Name "Finance" -Path "DC=consultingfirm,DC=com"
Write-Host "OU Finance created"

#import users from financePersonnel.csv file into the finance OU
$csvPath = ".\financePersonnel.csv"
$csvData = Import-Csv -Path $csvPath
foreach ($row in $csvData) {
    $DisplayName = "$($row.FirstName) $($row.LastName)"

    New-ADUser -GivenName $row.FirstName `
        -Surname $row.LastName `
        -DisplayName $DisplayName `
        -PostalCode $row.PostalCode `
        -OfficePhone $row.OfficePhone `
        -MobilePhone $row.MobilePhone `
        -Path $OUName `
        -AccountPassword (ConvertTo-SecureString "password" -AsPlainText -Force) `
        -Enabled $true
}

#generate an output file for submission
Get-ADUser -Filter * -SearchBase $OUName -Properties DisplayName,PostalCode,OfficePhone,MobilePhone | 
    Select-Object DisplayName, PostalCode, OfficePhone, MobilePhone |
    Out-File -FilePath ".\AdResults.txt"

Write-Host "adResults.txt has been updated"