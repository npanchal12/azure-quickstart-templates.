param(
[Parameter(Mandatory=$true,Position=0)]
[string]$TemplateText,

[Parameter(Mandatory=$true,Position=1)]
[string]$TemplateObject,

[Parameter(Mandatory=$true,Position=1)]
[switch]$IsMainTemplate
)

# First, create a copy of the template object
$TemplateObjectCopy = $templateText | ConvertFrom-Json
# Then remove the location property
$TemplateObjectCopy.parameters.psobject.properties.remove('location')
# and turn it back into JSON.
$TemplateWithoutLocationParameter = $TemplateObjectCopy | 
    ConvertTo-Json -Depth 10        

# Now get the location parameter 
$locationParameter = $templateObject.parameters.location

# Make sure that the template parameter's default is the expression [resourceGroup().location] 
if ($locationParameter -and 
    "$($locationParameter.defaultvalue)".Trim() -ne '[resourceGroup().location]' -and
    "$($locationParameter.defaultValue)".Trim() -ne 'global' -and 
    $IsMainTemplate) {
    # If it wasn't, write an error
    Write-Error "Location parameter must not be hardcoded.  The default value should be [resourceGroup().location]." -ErrorId Location.Parameter.Hardcoded -TargetObject $parameter
}

# Now check that the rest of the template doesn't use [resourceGroup().location] 
if ($TemplateWithoutLocationParameter -like '*resourceGroup().location*') {
    # If it did, write an error
    Write-Error "$TemplateFileName must use the location parameter, not resourceGroup().location (except when used as a default value)" -ErrorId Location.Parameter.Should.Be.Used -TargetObject $parameter
}