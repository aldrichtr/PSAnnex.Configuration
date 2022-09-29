
function Get-PsaConfigurationPath {
    <#
    .SYNOPSIS
        Determine the path to "the configuration" based on default locations.
    .DESCRIPTION
        `Get-PsaConfigurationPath` returns the path to the folder containing the configuration.  "The configuration"
        is either:
        1. A file named 'default.config.psd1'
        1. A directory named 'config'
        1. A directory named '.config'
        1. A directory named 'psaconfig'
        1. A directory named '.psaconfig'

        These are processed in order, and if any of those are found, `Get-PsaConfigurationPath` will return it's
        parent folder.  This function is used by `Get-PsaConfiguration` which then parses the files if a path is
        returned.

        To find "the configuration", `Get-PsaConfigurationPath` looks in several locations:
        1. The value passed in to the Path Parameter
        1. The PSA_CONFIG environment variable
        1. The $env:HOME (or $env:USERPROFILE if not set) environment variable
        1. The $env:XDG_CONFIG_HOME environment variable
        1. The $dotfiles variable (NOTE: not an environment variable)
        1. The directory of $Profile.CurrentUserCurrentHost
        1. The current directory
    #>
    [CmdletBinding()]
    param(
        # Optionally load a different configuration
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string]$Path
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        $DEFAULT = [ordered]@{
            'default.config.psd1' = [System.IO.FileInfo]
            'config'              = [System.IO.DirectoryInfo]
            '.config'             = [System.IO.DirectoryInfo]
            'psaconfig'           = [System.IO.DirectoryInfo]
            '.psaconfig'          = [System.IO.DirectoryInfo]
        }
        $locations = @(
            $PSBoundParameters['Path'],
            [System.Environment]::GetEnvironmentVariable('PSA_CONFIG', 'User'),
            [System.Environment]::GetEnvironmentVariable('HOME', 'User'),
            [System.Environment]::GetEnvironmentVariable('USERPROFILE', 'User'),
            [System.Environment]::GetEnvironmentVariable('XDG_CONFIG_HOME', 'User'),
            $dotfiles,
                ($Profile.CurrentUserCurrentHost).Directory.FullName,
                (Get-Location | Get-Item).FullName
        )
    }
    process {
        # 1. The value passed by the Path Parameter always wins
        :directory foreach ($dir in $locations) {
            if ([string]::IsNullOrEmpty($dir)) {
                Write-Debug '  Path was null or empty'
            } else {
                Write-Debug "  Testing if '$dir' has a config"
                :file foreach ($key in $DEFAULT.Keys) {
                    Write-Debug "   - $key ?"
                    $item = (Get-Item (Join-Path $dir $key) -ErrorAction SilentlyContinue)
                    if (($null -ne $item) -and ($item -is $Default[$key])) {
                        $item | Write-Output
                        break :directory
                    } else {
                        Write-Debug '     no'
                    }
                } # foreach key
            }
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
