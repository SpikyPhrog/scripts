$DestFolder = gl
$ProjectDest = $DestFolder.Path

$ProjectNameStartIndex = $ProjectDest.Length

while($ProjectNameStartIndex -ge 0)
{
	if($ProjectDest[$ProjectNameStartIndex] -like "\")
	{
		break
	}
	
	$ProjectNameStartIndex--
}

for($i = $ProjectNameStartIndex + 1; $i -lt $ProjectDest.Length; $i++)
{
	$ProjectName += $ProjectDest[$i]
}

$SourceFolderFiles = New-Object System.Collections.Generic.List[System.Object]
Get-ChildItem -filter *.cpp -Path $ProjectName\ -Recurse | % {$SourceFolderFiles.add($_)}

$HeaderFolderFiles = New-Object System.Collections.Generic.List[System.Object]
Get-ChildItem -filter *.h -Path $ProjectName\ -Recurse | % {$HeaderFolderFiles.add($_)}

$SourceIncludes = New-Object System.Collections.Generic.List[System.Object]

$HeaderIncludes = New-Object System.Collections.Generic.List[System.Object]

$ProjectFolder = $ProjectDest + '\' + $ProjectName

for ($i = 0; $i -lt $SourceFolderFiles.Count; $i++)
{
    $sourceIncludeName = $SourceFolderFiles[$i].FullName;

    $finalIncludeName = ''
    
    for($j = $ProjectFolder.Length + 1; $j -lt $sourceIncludeName.Length; $j++) #added +1 to $i so I can avoid the '\' from the path
    {
        $finalIncludeName += $sourceIncludeName[$j];
    }
    
    $SourceIncludes.add($finalIncludeName)
}

for ($i = 0; $i -lt $HeaderFolderFiles.Count; $i++)
{
    $HeaderIncludeName = $HeaderFolderFiles[$i].FullName;

    $finalIncludeName = ''
    
    for($j = $ProjectFolder.Length + 1; $j -lt $HeaderIncludeName.Length; $j++) #added +1 to $i so I can avoid the '\' from the path
    {
        $finalIncludeName += $HeaderIncludeName[$j];
    }
    
    $HeaderIncludes.add($finalIncludeName)
}

#find the vcxproj file
[string]$projSettingsPath = $ProjectDest + '\' + $ProjectName + '\' + $ProjectName + '.vcxproj'

$projectSettings = New-Object xml
$projectSettings.load($projSettingsPath)

if ($null -eq $projectSettings)
{
	echo "There is no VS project settings file to modify!"
}
else
{
    $ItemGroupCount = $projectSettings.project.ItemGroup.Count # get the size of the ItemGroup array

    $projectSettings.project.RemoveChild($projectSettings.project.ItemGroup[$ItemGroupCount - 1]) #remove the last element

    $ItemGroupCount = $projectSettings.project.ItemGroup.Count # update the value

    $projectSettings.project.RemoveChild($projectSettings.project.ItemGroup[$ItemGroupCount - 1]) #remove the last element after the update; Ultimately we remove the header and source includes

    #create the group for the source includes
    $SourceItemGroup = $projectSettings.CreateElement("ItemGroup", $projectSettings.project.NamespaceURI)
    $projectSettings.project.AppendChild($SourceItemGroup)

    #create the group for the header includes
    $HeaderItemGroup = $projectSettings.CreateElement("ItemGroup", $projectSettings.project.NamespaceURI)
    $projectSettings.project.AppendChild($HeaderItemGroup)

    #populate the source includes
    for($i = 0; $i -lt $SourceIncludes.Count; $i++)
    {
       $SourceInclude = $projectSettings.CreateElement("ClCompile", $projectSettings.Project.NamespaceURI)
       $SourceInclude.setAttribute("Include", $SourceIncludes[$i])
       $SourceInclude.RemoveAttribute("xmlns")
       $SourceItemGroup.AppendChild($SourceInclude)
    }

    #populate the header includes
    for($i = 0; $i -lt $HeaderIncludes.Count; $i++)
    {
        $HeaderInclude = $projectSettings.CreateElement("ClCompile", $projectSettings.Project.NamespaceURI)
        $HeaderInclude.setAttribute("Include", $HeaderIncludes[$i])
        $HeaderInclude.RemoveAttribute("xmlns")
        $HeaderItemGroup.AppendChild($HeaderInclude)
    }
    
    $projectSettings.Save($projSettingsPath)
}