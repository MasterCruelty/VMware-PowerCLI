#This just extracts the corresponding folder of every Virtual Machine in you vsphere environment.
#So you can migrate in the correct folder if you change infrastructure.

$parentFolder = Get-Folder -Name "<FOLDER-NAME>"
$childFolders = Get-Folder -Location $parentFolder | Where-Object { $_.Type -eq "VM" }

$results = foreach ($folder in $childFolders) {
    Get-VM -Location $folder | ForEach-Object {
        [PSCustomObject]@{
            Folder = $folder.Name
            VMName = $_.Name
			Owner = (Get-Annotation -Entity $_ -CustomAttribute "vm.owner" -ErrorAction SilentlyContinue).Value
        }
    }
}

$results | Export-Csv -Path "C:\Users\absolute-path-to\csv_test_MoveFolder.csv" -NoTypeInformation -Encoding UTF8
