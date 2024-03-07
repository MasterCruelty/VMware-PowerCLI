function Handler($context, $inputs) {
    $inputsString = $inputs | ConvertTo-Json -Compress

    #Bypass certificates
    Set-PowerCLIConfiguration -InvalidCertificateAction:Ignore -Confirm:$false
    
    #Connection to vCenter
    Connect-VIServer -Server $inputs.vcenter -User $inputs.user -Password $inputs.password

    # Check VM on specific cluster
    $cluster = "<cluster-name>"
    $rp = Get-ResourcePool -Name Resources -Location $cluster
    $vm1 =  Get-VM -Location $cluster | Where-Object {$_.ResourcePool.Id -eq $rp.Id -and !($_.Name -like "vCLS*")} | Select Name
    $result1 = ""
    foreach($item in $vm1.Name){
        $result1 += "$item`r`n"
    }
    #Notification via mail with a list of all VM outside resource pool
    if($result1 -ne "" -and $result2 -ne ""){
        send-MailMessage -To <receiver-1>,<receiver-2> -From <sender> -Subject "[Check VM] Workflow vRO " -Body "The following VMs are outside of a resource pool:`r`nCluster <cluster-name>:`r`n$($result1)`r`n -SmtpServer <ip-smtp-server> -Port 25
    }

    #Disconnect from vCenter
    Disconnect-VIserver -Server $inputs.vcenter -Force -Confirm:$false
    
    return $output
}
