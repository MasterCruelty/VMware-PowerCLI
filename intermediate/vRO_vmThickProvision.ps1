<#
	This script checks if there are VMs with Thick Provision in a specific Cluster.
#>

function Handler($context, $inputs) {
    $inputsString = $inputs | ConvertTo-Json -Compress

    #Bypass certificates
    Set-PowerCLIConfiguration -InvalidCertificateAction:Ignore -Confirm:$false
  
    #Connection to vCenter
    Connect-VIServer -Server $inputs.vcenter -User $inputs.user -Password $inputs.password

    #check for a specific cluster 
    $vm1 = Get-VM -Location "<cluster-name>"
    $pathcsv = "/tmp/vm-thick.csv"
    $vmThick1 = $vm1 | Get-HardDisk | where{$_.StorageFormat -eq 'Thick'} | Select @{N='VM';E={$_.Parent.Name}}, Name, StorageFormat, @{N='VMOwner';E={$_.Parent.CustomFields['vm.owner']}}, @{N='CapacityGB';E={$_.CapacityGB}}
    $resultObject = @()
    $totalSpace1 = 0
    foreach($item in $vmThick1){
        $totalSpace1 += $($item.CapacityGB)
        #$owner = $item | Get-Annotation -Name 'vm.owner' | Select Value
        $resultObject += [PSCustomObject]@{
                    VM = $item.VM
                    Proprietario = $item.VMOwner
                    "Spazio Occupato GB" = $item.CapacityGB
        }
    }
    $result1Object | Export-Csv -Path $pathcsv -NoTypeInformation -UseQuotes AsNeeded -Delimiter ';'

    if($totalSpace1 -ne 0 -or $totalSpace2 -ne 0){
        send-MailMessage -To <receiver-1>,<receiver-2> -From <sender> -Subject "[Check VM] Workflow vRO " -Body "The following VMs has one or more disks with Thick Provision:`r`n<cluster-name>:`r`nOccupied space: $($totalSpace1) GB`r`n" -SmtpServer <ip-server-smtp> -Port 25 -Attachments $pathcsv
    }
    #Disconnect from vCenter
    Disconnect-VIserver -Server $inputs.vcenter -Force -Confirm:$false

    return $output
}
