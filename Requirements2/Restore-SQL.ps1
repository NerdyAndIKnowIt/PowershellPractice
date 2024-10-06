<#
made by Breanna Chase, student ID 011725162
#>

$databaseName = "ClientDB"
$serverInstance = "localhost\SQLEXPRESS"

#path to the CSV file
$csvPath =  ".\NewClientData.csv"

#check if client DB exists
try {
    $dbExists = Get-SqlDatabase -ServerInstance $serverInstance -Database $databaseName

    if ($null -eq $dbExists) {

        Write-Host "ClientDB database does not exist"
    }
    else {
        Write-Host "ClientDB database already exists, deleting it"
        Invoke-Sqlcmd -Query "alter database ClientDB set single_user with rollback immediate; drop database ClientDB;" -ServerInstance $serverInstance
        Write-Host "ClientDB database has been deleted"
    }

    #create a new database called ClientDB
    Invoke-Sqlcmd -Query "create database ClientDB" -ServerInstance $serverInstance
    Write-Host "Database ClientDB has been created"

    #create a table called Client_A_Contacts
    Invoke-Sqlcmd -Database $databaseName -ServerInstance $serverInstance -Query @"
        create table Client_A_Contacts (
            first_name nvarchar(25),
            last_name nvarchar(25),
            city nvarchar(25),
            county nvarchar(25),
            zip varchar(5),
            officePhone nvarchar(12),
            mobilePhone nvarchar(12)
        )
"@
    Write-Host "the Client_A_Contacts table has been created"

    #insert data from csv into the table
    $csvData = Import-Csv -Path $csvPath
    foreach ($row in $csvData) {
        Invoke-Sqlcmd -Database ClientDB @"
            insert into Client_A_Contacts (first_name, last_name, city, county, zip, officePhone, mobilePhone)
            values ('$($row.first_name)','$($row.last_name)','$($row.city)','$($row.county)','$($row.zip)','$($row.officePhone)','$($row.mobilePhone)')
"@ -ServerInstance $serverInstance
    }
    Write-Host "client data was imported into Client_A_Contacts from the NewClientData.csv file"

    #generate an output file
    Invoke-Sqlcmd -Database ClientDB -ServerInstance $serverInstance -Query "select * from dbo.Client_A_Contacts" > .\SqlResults.txt
    Write-Host "results have been written to SqlResults.txt"

} 
#catch any errors and write them to the console
catch {
    Write-Host "there was an error: $_"
}