function Handler($context, $inputs) {
    $inputsString = $inputs | ConvertTo-Json -Compress

    #Bypass certificates
    Set-PowerCLIConfiguration -InvalidCertificateAction:Ignore -Confirm:$false
  
    #Connection to Vcenter
    Connect-VIServer -Server $inputs.vcenter -User $inputs.user -Password $inputs.password

    $vmLongTime1 = Get-VM -Location "<cluster-name>" | Where-Object {$_.PowerState -eq 'PoweredOff'} | Get-Annotation -CustomAttribute "PowerOff.From" | Select AnnotatedEntity, Value
    $result1 = ""
    $totalSpace1 = 0
    foreach($item in $vmLongTime1){ 
        try{
            if(([datetime]::parseexact($($item.Value),'MM/dd/yyyy HH:mm:ss',$null)) -le (get-date).AddDays(-180)) {
                $provisionedSpace = [math]::Round((Get-VM -Name $item.AnnotatedEntity).UsedSpaceGB)                
                $totalSpace1 += $provisionedSpace
                $result1 += "`r`n$($item.AnnotatedEntity) [last poweroff] $($item.Value) [occupied space] $provisionedSpace GB`r`n"
            }
        } catch{ Write-Output "PowerOff not found"}
    }
    $result1 += "`r`n"
    if($totalSpace1 -ne 0){
        send-MailMessage -To <receiver-1>,<receiver-2> -From <sender> -Subject "[Check VM] Workflow vRO " -Body "The following VMs are poweredoff since 6 months:`r`n<cluster-name>:`r`nSpace occupied: $($totalSpace1) GB`r`n$($result1)`r`n" -SmtpServer <ip-server-smtp> -Port 25
    }
    #Disconnect from vCenter
    Disconnect-VIserver -Server $inputs.vcenter -Force -Confirm:$false

    return $output
}
