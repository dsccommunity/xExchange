$script:DSCModuleName = 'xExchange'
$script:DSCResourceName = 'MSFT_xExchDatabaseAvailabilityGroupNetwork'
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'tests' -ChildPath (Join-Path -Path 'TestHelpers' -ChildPath 'xExchangeTestHelper.psm1'))) -Global -Force

function Invoke-TestSetup
{
    try
    {
        Import-Module -Name DscResource.Test -Force
    }
    catch [System.IO.FileNotFoundException]
    {
        throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -Tasks build" first.'
    }

    $script:testEnvironment = Initialize-TestEnvironment `
        -DSCModuleName $script:dscModuleName `
        -DSCResourceName $script:dscResourceName `
        -ResourceType 'Mof' `
        -TestType 'Unit'
}

function Invoke-TestCleanup
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}

Invoke-TestSetup

# Begin Testing
try
{
        InModuleScope $script:DSCResourceName {
        Describe 'MSFT_xExchDatabaseAvailabilityGroupNetwork\Get-TargetResource' -Tag 'Get' {
            # Override Exchange cmdlets
            function Get-DatabaseAvailabilityGroup {}

            AfterEach {
                Assert-VerifiableMock
            }

            $getTargetResourceParams = @{
                Name                      = 'DatabaseAvailabilityGroupNetwork'
                Credential                = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
                DatabaseAvailabilityGroup = 'DatabaseAvailabilityGroup'
                Ensure                    = 'Present'
            }

            $getDatabaseAvailabilityGroupNetworkStandardOutput = @{
                IgnoreNetwork      = [System.Boolean] $false
                ReplicationEnabled = [System.Boolean] $false
                Subnets            = [System.String[]] @()
            }

            Context 'When Get-TargetResource is called' {
                Mock -CommandName Write-FunctionEntry -Verifiable
                Mock -CommandName Get-RemoteExchangeSession -Verifiable
                Mock -CommandName Get-DatabaseAvailabilityGroupNetworkInternal -Verifiable -MockWith { return $getDatabaseAvailabilityGroupNetworkStandardOutput }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $getTargetResourceParams
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
