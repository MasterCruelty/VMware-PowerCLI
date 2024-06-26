<#
	This script checks if there are Vms poweredoff since 6 months ago.
#>

function Handler($context, $inputs) {
    $inputsString = $inputs | ConvertTo-Json -Compress

    #Bypass certificates
    Set-PowerCLIConfiguration -InvalidCertificateAction:Ignore -Confirm:$false
  
    #Connection to Vcenter
    Connect-VIServer -Server $inputs.vcenter -User $inputs.user -Password $inputs.password
    
    #tag which exclude vms from this check
    $vmsWithTag = Get-VM -Tag "exclude-vms"
    $vmLongTime1 = Get-VM -Location "<cluster-name>" | Where-Object {$_.PowerState -eq 'PoweredOff' -and $_ -notin $vmsWithTag} | Get-Annotation -CustomAttribute "PowerOff.From" | Select AnnotatedEntity, Value
    #path for exporting and sending csv via email
    $pathcsv1 = "/tmp/vm-poweroff.csv"
    #initialize object which is need for exporting csv
    $result1Object = @()
    $totalSpace1 = 0
    foreach($item in $vmLongTime1){ 
        try{
            if(([datetime]::parseexact($($item.Value),'MM/dd/yyyy HH:mm:ss',$null)) -le (get-date).AddDays(-180)) {
                $owner = $item.AnnotatedEntity | Get-Annotation -Name 'vm.owner' | Select Value
                $provisionedSpace = [math]::Round((Get-VM -Name $item.AnnotatedEntity).UsedSpaceGB)                
                $totalSpace1 += $provisionedSpace
                #fill the object at every iteration
                $result1Object += [PSCustomObject]@{
                    VM = $item.AnnotatedEntity.Name
                    Owner = $owner.Value
                    "Last poweroff" = $item.Value
                    "Occupied space GB" = $provisionedSpace
                }
            }
        } catch{ Write-Error $_.Exception.Message}
    }
    #exporting data to csv
    $result1Object | Export-Csv -Path $pathcsv1 -NoTypeInformation -UseQuotes AsNeeded -Delimiter ';'
    if($totalSpace1 -ne 0){
        send-MailMessage -To <receiver-1>,<receiver-2> -From <sender> -Subject "[Check VM] Workflow vRO " -Body "The following VMs are poweredoff since 6 months:`r`n<cluster-name>:`r`nSpace occupied: $($totalSpace1) GB" -SmtpServer <ip-server-smtp> -Port 25 -Attachments $pathcsv1
    }
    #Disconnect from vCenter
    Disconnect-VIserver -Server $inputs.vcenter -Force -Confirm:$false

    return $output
}
