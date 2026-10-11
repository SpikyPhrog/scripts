param([string]
	$inFileName,
	[int]$newWidth,
	[int]$newHeight
)

$wia = New-Object -ComObject wia.imagefile

$currentDir = gl
[string]$extension = ""

[int]$rightPtrExtension = $inFileName.Length

for($rightPtrExtension -ge 0)
{
	if($inFileName[$rightPtrExtension] -like ".")
	{
		break
	}
	
	$extension += $inFileName[$rightPtrExtension]
	$rightPtrExtension --;
}

[string]$correctedExt = ""
[string]$fileName = ""

#
#	if we leave $rightPtrExtension as it is, it will include the "." at the end of the name
#	if we don't want to do that, just add a -1 to the $i -le $rightPtrExtension and it will exclude the .
#
for	($i = 0; $i -le $rightPtrExtension - 1; $i++)
{
	$fileName += $inFileName[$i]
}

for	($currentIndex = $extension.Length; $currentIndex -ge 0; $currentIndex--)
{
	$correctedExt += $extension[$currentIndex]
}

$wia.LoadFile($currentDir.Path + '\' + $inFileName)
$wip = New-Object -ComObject wia.imageprocess
$Scale = $wip.FilterInfos.Item("Scale").FilterID

$wip.Filters.Add($Scale)
$wip.Filters[1].Properties("MaximumWidth") = $newWidth
$wip.Filters[1].Properties("MaximumHeight") = $newHeight

$wip.Filters[1].Properties("PreserveAspectRatio") = $false
$wip.Apply($wia)

$newImage = $wip.Apply($wia)

[int]$fileCopies = 0
[string]$newPath = $currentDir.Path + '\' + $fileName + '_' + $fileCopies + '.' + $correctedExt

while($true)
{	
	if([System.IO.File]::Exists($newPath))
	{
		$fileCopies ++;
		$newPath = $currentDir.Path + '\' + $fileName + '_' + $fileCopies + '.' + $correctedExt
	}
	else
	{
		break
	}
}	

$newImage.SaveFile($newPath)

