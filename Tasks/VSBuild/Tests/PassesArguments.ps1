[CmdletBinding()]
param()

# Arrange.
. $PSScriptRoot\..\..\..\Tests\lib\Initialize-Test.ps1
$variableSets = @(
    # Variable combinations to assert Booleans are passed correctly.
    @{ Clean = $false ; MaximumCpuCount = $false ; RestoreNugetPackages = $false ; LogProjectEvents = $false ; CreateLogFile = $true ; VSVersion = '14.0' }
    @{ Clean = $false ; MaximumCpuCount = $false ; RestoreNugetPackages = $false ; LogProjectEvents = $true ; CreateLogFile = $false ; VSVersion = '14.0' }
    @{ Clean = $false ; MaximumCpuCount = $false ; RestoreNugetPackages = $true ; LogProjectEvents = $false ; CreateLogFile = $false ; VSVersion = '14.0' }
    @{ Clean = $false ; MaximumCpuCount = $true ; RestoreNugetPackages = $false ; LogProjectEvents = $false ; CreateLogFile = $false ; VSVersion = '14.0' }
    @{ Clean = $true ; MaximumCpuCount = $false ; RestoreNugetPackages = $false ; LogProjectEvents = $false ; CreateLogFile = $false ; VSVersion = '14.0' }
)
foreach ($variableSet in $variableSets) {
    Unregister-Mock Get-VstsInput
    Unregister-Mock Get-SolutionFiles
    Unregister-Mock Select-VSVersion
    Unregister-Mock Select-MSBuildPath
    Unregister-Mock Format-MSBuildArguments
    Unregister-Mock Invoke-BuildTools
    Register-Mock Get-VstsInput { $variableSet.VSVersion } -- -Name VSVersion
    Register-Mock Get-VstsInput { 'Some input architecture' } -- -Name MSBuildArchitecture
    Register-Mock Get-VstsInput { 'Some input arguments' } -- -Name MSBuildArgs
    Register-Mock Get-VstsInput { 'Some input solution' } -- -Name Solution -Require
    Register-Mock Get-VstsInput { 'Some input platform' } -- -Name Platform
    Register-Mock Get-VstsInput { 'Some input configuration' } -- -Name Configuration
    Register-Mock Get-VstsInput { $variableSet.Clean } -- -Name Clean -AsBool
    Register-Mock Get-VstsInput { $variableSet.MaximumCpuCount } -- -Name MaximumCpuCount -AsBool
    Register-Mock Get-VstsInput { $variableSet.RestoreNuGetPackages } -- -Name RestoreNuGetPackages -AsBool
    Register-Mock Get-VstsInput { $variableSet.LogProjectEvents } -- -Name LogProjectEvents -AsBool
    Register-Mock Get-VstsInput { $variableSet.CreateLogFile } -- -Name CreateLogFile -AsBool
    Register-Mock Get-SolutionFiles { 'Some solution 1', 'Some solution 2' } -- -Solution 'Some input solution'
    Register-Mock Select-VSVersion { $variableSet.VSVersion } -- -PreferredVersion $variableSet.VSVersion
    Register-Mock Select-MSBuildPath { 'Some MSBuild location' } -- -PreferredVersion $variableSet.VSVersion -Architecture 'Some input architecture'
    Register-Mock Format-MSBuildArguments { 'Some formatted arguments' } -- -MSBuildArguments 'Some input arguments' -Platform 'Some input platform' -Configuration 'Some input configuration' -VSVersion $variableSet.VSVersion -MaximumCpuCount: $variableSet.MaximumCpuCount
    Register-Mock Invoke-BuildTools { 'Some build output' }

    # Act.
    $output = & $PSScriptRoot\..\VSBuild.ps1

    # Assert.
    Assert-AreEqual 'Some build output' $output
    Assert-WasCalled Invoke-BuildTools -- -NuGetRestore: $variableSet.RestoreNuGetPackages -SolutionFiles @('Some solution 1', 'Some solution 2') -MSBuildLocation 'Some MSBuild location' -MSBuildArguments 'Some formatted arguments' -Clean: $variableSet.Clean -NoTimelineLogger: $(!$variableSet.LogProjectEvents) -CreateLogFile: $variableSet.CreateLogFile
}
