<#
    This script check and set custom field owner to VMs by reading their resource pool 
#>

function Handler($context, $inputs) {
    $inputsString = $inputs | ConvertTo-Json -Compress

    #Bypass certificates
    Set-PowerCLIConfiguration -InvalidCertificateAction:Ignore -Confirm:$false
  
    #Connection to vCenter
    Connect-VIServer -Server $inputs.vcenter -User $inputs.user -Password $inputs.password

    #setting owner for every VM in cluster
    $vm1 = Get-VM -Location "<cluster-name>" 
    foreach ($vm in $vm1) {
        $checkowner = $vm | Get-Annotation -Name 'vm.owner' | Select Value
        try{ 
            if($checkowner.Value -eq ''){
                $rs = $vm | Get-ResourcePool | Select Name
                #add attribute 
                $vm | Set-Annotation -CustomAttribute 'vm.owner' -Value $rs.Name
                Write-Output "Custom field 'vm.owner' added to VM $($vm.Name) with value '$rs.Name'."    
            }
        }catch{continue}
    }

    # Disconnect from vCenter
    Disconnect-VIserver -Server $inputs.vcenter -Force -Confirm:$false

    return $output
}
