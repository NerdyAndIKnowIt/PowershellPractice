<#
made by Breanna Chase, student ID 011725162
#>
try {
    #check for the existance of the finance OU
    $OUName = "ou=Finance,dc=consultingfirm,dc=com"
    $OUFinanceExists = Get-ADOrganizationalUnit -Filter {Name -eq "Finance"} -ErrorAction SilentlyContinue 
    #"ErrorAction SilentlyContinue" will bypass any error if the finance OU does not exist

    if ($OUFinanceExists) {
        Write-Host "OU finance exists"
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

    foreach ($user in $csvData) {
        #create the display name using the first and last name
        $DisplayName = "$($user.First_Name) $($user.Last_Name)"

        #as each row is iterated through in financePersonnel.csv, create a new user with New-ADUser
        New-ADUser  -GivenName = $user.First_Name `
            -Surname $user.Last_Name `
            -DisplayName $DisplayName `
            -SamAccountName $user.samAccount `
            -PostalCode $user.PostalCode `
            -OfficePhone $user.OfficePhone `
            -MobilePhone $user.MobilePhone `
            -Path $OUName `
            -AccountPassword (ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force) `
            -Enabled $true
        
    }

    #generate an output file for submission
    Get-ADUser -Filter * -SearchBase $OUName -Properties DisplayName,PostalCode,OfficePhone,MobilePhone | 
        Select-Object DisplayName, PostalCode, OfficePhone, MobilePhone |
        Out-File -FilePath ".\AdResults.txt"

    Write-Host "adResults.txt has been updated"
}
#if there is an error at any time during execution, display it to the console
catch {
    Write-Host "There was an error: "
    Write-Host $_.Exception.Message
    Exit
}