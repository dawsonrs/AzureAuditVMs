<#Author       : Robert Dawson
# Creation Date: 14-04-2024
# Usage        : Audit VMs in Azure Subscription - easily run from clouddrive, or any authenticated session
# 
# e.g.
# PS /home/robert/clouddrive> ./VM_Status.ps1
# PS /home/robert/clouddrive> cat VM_Status.csv                                                   
# "ResourceGroupName","Name","Location","VmSize","OSType","OSVersion","NIC","Extensions"
# "PLACEBOHEALTH_ULTRACLOUD","VM-AADDS-MGMT1","uksouth","Standard_A2_v2","Windows Server 2019 Datacenter","10.0.17763.5696","VM-AADDS-MGMT1_nic","AzureMonitorWindowsAgent DSC VMAccessAgent IaaSAntimalware IaaSDiagnostics JsonADDomainExtension MicrosoftMonitoringAgent CustomScriptExtension"
# "PLACEBOHEALTH_ULTRACLOUD","vm-mgmt-em2","uksouth","Standard_DS1_v2","ubuntu","22.04","vm-mgmt-em2_nic1","AzureMonitorLinuxAgent CustomScript"
# "PLACEBOHEALTH_ULTRACLOUD","VM-MGMT-JUMP1","uksouth","Standard_A1_v2","Windows Server 2022 Datacenter","10.0.20348.2402","VM-MGMT-JUMP1_nic","AzureMonitorWindowsAgent VMAccessAgent MicrosoftMonitoringAgent"
# "PLACEBOHEALTH_ULTRACLOUD_AVD","VM-WVD-SH1","uksouth","Standard_F2s_v2","Windows 10 Enterprise","10.0.19045.4291","VM-WVD-SH1_nic","AzureMonitorWindowsAgent DSC IaaSAntimalware JsonADDomainExtension MicrosoftMonitoringAgent CustomScriptExtension"
# PS /home/robert/clouddrive>
#>

$Report = [System.Collections.Generic.List[Object]]::new()
$vms = $null
$vms = Get-azVm -Status

Foreach ($vm in $vms){
	$rg = $vm.ResourceGroupName
	$name = $vm.Name
	$vm2 = Get-AzVm -ResourceGroupName $rg -Name $name
	$loc = $vm2.Location
	$size = $vm2.HardwareProfile.VmSize
	$nic = ($vm2.NetworkProfile.NetworkInterfaces.Id).split("/")[-1]
	$extensions = $vm2.Extensions.VirtualMachineExtensionType
    $obj = [PSCustomObject][ordered]@{
		"ResourceGroupName" = $vm.ResourceGroupName
        "Name" = $vm.Name
		"Location" = $loc
		"VmSize" = $size
        "PowerState" = $vm.PowerState
        "OSType" = $vm.OsName
        "OSVersion" = $vm.OsVersion
        "NIC" = $nic
        "Extensions" = [string]$extensions
    }
	$report.Add($obj)
}

$Report | Export-CSV VM_Status.csv
