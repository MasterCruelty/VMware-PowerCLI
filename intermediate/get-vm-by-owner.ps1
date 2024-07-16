<# 
   The following script return a list of VMs and main info about them by giving an array of username.
   This is based on the fact you have a custom attribute named "vm.owner".
   The rest of missed vms are looked manually on vcenter and then by giving them in an array, the script recover their info.
#>   

#Bypass certificati
Set-PowerCLIConfiguration -InvalidCertificateAction:Ignore -Confirm:$false
    
# Connettersi al server vCenter
Connect-VIServer -Server <vcsa-server> -user 'user' -password 'pwd'

# Definire la lista di username
$usernames = @('user1','user2','user3','user4','user5','user_n')

# Recuperare tutte le VM
$vms = Get-VM

# Filtrare le VM il cui custom attribute 'vm.owner' è contenuto nella lista di username
$filteredVMs = @()
foreach ($vm in $vms) {
    $owner = Get-Annotation -Entity $vm -CustomAttribute 'vm.owner'
    if ($owner -and $usernames -contains $owner.Value) {
        $filteredVMs += $vm
    }
}

# Stampare la lista delle VM filtrate
$filteredVMs | Select-Object Name, 
                                @{Name='Owner';Expression={$_ | Get-Annotation -CustomAttribute 'vm.owner' | Select-Object -ExpandProperty Value}}, 
                                @{Name='CPU';Expression={$_.NumCpu}}, 
                                @{Name='MemoryGB';Expression={[math]::round($_.MemoryGB, 2)}},
                                @{Name='DiskGB';Expression={($_ | Get-HardDisk | Measure-Object -Property CapacityGB -Sum).Sum}},
								@{Name='RP';Expression={($_ | Get-ResourcePool)}},
								@{Name='Folder';Expression={($_ | Get-Folder)}} | 
                                Format-Table -AutoSize


#vm mancanti recupero info dal nome vm
$vmNames = @('vm1','vm2','vm3','vm_n')
$vms = Get-VM -Name $vmNames

# Creare una tabella con le informazioni desiderate
$vms | Select-Object Name,
		      @{Name='Owner';Expression={$_ | Get-Annotation -CustomAttribute 'vm.owner' | Select-Object -ExpandProperty Value}},
                      @{Name='CPU';Expression={$_.NumCpu}}, 
                      @{Name='MemoryGB';Expression={[math]::round($_.MemoryGB, 2)}},
                      @{Name='DiskGB';Expression={($_ | Get-HardDisk | Measure-Object -Property CapacityGB -Sum).Sum}},
					  @{Name='RP';Expression={($_ | Get-ResourcePool)}},
					  @{Name='Folder';Expression={($_ | Get-Folder)}} |					  
                      Format-Table -AutoSize
					  
# Disconnettersi dal server vCenter
Disconnect-VIServer -Server <vcsa-server> -Confirm:$false
