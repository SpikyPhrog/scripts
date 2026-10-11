$fileName = "SFML-2.6.1-windows-vc17-64-bit.zip"

$SFMLDownloadLink = "https://www.sfml-dev.org/files/" + $fileName

$DestFolder = gl
$ProjectDest = $DestFolder.Path
$ProjectName = ''

$ProjectDestLength = $ProjectDest.Length

$ProjectNameStartIndex = $ProjectDestLength

while($ProjectNameStartIndex -ge 0)
{
	if($ProjectDest[$ProjectNameStartIndex] -like "\")
	{
		break
	}
	
	$ProjectNameStartIndex--
}

for($i = $ProjectNameStartIndex + 1; $i -lt $ProjectDestLength; $i++)
{
	$ProjectName += $ProjectDest[$i]
}

[string]$projSettingsPath = $ProjectDest + '\' + $ProjectName + '\' + $ProjectName + '.vcxproj'

[xml]$projectSettings = Get-Content $projSettingsPath

if ($null -eq $projectSettings)
{
	echo "There is no VS project settings file to modify!"
}
else
{
	$debugWin32AdditionalDependencies = $projectSettings.CreateElement("AdditionalDependencies", $projectSettings.Project.NamespaceURI)
	$debugWin32AdditionalDependencies.set_innerText("sfml-system-d.lib;sfml-audio-d.lib;sfml-graphics-d.lib;sfml-network-d.lib;sfml-window-d.lib;%(AdditionalDependencies)")
	$debugWin32AdditionalDependencies.RemoveAttribute("xmlns")

	$projectSettings.Project.ItemDefinitionGroup[0].Link.AppendChild($debugWin32AdditionalDependencies)

	$releaseWin32AdditionalDependencies = $projectSettings.CreateElement("AdditionalDependencies", $projectSettings.Project.NamespaceURI)
	$releaseWin32AdditionalDependencies.set_innerText("sfml-system.lib;sfml-audio.lib;sfml-graphics.lib;sfml-network.lib;sfml-window.lib;%(AdditionalDependencies)")
	$releaseWin32AdditionalDependencies.RemoveAttribute("xmlns")

	$projectSettings.Project.ItemDefinitionGroup[1].Link.AppendChild($releaseWin32AdditionalDependencies)

	$debugX64AdditionalDependencies = $projectSettings.CreateElement("AdditionalDependencies", $projectSettings.Project.NamespaceURI)
	$debugX64AdditionalDependencies.set_innerText("sfml-system-d.lib;sfml-audio-d.lib;sfml-graphics-d.lib;sfml-network-d.lib;sfml-window-d.lib;%(AdditionalDependencies)")
	$debugX64AdditionalDependencies.RemoveAttribute("xmlns")

	$debugX64AdditionalLibraryDirectories = $projectSettings.CreateElement("AdditionalLibraryDirectories", $projectSettings.Project.NamespaceURI)
	$debugX64AdditionalLibraryDirectories.set_innerText('$(SolutionDir)/library;%(AdditionalLibraryDirectories)')
	$debugX64AdditionalLibraryDirectories.RemoveAttribute("xmlns")

	$debugX64AdditionalIncludeDirectories = $projectSettings.CreateElement("AdditionalIncludeDirectories", $projectSettings.Project.NamespaceURI)
	$debugX64AdditionalIncludeDirectories.set_innerText('$(SolutionDir)/include;%(AdditionalIncludeDirectories)') # need to use single quote string, because otherwise using the double quotes expands $ to look for a variable
	$debugX64AdditionalIncludeDirectories.RemoveAttribute("xmlns")

	$projectSettings.Project.ItemDefinitionGroup[2].Link.AppendChild($debugX64AdditionalLibraryDirectories)
	$projectSettings.Project.ItemDefinitionGroup[2].Link.AppendChild($debugX64AdditionalDependencies)
	$projectSettings.Project.ItemDefinitionGroup[2].ClCompile.AppendChild($debugX64AdditionalIncludeDirectories)

	$releaseX64AdditionalDependencies = $projectSettings.CreateElement("AdditionalDependencies", $projectSettings.Project.NamespaceURI)
	$releaseX64AdditionalDependencies.set_innerText("sfml-system.lib;sfml-audio.lib;sfml-graphics.lib;sfml-network.lib;sfml-window.lib;%(AdditionalDependencies)")
	$releaseX64AdditionalDependencies.RemoveAttribute("xmlns")

	$releaseX64AdditionalLibraryDirectories = $projectSettings.CreateElement("AdditionalLibraryDirectories", $projectSettings.Project.NamespaceURI)
	$releaseX64AdditionalLibraryDirectories.set_innerText('$(SolutionDir)/library;%(AdditionalLibraryDirectories)') # need to use single quote string, because otherwise using the double quotes expands $ to look for a variable
	$releaseX64AdditionalLibraryDirectories.RemoveAttribute("xmlns")

	$releaseX64AdditionalIncludeDirectories = $projectSettings.CreateElement("AdditionalIncludeDirectories", $projectSettings.Project.NamespaceURI)
	$releaseX64AdditionalIncludeDirectories.set_innerText('$(SolutionDir)/include;%(AdditionalIncludeDirectories)') # need to use single quote string, because otherwise using the double quotes expands $ to look for a variable
	$releaseX64AdditionalIncludeDirectories.RemoveAttribute("xmlns")

	$projectSettings.Project.ItemDefinitionGroup[3].Link.AppendChild($releaseX64AdditionalLibraryDirectories)
	$projectSettings.Project.ItemDefinitionGroup[3].Link.AppendChild($releaseX64AdditionalDependencies)
	$projectSettings.Project.ItemDefinitionGroup[3].ClCompile.AppendChild($releaseX64AdditionalIncludeDirectories)

	$projectSettings.Save($projSettingsPath)

	Invoke-WebRequest -Uri $SFMLDownloadLink -OutFile $DestFolder\$fileName

	Expand-Archive -LiteralPath $DestFolder\$fileName -DestinationPath $DestFolder

	Remove-Item $DestFolder\$fileName #clean up the file, because we won't really need it

	mkdir library

	mkdir include

	mkdir x64\Release

	mkdir x64\Debug

	$libFiles = @(
		'sfml-audio.lib',
		'sfml-graphics.lib',
		'sfml-network.lib',
		'sfml-system.lib',
		'sfml-window.lib',
		'sfml-audio-d.lib',
		'sfml-graphics-d.lib',
		'sfml-network-d.lib',
		'sfml-system-d.lib',
		'sfml-window-d.lib'
	)

	$releaseBinFiles = @(
		'openal32.dll',
		'sfml-audio-2.dll',
		'sfml-graphics-2.dll',
		'sfml-network-2.dll',
		'sfml-system-2.dll',
		'sfml-window-2.dll'
	)

	$debugBinFiles = @(
		'openal32.dll',
		'sfml-audio-d-2.dll',
		'sfml-graphics-d-2.dll',
		'sfml-network-d-2.dll',
		'sfml-system-d-2.dll',
		'sfml-window-d-2.dll'
	)

	Copy-Item -Force -Recurse -Path $DestFolder\SFML-2.6.1\include\SFML -Destination $DestFolder\include

	for($i = 0; $i -le $libFiles.Length; $i++)
	{
		$path = $ProjectDest + '\SFML-2.6.1\lib\' + $libFiles[$i]
		Copy-Item -Path $path -Destination $ProjectDest\library

		if($i -eq $libFiles.Length)
		{
			$pathToRemove = $ProjectDest + '\library\lib'
			Remove-Item -LiteralPath $pathToRemove -Force
		}
	}

	for	($i = 0; $i -le $releaseBinFiles.Length; $i++)
	{
		$path = $ProjectDest + '\SFML-2.6.1\bin\' + $releaseBinFiles[$i]
		Copy-Item -Path $path -Destination $DestFolder\x64\Release

		if($i -eq $releaseBinFiles.Length)
		{
			$pathToRemove = $ProjectDest + '\x64\Release\bin'
			Remove-Item -LiteralPath $pathToRemove -Force
		}
	}

	for	($i = 0; $i -le $debugBinFiles.Length; $i++)
	{
		$path = $ProjectDest + '\SFML-2.6.1\bin\' + $debugBinFiles[$i]
		Copy-Item -Path $path -Destination $DestFolder\x64\Debug

		if($i -eq $debugBinFiles.Length)
		{
			$pathToRemove = $ProjectDest + '\x64\Debug\bin'
			Remove-Item -LiteralPath $pathToRemove -Force
		}
	}

	$pathToSFML = $ProjectDest + '\SFML-2.6.1\'
	Remove-Item -LiteralPath $pathToSFML -Force -Recurse # Remove SFML folder 
}	