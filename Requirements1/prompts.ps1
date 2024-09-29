#made by Breanna Chase, student ID 011725162

#try this code, if the script fails display the error message in the catch block
try {
    #repeat asking the switch statement in a do while loop until the user presses 5 to exit
    do {
        
    
        #display menu options
        Write-Host "Choose an option:"
        Write-Host "1: List log files and append to DailyLog.txt"
        Write-Host "2: List files in Requirements1 folder in C916contents.txt"
        Write-Host "3: Display CPU and memory usage"
        Write-Host "4: Display all running processes"
        Write-Host "5: Exit"

        #Capture user input
        $choice = Read-Host "Enter your choice"

        #this is my switch statement, switching between what the user chooses using the $choice variable
        switch ($choice) {
            #if the user chooses option 1...
            1 {
                #get the date and time, then store it in the date variable
                $date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                #get the file names ending with .log in the Requirements1 folder and store them in the logfiles variable
                $logFiles = Get-ChildItem -Filter "*.log"
                #add the content of the logfiles variable to the DailyLog.txt file
                #added -Encoding ASCII to stop weird formatting problems I was having, didn't have the same issue with C916contents.txt oddly
                $logFiles | Out-File -FilePath "DailyLog.txt" -Append -Encoding ASCII
                #add the date and time to the end of the logs, and add a new line character
                Add-Content -Path "DailyLog.txt" -Value "`n$date`n"
            }
            #if the user chooses option 2...
            2 {
                #get all the files inside current directory (the requirements folder), sort them by name, format them in a table format, then place the contents in c916contents.txt
                Get-ChildItem -Path "." | Sort-Object Name | Format-Table Name, Length, LastWriteTime | Out-File "C916contents.txt"
            }
            #if the user chooses option 3...
            3 {
                #list the average CPU usage
                Get-WmiObject Win32_Processor | Measure-Object -Property LoadPercentage -Average | Select-Object @{Name="Average CPU Usage"; Expression={$_.Average}}
                #list the memory usage
                Get-WmiObject -Class Win32_OperatingSystem | Format-Table TotalVisibleMemorySize, FreePhysicalMemory
            }
            #if the user chooses option 4...
            4 {
                #get all the running processes, sort them in descending order, and place them in a grid view
                Get-Process | Select-Object ID, Name, VM | Sort-Object VM | Out-GridView
            }
            #if the user chooses option 5...
            5 {
                #exit the script
                Write-Host "Quiting"
            }
            #catch any invalid user input and ask them to try again
            default {
                Write-Host "That wasn't an option, please try again"
            }
        }
    #repeat asking the switch statement in a do while loop until the user presses 5 to exit
    } while ($choice -ne 5)
}
#if there is an error running the program, display the error message
catch [System.OutOfMemoryException] {
    Write-Host "The system is out of memory"
}
