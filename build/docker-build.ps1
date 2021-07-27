#!/bin/pwsh

# Copyright (c) 2021 Jesse N. <jesse@keplerdev.com>
# This work is licensed under the terms of the MIT license. For a copy, see <https://opensource.org/licenses/MIT>.

[CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'Build')]
param(
    [Parameter(
        Mandatory = $true,
        ParameterSetName = "Build",
        HelpMessage = 'Semantic version compliant string to tag built image with.')]
    [Parameter(
        Mandatory = $true,
        ParameterSetName = "Login",
        HelpMessage = 'Semantic version compliant string to tag built image with.')] )]
    [Alias('i')]
    [Alias('-image-version')]
    [ValidateNotNullOrEmpty]
    [string]$ImageVersion

    [Parameter(
        ParameterSetName = "Login",
        HelpMessage = "Username to log into the specified registry with.")]
    [Alias('U')]
    [Alias('-registry-username')]
    [string]$RegistryUsername,

    [Parameter(
        ParameterSetName = "Login",
        HelpMessage = "Plain text or secure string password to log in to the specified registry with.")]
    [string]$RegistryPassword,

    [Parameter(
        ParameterSetName = "Build",
        HelpMessage = "Semantic version compliant string that coincides with underlying base Alpine image. See dockerhub.com/alpine for values. 'latest' is considered valid.")]
    [Alias('a')]
    [Alias('-alpine-version')]
    [string]$AlpineVersion = 'latest',

    [Parameter(
        ParameterSetName = "Build"
        HelpMessage = ('Registry which the image will be pushed upon successful build. ' +
            'If not using dockerhub, the full FQDN must be specified. ' +
            'This assumes the default docker daemon is already authenticated ' +
            'with the registry specified. If dockerhub is used, just the username ' +
            'is required. Default value: jessenich91.'))]
    [Alias('l')]
    [Alias('-library')]
    [string]$Library = 'jessenich91',

    [Parameter(
        ParameterSetName = "Build",
        HelpMessage = "Repository which the image will be pushed upon successful build. Default value: 'base-alpine'")]
    [Alias('R')]
    [Alias('-repository')]
    [string]$Repository = 'base-alpine'
)

begin {
    if ([string]::IsNullOrWhiteSpace($ImageVersion)) {
        throw [System.ArgumentNullException]::new('ImageVersion');
    }

    $Script:Tag1 = 'latest';
    $Script:Tag2 = $ImageVersion;

    if ($NoDocs -eq $true) {
        $Script:Tag1 = $Script:Tag1 += "-do-docs";
        $Script:Tag2 = $Script:Tag2 += "-no-docs";
    }

    $Script:RepositoryRoot = '.';
}

process {
    docker buildx build `
        -f "$($Script:RepositoryRoot)/Dockerfile" `
        -t "$($Registry)/$($Repository):$($Script:Tag1)" `
        -t "$($Registry)/$($Repository):$($Script:Tag2)" `
        --build-arg "ALPINE_VERSION=$AlpineVersion" `
        --build-arg "USER=$User" `
        --platform linux/arm/v7,linux/arm64/v8,linux/amd64 `
        --push `
        $Script:RepositoryRoot
}

end {

}
