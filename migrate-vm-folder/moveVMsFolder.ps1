
# Path to the folder to start
$datacenter = Get-Datacenter
$sourceFolder = Get-Folder -Name "Discovered virtual machine" -Location $datacenter

# Import csv with association VM -> folder
$vmMappings = Import-Csv -Path "C:\Users\absolute-path-to\csv_test.csv"


$sourceVMs = Get-VM -Location $sourceFolder

foreach ($vm in $sourceVMs) {
    $match = $vmMappings | Where-Object { $_.VMName -ceq $vm.Name }

    if ($match) {
        $targetFolderName = $match.destination_folder
        # Obtaining or creating destination folder 
        $targetFolder = Get-Folder -Name $targetFolderName -Location $datacenter -ErrorAction SilentlyContinue
        if (-not $targetFolder) {
            Write-Host "Folder '$targetFolderName' not found. Creating..."
            #$targetFolder = New-Folder -Name $targetFolderName -Location $datacenter
        }

        # Move VM
        Write-Host "Move VM '$($vm.Name)' to folder '$targetFolderName'"
        Move-VM -VM $vm -Destination $targetFolder -Confirm:$false
    }
    else {
        Write-Warning "The VM '$($vm.Name)' doesn't have a destination folder inside CSV. Skip."
    }
}

# Disconnect
#Disconnect-VIServer -Confirm:$false
