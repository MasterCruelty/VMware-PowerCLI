<# 
   The following script return a list of VMs and main info about them by giving an array of username.
   This is based on the fact you have a custom attribute named "vm.owner".
   The rest of missed vms are looked manually on vcenter and then by giving them in an array, the script recover their info.
#>   

#Bypass certificati
Set-PowerCLIConfiguration -InvalidCertificateAction:Ignore -Confirm:$false
    
# Connect to vCenter
Connect-VIServer -Server <vcsa-server> -user 'user' -password 'pwd'

# Define a list of usernames
$usernames = @('user1','user2','user3','user4','user5','user_n')

# Retrieve all VMs
$vms = Get-VM

# Filtering VMs by vm.owner custom attribute if it's in the usernames array.
$filteredVMs = @()
foreach ($vm in $vms) {
    $owner = Get-Annotation -Entity $vm -CustomAttribute 'vm.owner'
    if ($owner -and $usernames -contains $owner.Value) {
        $filteredVMs += $vm
    }
}

# Print all VMs found
$filteredVMs | Select-Object Name, 
                                @{Name='Owner';Expression={$_ | Get-Annotation -CustomAttribute 'vm.owner' | Select-Object -ExpandProperty Value}}, 
                                @{Name='CPU';Expression={$_.NumCpu}}, 
                                @{Name='MemoryGB';Expression={[math]::round($_.MemoryGB, 2)}},
                                @{Name='DiskGB';Expression={($_ | Get-HardDisk | Measure-Object -Property CapacityGB -Sum).Sum}},
								@{Name='RP';Expression={($_ | Get-ResourcePool)}},
								@{Name='Folder';Expression={($_ | Get-Folder)}} | 
                                Format-Table -AutoSize


#Missing Vms, I get those by VM name
$vmNames = @('vm1','vm2','vm3','vm_n')
$vms = Get-VM -Name $vmNames

# Create a new table with info required
$vms | Select-Object Name,
		      @{Name='Owner';Expression={$_ | Get-Annotation -CustomAttribute 'vm.owner' | Select-Object -ExpandProperty Value}},
                      @{Name='CPU';Expression={$_.NumCpu}}, 
                      @{Name='MemoryGB';Expression={[math]::round($_.MemoryGB, 2)}},
                      @{Name='DiskGB';Expression={($_ | Get-HardDisk | Measure-Object -Property CapacityGB -Sum).Sum}},
					  @{Name='RP';Expression={($_ | Get-ResourcePool)}},
					  @{Name='Folder';Expression={($_ | Get-Folder)}} |					  
                      Format-Table -AutoSize
					  
# Disconnect from vCenter
Disconnect-VIServer -Server <vcsa-server> -Confirm:$false
