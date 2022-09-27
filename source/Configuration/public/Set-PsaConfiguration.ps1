Function Set-PsaConfiguration {
    <#
    .SYNOPSIS
        Set a configuration item in the profile config
    .EXAMPLE
        PS C:\> $repos | Set-PsaConfiguration 'github.repos'
    .EXAMPLE
        PS C:\> Set-PsaConfiguration 'github.repos' $repos
    #>
    [CmdletBinding()]
    param(
        # Provide a "key path" to the item in the configuration
        # Example:
        # if the config is like:
        # @{
        #    'github' = @{
        #        'repository = @{
        #            ...
        #        }
        #    }
        #    ....
        # then 'github.repository' will return an object starting at
        # the repository "key"
        [Parameter(
            Position = 0,
            Mandatory
        )]
        [string]$Key,

        # The value to set the key to
        [Parameter(
            Position = 1,
            Mandatory,
            ValueFromPipeline
        )]
        [object]$Value,

        # Optionally load a different configuration
        [Parameter(
        )]
        [string]$Path
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        $configFile = Get-PsaConfigurationFile -Path:$Path -Key $Key
        if ([string]::IsNullOrEmpty($configFile)) {
            throw "Could not find a file for $Key"
        } else {
            Write-Debug "Key is set to '$Key'"
            # first remove the "file path" portion from the key
            $file_path = $configFile.BaseName -replace '\.config'
            Write-Debug "  removing $file_path from Key path"
            $config_path = $Key -replace "$file_path.", ''
            Write-Debug "  path we are looking for is $config_path"

            $parts = ($config_path -split '\.')
            if ($parts.Count -gt 0) {
                $xPath = '/Data'
                foreach ($p in $parts) {
                    $xPath += -join ( '/Table/Item[@Key="', $p, '"]' )
                    Write-Debug "   xpath now $xPath"
                }

                Write-Verbose "Getting configuration item at '$xPath' in $($configFile.Name)"

                $xmlDoc = Import-PsdXml $configFile.FullName
                $xmlNode = $xmlDoc.SelectNodes($xPath)
                Write-Debug '  Setting the value'
                Set-Psd -Xml $xmlDoc -Value $Value -XPath $xPath
                Write-Debug "  Writing back to $($configFile.FullName)"
                Export-PsdXml -Path $configFile.FullName -Xml $xmlDoc
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
