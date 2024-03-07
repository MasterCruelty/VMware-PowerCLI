<#
	This script checks if there are Vms outside a specific folder in a specific cluster.
	If found, it sends an email for notification.
#>

function Handler($context, $inputs) {
    $inputsString = $inputs | ConvertTo-Json -Compress

    #Bypass certificates
    Set-PowerCLIConfiguration -InvalidCertificateAction:Ignore -Confirm:$false
    
    #Connection to vCenter
    Connect-VIServer -Server $inputs.vcenter -User $inputs.user -Password $inputs.password
    
    $folder = Get-Folder -Name "<folder-name>"
    $vmInFolder = $folder | Get-VM | Where-Object {$_.Folder.Name -eq "<folder-name>"} | Select Name
    $result = ""
    foreach($item in $vmInFolder){
        $result += "$item`r`n"
    }
    if($result -ne ""){
        send-MailMessage -To <receiver-1>,<receiver-2> -From <sender> -Subject "[Check VM] Workflow vRO " -Body "The following VMs are outside specific folder:`r`n$result" -SmtpServer <ip-smtp-server> -Port 25
    }

    #Disconnect from vCenter
    Disconnect-VIserver -Server $inputs.vcenter -Force -Confirm:$false

    return $output
}
