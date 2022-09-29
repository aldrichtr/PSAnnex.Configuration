

Describe 'Testing the public function Get-PsaConfigurationPath' -Tag @('unit', 'public') {
    Context 'The command is available from the module' {
        BeforeAll {
            $command = Get-Command 'Get-PsaConfigurationPath'
        }

        It 'Should load without error' {
            $command | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Path is given as a Parameter' {
        Context 'And the path contains the default file' {
            BeforeAll {
                $config_dir = New-Item -Path 'TestDrive:\config_test' -ItemType Directory
                $config_path = Join-Path $config_dir 'configuration.psd1'
                '@{ test = $true }' | Set-Content $config_path

                $result = Get-PsaConfigurationPath -Path $config_dir
            }

            It 'Should return the path to the configuration directory' {
                $result | Should -BeLike $config_dir
            }
        }
        Context 'And the path contains the default folder' {
            BeforeAll {
                $config_dir = New-Item -Path 'TestDrive:\config_test\config' -ItemType Directory
                $config_path = Join-Path $config_dir 'default.config.psd1'
                '@{ test = $true }' | Set-Content $config_path

                $result = Get-PsaConfigurationPath -Path $config_dir
            }

            It 'Should return the path to the configuration directory' {
                $result | Should -BeLike $config_dir
            }
        }
    }
}
