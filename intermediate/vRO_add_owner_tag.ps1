<#
	This script extract all VM of a specific cluster to set the current owner of every VM.
	New-CustomAttribute -Name "vm.owner" -TargetType VirtualMachine
#>

function Handler($context, $inputs) {
    $inputsString = $inputs | ConvertTo-Json -Compress
	
    #Bypass certificates
    Set-PowerCLIConfiguration -InvalidCertificateAction:Ignore -Confirm:$false
  
    #Connection to vCenter
    Connect-VIServer -Server $inputs.vcenter -User $inputs.user -Password $inputs.password

    #Setting VM owner for a specific cluster
    $vm1 = Get-VM -Location "<cluster-name>" 
    foreach ($vm in $vm1) {
        $checkowner = $vm | Get-Annotation -Name 'vm.owner' | Select Value
        if($checkowner.Value.Contains('.')){
            #Write-Output "Attribute 'vm.owner' already exits for VM $($vm.Name). Skip iteration."
            continue
        }
        $eventi = $vm | Get-VIEvent | Where-Object {
            ($_.FullFormattedMessage -match "^Created virtual machine") -or
            ($_.FullFormattedMessage -match "is starting") -and
            ($_.UserName -match "<OU-name>\\(.*)") -and
        }

        # If there are events matched
        if ($eventi) {
            # Extract name without <OU-name>
            $result = $eventi[0].UserName -replace "<OU-name>\\", ""

            # Add custom attribute 'vm.owner' to vm with value of the username
            $vm | Set-Annotation -CustomAttribute 'vm.owner' -Value $result
            Write-Output "custom attribute 'vm.owner' added to VM $($vm.Name) with value: '$result'."
        } else {
            #Write-Output "No events matched for VM: $($vm.Name)."
            continue
        }
    }

    #Disconnect from vCenter
    Disconnect-VIserver -Server $inputs.vcenter -Force -Confirm:$false
     
    return $output
}
