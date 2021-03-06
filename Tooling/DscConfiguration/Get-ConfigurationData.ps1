function Get-ConfigurationData
{
    [cmdletbinding(DefaultParameterSetName='NoFilter')]
    param (
        [parameter()]
        [string]
        $Path = $ConfigurationDataPath,
        [parameter(
            ParameterSetName = 'NameFilter'
        )]
        [string]
        $Name,
        [parameter(
            ParameterSetName = 'NodeNameFilter'  
        )]
        [string]
        $NodeName,
        [parameter(
            ParameterSetName = 'RoleFilter'  
        )]
        [string]
        $Role, 
        [parameter()]
        [switch]
        $Force
    )             

    begin
    {
        if (($script:ConfigurationData -eq $null) -or $force) 
        {
            $script:ConfigurationData = @{ AllNodes = @(); SiteData = @{}; Services=@{}; Credentials = @{} }
        }
    }
    end { 

        Get-AllNodesConfigurationData -Path $path 

        $ofs = ', '
        $FilteredResults = $true
        Write-Verbose 'Checking for filters of AllNodes.'
        switch ($PSCmdlet.ParameterSetName)
        {
            'Name'  {            
                Write-Verbose "Filtering for nodes with the Name $Name"
                $script:ConfigurationData.AllNodes = $script:ConfigurationData.AllNodes.Where({$_.Name -like $Name})
            }

            'NodeName' {            
                Write-Verbose "Filtering for nodes with the GUID of $NodeName"
                $script:ConfigurationData.AllNodes = $script:ConfigurationData.AllNodes.Where({$_.NodeName -like $NodeName})
            }
            'Role'  {
                Write-Verbose "Filtering for nodes with the Role of $Role"
                $script:ConfigurationData.AllNodes = $script:ConfigurationData.AllNodes.Where({ $_.roles -contains $Role})
            }
            default {
                Write-Verbose 'Loading Site Data'
                Get-SiteDataConfigurationData -Path $path
                Write-Verbose 'Loading Services Data'
                Get-ServiceConfigurationData -Path $path
                Write-Verbose 'Loading Credential Data'
                Get-CredentialConfigurationData -Path $path
            }
        }

        Add-NodeRoleFromServiceConfigurationData
        return $script:ConfigurationData
    }

    
}
