<#
	This script checks if there are Vms without a default tag.
	if found, it assign the default tag to every VM without it.
#>

function Handler($context, $inputs) {
  $inputsString = $inputs | ConvertTo-Json -Compress
  
  #Bypass certificates
  Set-PowerCLIConfiguration -InvalidCertificateAction:Ignore -Confirm:$false
  
  #Connection to vCenter
  Connect-VIServer -Server $inputs.vcenter -User $inputs.user -Password $inputs.password

  # Default tag to assign
  $tag = "<tag-name>"

  # Check VM on a specific cluster
  $VMs1 = Get-Cluster -Name "<cluster-name>" | Get-VM
  Write-Output ("----Check <cluster-name>----")

  foreach ($VM in $VMs1){
      If (((Get-Tagassignment $VM).Tag.Name -contains $null)){ 
           
         #check on vCLS 
         If(!($VM.Name -like "*vCLS*")){
            
            #Add default tag where tag is not present
            New-TagAssignment -Tag $tag -Entity $VM
            Write-Output ("Add default tag to VM: ")
            Write-Output $note $VM.Name
         }
      }       
  }
  
  #Disconnect from vCenter
  Disconnect-VIserver -Server $inputs.vcenter -Force -Confirm:$false
  
  return $output
}
