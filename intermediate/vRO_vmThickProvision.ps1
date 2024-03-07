function Handler($context, $inputs) {
    $inputsString = $inputs | ConvertTo-Json -Compress

    #Bypass certificates
    Set-PowerCLIConfiguration -InvalidCertificateAction:Ignore -Confirm:$false
  
    #Connection to vCenter
    Connect-VIServer -Server $inputs.vcenter -User $inputs.user -Password $inputs.password

    #check for a specific cluster 
    $vm1 = Get-VM -Location "<cluster-name>"
    $vmThick1 = $vm1 | Get-HardDisk | where{$_.StorageFormat -eq 'Thick'} | Select @{N='VM';E={$_.Parent.Name}}, Name, StorageFormat, @{N='VMOwner';E={$_.Parent.CustomFields['vm.owner']}}, @{N='CapacityGB';E={$_.CapacityGB}}
    $result1 = ""
    $totalSpace1 = 0
    foreach($item in $vmThick1){
        $totalSpace1 += $($item.CapacityGB)
        if( $($item.VMOwner).Contains('.')){
            $result1 += "`r`n$($item.VM) [occupied space] $($item.CapacityGB) GB [owner] $($item.VMOwner)`r`n"
        }else{
            $result1 += "`r`n$($item.VM) [occupied space] $($item.CapacityGB) GB`r`n"
        }
    }

    if($totalSpace1 -ne 0 -or $totalSpace2 -ne 0){
        send-MailMessage -To <receiver-1>,<receiver-2> -From <sender> -Subject "[Check VM] Workflow vRO " -Body "The following VMs has one or more disks with Thick Provision:`r`n<cluster-name>:`r`nOccupied space: $($totalSpace1) GB`r`n$($result1)`r`n" -SmtpServer <ip-server-smtp> -Port 25
    }
    #Disconnect from vCenter
    Disconnect-VIserver -Server $inputs.vcenter -Force -Confirm:$false

    return $output
}
