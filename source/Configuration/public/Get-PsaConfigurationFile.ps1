<#
This function is used so that we can find the file in which 'github.labels' is defined.

it could be in configuration.psd1, in which case, that is easy... just return the file
if Get-PsaConfigurationPath returns a file.

it could be in config/github.config.psd1 , or it could be in github.labels.config.psd1

by iterating over the 'Key' we should be able to loop through the files, and return the "most specific"

the 'Key' is 'github.labels', so, is there a github.labels.config.psd1 ? yes? return that... no? ok,
how about a github.config.psd1, .... and up the "key path" in reverse

#>
function Get-PsaConfigurationFile {
    [CmdletBinding()]
    param(
        # The key to look up for determining the file
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string]$Key,

        # Optionally provide an alternate path to look in
        [Parameter(
        )]
        [string]$Path
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        Write-Debug "  Looking for path to file that contains $Key"
        $ConfigPath = (Get-PsaConfigurationPath -Path:$Path)
        if ($null -eq $ConfigPath) {
            $PSCmdlet.ThrowTerminatingError('No path was given for profile configuration')
        }

        if ($ConfigPath -is [System.IO.FileInfo]) {
            # if the path was to a single file, then just return that one.
            Write-Debug '  ConfigPath is a file'
            (Get-Item $ConfigPath) | Write-Output
        } elseif ($ConfigPath -is [System.IO.DirectoryInfo]) {
            Write-Debug "  Configuration is in a directory, looking for files"
            $parts = [System.Collections.ArrayList]@($Key -split '\.')
            Write-Debug "  $Key has $($parts.Count) parts"

            $current = $parts.Clone()

            foreach ($part in $parts) {
                $file_name = "$($current -join '.').config.psd1"
                $file_path = (Join-Path $ConfigPath $file_name)
                Write-Debug "  Testing for $file_name"
                if (Test-Path $file_path) {
                    Write-Debug "   $file_name exists"
                    (Get-Item $file_path) | Write-Output
                    break
                } else {
                    Write-Debug "  $file_name not found"
                    $last = $current[-1]
                    Write-Debug "    removing $last"
                    $current.Remove($last)
                }
            }
            #? if we didn't find a file from the path, then what?

        } else {
            Write-Verbose "  Could not access $($ConfigPath.GetType()) $ConfigPath"
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}
