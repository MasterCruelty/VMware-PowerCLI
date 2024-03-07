<#
	This script set the last time a VM was powered off.
	If the VM has already the tag PowerOff.From, it does nothing.
	If the VM is powered on and it has the tag, it deletes it.
#>

function Handler($context, $inputs) {
    $inputsString = $inputs | ConvertTo-Json -Compress

    #Bypass certificates
    Set-PowerCLIConfiguration -InvalidCertificateAction:Ignore -Confirm:$false
  
    #Connection to vCenter
    Connect-VIServer -Server $inputs.vcenter -User $inputs.user -Password $inputs.password

    Get-VM -Location "<cluster-name>" | Where-Object {($_.PowerState -eq 'PoweredOff') -and ($_.CustomFields.Item("PowerOff.From") -eq '')} | Set-Annotation -CustomAttribute 'PowerOff.From' -Value (get-date) 
    Get-VM -Location "<cluster-name>" | Where-Object {($_.PowerState -eq 'PoweredOn') -and ($_.CustomFields.Item("PowerOff.From") -ne '')} | Set-Annotation -CustomAttribute 'PowerOff.From' -Value '' 
    
    #Disconnect from vCenter
    Disconnect-VIserver -Server $inputs.vcenter -Force -Confirm:$false

    return $output
}
