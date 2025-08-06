#This is thought to be a utility to create folder, resource pool and assign correct permission to new user incoming to a vsphere environment

 #Bypass certificates
 Set-PowerCLIConfiguration -InvalidCertificateAction:Ignore -Confirm:$false
    
 # connect to vCenter Server
 Connect-VIServer -Server <vCenter-name> 
 
 #user of which you need to create folder, resource pool and permission assign.
 $newuser = 'TEST-SCRIPT'
 
 
 #check folder
 try{
	 $folder = Get-Folder -Name $newuser -ErrorAction stop
 }catch{
	 Write-Output "Folder doesn't exist, I'll create..."
 }
 
 #if the folder doesn't exist, it'll be created
 if($folder.Name -eq $newuser) {
	 Write-Output "Folder named  $($newuser) already exists." 
 }
 else {
	Get-Folder -Name "<folder-name>"| New-Folder -Name $newuser
	$folder = Get-Folder -Name $newuser -ErrorAction stop
 }
 
 #check resource pool
 try{
	 $rp = Get-ResourcePool -Name $newuser -ErrorAction stop
 }catch{
	 Write-Output "Resource pool doesn't exist, I'll create"
 }	 
	 
#if resource pool doesn't exist, it'll be created
 if($rp.Name -eq $newuser) {
	 Write-Output "resource pool named $($newuser) already exists." 
 }
 else{
	 New-ResourcePool -Location "<cluste-name>" -Name $newuser
	 $rp = Get-ResourcePool -Name $newuser -ErrorAction stop
 }
 
 #check permission folder e resource pool
 $permissionFolder = Get-ViPermission -Entity $folder
 $permissionRP = Get-ViPermission -Entity $rp
 $checkRole = 0
 $checkPrincipal = 0
 foreach($item in $permissionFolder){	 
	if($item.Role -eq "<role-name>"){
		Write-Output "Role OK"
		$checkRole = 1
	}
	if($item.Principal -eq "<domain\principal>"){
		Write-Output "Principal OK"
		$checkPrincipal = 1
	}
 }
 
 #if the folder doesn't have permission, I'll assign 
 if($checkRole -eq 0){
	 Write-Output "Role Folder NO OK, I assign"
	 New-VIPermission -Entity $folder -Principal "<domain\principal>" -Role "<role-name>"
 }
 
 if($checkPrincipal -eq 0){
	 Write-Output "Principal Folder NO OK, I assign"
	 New-VIPermission -Entity $folder -Principal "<domain\principal>" -Role "<role-name>"
 }
 
 
 $checkRole = 0
 $checkPrincipal = 0
 foreach($item in $permissionRP){	 
	if($item.Role -eq "<role-name>"){
		Write-Output "Role OK"
		$checkRole = 1
	}
	if($item.Principal -eq "<domain\principal>"){
		Write-Output "Principal OK"
		$checkPrincipal = 1
	}
 }
 
 #if the resource pool doesn't have permission, I'll assign 
if($checkRole -eq 0){
	 Write-Output "Role resource pool NO OK, I assign"
	 New-VIPermission -Entity $rp -Principal "<domain\principal>" -Role "<role-name>"
 }
 
 if($checkPrincipal -eq 0){
	 Write-Output "Principal resource pool NO OK, I assign"
	 New-VIPermission -Entity $rp -Principal "<domain\principal>" -Role "<role-name>"
 }
 
 Disconnect-VIserver -Server <vCenter-name> -Force -Confirm:$false
