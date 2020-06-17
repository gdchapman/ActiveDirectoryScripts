﻿########### Beginnning of Main Menu #########

function Show-Menu

{


     param (
           [string]$Title = 'Welcome to the PowerDomain V1.1 !'
     )
     cls
     Write-Host "=====$Title ====="
     Write-Host "                   "
     
     Write-Host "Using this script , you can get the details of Sites, Subnets, FSMO Role Holders, Functional Levels, Group Policies for an entire Forest."
     Write-Host "                   "
     Write-Host "This script works for multi Domain Forest. You can run it from any Domain Controller in the forest, with Domain Admin or equivalent access."
     Write-Host "       "
     Write-Host "The script has been prepared and tested in Powershell 4.0. So when you run this script, please make sure that the Powershell version is 4.0 or above."
     Write-Host "                   "
     Write-Host "Test before you use in production."
     Write-Host "                   "
     Write-Host "Use at your own Risk."

     Write-Host "                   "

     Write-Host "--------------MENU----------------"
     Write-Host "                   "
     Write-Host "1: Press 1 to get Site and Subnet Details."
     Write-Host "                   "
     Write-Host "2: Press 2 to get FSMO Role Holder Details."
     Write-Host "                   "
     Write-Host "3: Press 3 to get Functional Level Details."
     Write-Host "                   "
     Write-Host "4: Press 4 to get Domain Controller Details."
     Write-Host "                   "
     Write-Host "5: Press 5 to get Group Policy Details."
     Write-Host "                   "
     Write-Host "6: Press 6 to get DNS Zone Details."
     Write-Host "                   "
     Write-Host "Q: Press 'Q' to quit this Program."
     Write-Host "----------------------------------"
     Write-Host "                   "

}


########### End of Main Menu #########

##### Beginning of the function SiteSubnet #######

function SiteSubnet

{
write-host "   "
$output = read-host "Enter the location of the output file. It should be a CSV file."
write-host "   "
$sites = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().Sites
$sitesubnets = @()

foreach ($site in $sites)
{

if ($site.subnets -ne $null)

{
foreach ($subnet in $site.subnets){
   $temp = New-Object PSCustomObject -Property @{
   ‘Site’ = $site.Name
   ‘Subnet’ = $subnet;
    }
    $sitesubnets += $temp
}

}

else

{
    $temp = New-Object PSCustomObject -Property @{
   ‘Site’ = $site.Name
    }
    $sitesubnets += $temp
}

}


 $sitesubnets

 $sitesubnets | Export-Csv -Path $output -NoTypeInformation


}

########## End of the function SiteSubnet ######

##### Beginning of the function SiteLink #######

function SiteLink

{

write-host "   "
$output = read-host "Enter the location of the output file. It should be a CSV file."

$value= Get-ADReplicationSiteLink -Filter * | Select-Object @{label='Site Link Name'; expression= {$_.Name}},@{label='Link Cost'; expression= {$_.Name}},@{label='Replication Frequency In Minutes'; expression= {$_.ReplicationFrequencyInMinutes}},@{label='Sites Included'; expression= {$_.SitesIncluded}}

$value | export-csv -Path $output -NoTypeInformation


}




########### Beginnning of FSMO Functions #########


function ForestFSMO

{

Get-ADForest | Select-Object Name,DomainNamingMaster, SchemaMaster



}


function DomainFSMO

{

$path= Read-Host "Please enter the location of the output file, along with the file name. The file format would be CSV".


$domains=(Get-ADForest).Domains


foreach ($domain in $domains)

{

$domainfsmo= Get-ADDomain -Identity $domain | select-object DistinguishedName,InfrastructureMaster, RIDMaster, PDCEmulator

$domainfsmo

$domainfsmo | export-csv -path $path -NoTypeInformation -Append

}


}

########### End of FSMO Functions #########


########### Beginning of Functional Level Functions #########

function ForestFL

{

Get-ADForest | Select-Object Name,ForestMode

}

function DomainFL

{


$domains=(Get-ADForest).Domains


foreach ($domain in $domains)

{

$domainfl= Get-ADDomain -Identity $domain | select-object DistinguishedName,DomainMode

$domainfl



}


}

########### End of Functional Level Functions #########



########### Beginning of DC Details Function #########

function DcDetails

