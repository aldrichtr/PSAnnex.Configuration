## SYNOPSIS

PSAnnex.Configuration is a configuration manager that uses psd1 files in a configuration directory

## DESCRIPTION

While the Configuration module is great for managing configuration setting for a module, it does not handle
configuration for general functions, such as those that are used in a PowerShell profile, or scripts created by the
user.

PSAnnex.Configuration will build a Configuration object from one or more psd1 files.  The files can be structured to
add configuration settings in a hierarchical manner.  For example, the file `github.config.psd1` will add the
settings defined within it to the `github` key within the configuration object.
