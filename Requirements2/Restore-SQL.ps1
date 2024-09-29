<#
made by Breanna Chase, student ID 011725162
#>

#path to the CSV file
$csvPath =  ".\NewClientData.csv"

#check if client DB exists
try {
    $dbExists = Invoke-Sqlcmd - Query "select name from sys.database where name 'ClientDB'" -ServerInstance "localhost\SQLEXPRESS"

    if ($dbExists) {
        Write-Host "ClientDB database already exists, deleting it now"
        Invoke-Sqlcmd -Query "drop database ClientDB" -ServerInstance "localhost\SQLEXPRESS"
        Write-Host "ClientDB database has been deleted"
    }
    else {
        Write-Host "ClientDB database does not exist"
    }

    #create a new database called ClientDB
    Invoke-Sqlcmd -Query "create database ClientDB" -ServerInstance "localhost\SQLEXPRESS"
    Write-Host "Database ClientDB has been created"

    #create a table called Client_A_Contacts
    Invoke-Sqlcmd -Database ClientDB -Query @"
        create table dbo.Client_A_Contacts (
            FirstName nvarchar(25)
            LastName nvarchar(25)
            City nvarchar(25)
            Country nvarchar(25)
            Zip nvarchar(5)
            officePhone nvarchar(10)
            mobilePhone nvarchar(10)
        )
"@ -ServerInstance "localhost\SQLEXPRESS"
    Write-Host "the Client_A_Contacts table has been created"

    #insert data from csv into the table
    $csvData = Import-Csv -Path $csvPath
    foreach ($row in $csvData) {
        Invoke-Sqlcmd -Database ClientDB @"
            insert into dbo.Client_A_Contacts (FirstName, LastName, City, Country, Zip, officePhone, mobilePhone)
            values ('$($row.FirstName)','$($row.LastName)','$($row.City)','$($row.Country)','$($row.Zip)','$($row.officePhone)','$($row.mobilePhone)')
"@ -ServerInstance "localhost\SQLEXPRESS"
    }
    Write-Host "client data was imported into Client_A_Contacts from the NewClientData.csv file"

    #generate an output file
    Invoke-Sqlcmd -Database ClientDB -ServerInstance "localhost\SQLEXPRESS" -Query "select * from dbo.Client_A_Contacts" > .\SqlResults.txt
    Write-Host "results have been written to SqlResults.txt"

} catch {
    Write-Host "there was an error: $_"
}