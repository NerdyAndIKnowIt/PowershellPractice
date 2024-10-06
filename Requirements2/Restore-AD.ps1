<#
made by Breanna Chase, student ID 011725162
#>

#check for the existance of the finance OU
$OUName = "ou=Finance,dc=consultingfirm,dc=com"
$OUFinanceExists = Get-ADOrganizationalUnit -Filter {Name -eq "Finance"} -ErrorAction SilentlyContinue 
#"ErrorAction SilentlyContinue" will bypass any error if the finance OU does not exist

if ($OUFinanceExists) {
    Write-Host "OU finance exists"
    # Set-ADOrganizationalUnit -Identity $OUName -ProtectedFromAccidentialDeletion $false
    Remove-ADOrganizationalUnit -Identity $OUName -Recursive -Confirm:$false
    Write-Host "OU finance has been deleted"
}
else {
    Write-Host "OU finance does not exist"
}

#create the finance OU
New-ADOrganizationalUnit -Name "Finance" -Path "DC=consultingfirm,DC=com" -ProtectedFromAccidentalDeletion $False
Write-Host "OU finance created"

#import users from financePersonnel.csv file into the finance OU
$csvPath = Join-Path -Path (Get-Location) -ChildPath "\financePersonnel.csv"
$csvData = Import-Csv -Path $csvPath

Write-Host $csvPath
Write-Host $csvData
foreach ($row in $csvData) {
    $DisplayName = "$($row.First_Name) $($row.Last_Name)"

    New-ADUser -GivenName $row.First_Name `
        -Surname $row.Last_Name `
        -DisplayName $DisplayName `
        -SamAccountName $samAccount `
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