{

$domains=(Get-ADForest).Domains

$path= Read-Host "Please enter the location of the output file, along with the file name. The file format would be CSV".

foreach ($domain in $domains)

{

$DC = (Get-ADDomain -Identity $domain).PDCEmulator

$DCList=Get-ADGroupMember 'Domain Controllers' -Server $DC| Get-ADDomainController | Select-Object Domain,Name,OperatingSystem,IPv4Address,IsGlobalCatalog,Site

$DCList | ft *

$DCList | export-csv -Path "$path" -Append -NoTypeInformation

}

}

########### End of DC Details Function #########



########### Beginning of Group Policy Function #########

function GPODetails

{

$path= Read-Host "Please enter the location of the output file, along with the file name. The file format would be CSV".

$domains=(Get-ADForest).Domains

foreach ($domain in $domains)

{

$GPOList= Get-GPO -Domain $domain -All

$GPOList | ft DomainName,DisplayName,GpoStatus,WmiFilter

$GPOList | Select-Object DomainName,DisplayName,GpoStatus,WmiFilter | Export-Csv -Path $path -Append -NoTypeInformation

}

}

########### End of Group Policy Function #########

########### Beginnning of DNS Zone Details Function #########

function DNSZones

{

Write-Host " "

Write-Host "Please run this from a DNS Server."

Write-Host " "

$output= Read-Host "Please enter the location of the output file. This will be a CSV file."

$domainname= (Get-ADDomain).name

$list=Get-DnsServerZone | Select-Object @{Name="Domain";Expression={$domainname}},ZoneName,ZoneType,DynamicUpdate,IsAutoCreated,IsDsIntegrated,IsReverseLookupZone,ReplicationScope,MasterServers,NotifyServers,SecondaryServers

$list | export-csv "$output" -NoTypeInformation

$list | ft

}



########### End of DNS Zone Details Function #########


########### Beginnning of Sub Menus and Function Execution #########

do
{
     Show-Menu
     $input = Read-Host "Please make a selection"
     switch ($input)
     {
           '1' {
                cls
                'Press 1 to get site and Subnet Details'
                 Write-host "               "
                'Press 2 to get Site Link Details'
                 Write-host "               "
                 
                $input=Read-Host "Please make a selection"
                 
                 switch ($input)

                {
                   1 { SiteSubnet }

                   2 { SiteLink }

                  
                }

                 return

                  } 
           
                   
           
           
           '2'  {
                cls
                'You have selected option #2: FSMO Role Holder Details.'

                'Press 1 for Forest FSMO ROle Holders'
                'Press 2 for DOmain FSMO Role Holders'
                'Press Q to Return to the Main Menu'
                
                Write-host "               "
                Write-Warning "After showing the Forest or Domain FSMO Role holders, the script will be terminated and you have to run it again."
                Write-host "               "
                $input=Read-Host "Please make a selection"


                switch ($input)

                {
                   1 { ForestFSMO }

                   2 { DomainFSMO }

                  
                }

                 return

                }


 
           '3'  {
                cls
                'You have selected option #3: Functional Level Details.'

                'Press 1 for Forest Functional Levels.'
                'Press 2 for DOmain Functional Levels.'
                'Press Q to Return to the Main Menu'
                 
                Write-host "               "
                Write-Warning "After showing the Forest or Domain Functional Levels, the script will be terminated and you have to run it again."
                Write-host "               "
                $input=Read-Host "Please make a selection"


                switch ($input)

                {
                   1 { ForestFL }

                   2 { DomainFL }

                  
                }

                 return

                }


                '4'  {

                cls

                'You have selected option #4: Domain Controller Details.'
                
                Write-host "               "
                Write-Warning "This will collect the details of all Domain Controllers in the entire Forest. So make sure you have appropriate access."
                Write-host "               "
                DcDetails

                     }


                      '5'  {

                cls

                'You have selected option #5: Group Policy Details.'
                
                Write-host "               "
                Write-Warning "This will bring the Group Policy details for the entire Forest. So make sure you have appropriate access."
                Write-host "               "
                GPODetails

                     }

                         '6'{

                cls

                'You have selected option #6: Get DNS Zone Details.'
                
                Write-host "               "
                
                DNSZones

                            }

          
           'q' {
                return
               }
     }
     pause
}
until ($input -eq 'q')


########### End of Sub Menus and Function Execution #########