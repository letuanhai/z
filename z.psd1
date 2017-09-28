﻿#
# Module manifest for module 'z'
#
# Generated by: Vince Panuccio
#
# Generated on: 6/11/2015
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'z.psm1'

#ModuleToProcess = 'z.psm1'

# Version number of this module.
ModuleVersion = '1.1.8'

# ID used to uniquely identify this module
GUID = 'bc198554-ae1f-4ab6-84ce-5d3a41b74553'

# Author of this module
Author = 'Vince Panuccio'

# Description of the functionality provided by this module
Description = 'z lets you quickly navigate the file system in PowerShell based on your cd command history. It''s a port of the z bash shell script'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '3.0'

FileList = 'z.psm1'

# Functions to export from this module
FunctionsToExport = @('z', 'cdX', 'popdX', 'pushdX')

# Aliases to export from this module
AliasesToExport = '*'

HelpInfoURI = 'https://github.com/vincpa/z'

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('z', 'directory', 'popd', 'pushd', 'jump')

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/vincpa/z'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        ReleaseNotes = 'Add cd history file check for first time users. Reduce PowerShell function export count to 1.'

    } # End of PSData hashtable

} # End of PrivateData hashtable



# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}
