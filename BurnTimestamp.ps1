#
# Copyright 2019 Laurent Goulet
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
# documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to 
# permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of 
# the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
# WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
# OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

param(
  [string]$images,
  [string]$suffix=""
)

if ([string]::IsNullOrWhiteSpace($images)) {
  Write-Host "Missing images argument"
  Exit
}
$files = Get-ChildItem $images | Select-Object -Expand FullName

$posX = 70
$posY = 40
$weight = 600
ForEach ($image in $files) {
  Try {
    #$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    $exif = magick $image -format "%[EXIF:datetime]/%[EXIF:PixelXDimension]/%[EXIF:PixelYDimension]\n" info: 2>&1
    $fields = $exif -Split "/"
    $datetaken = $($fields[0]) -Replace "^([0-9]{4}):([0-9]{2}):([0-9]{2}) ([0-9]{1,2}:[0-9]{2}):.*$", '$1-$2-$3 $4'
    $width  = $($fields[1])
    $height = $($fields[2])
    $width  = [int]$width
    $height = [int]$height

    Write-Host "INFO: $image"
    Write-Host "  taken $datetaken"
    Write-Host "  size  $width by $height"

    $text = "'$datetaken'"
    $pointsize = 0.5*($width+$height)*(1.0/50.0)
    $file = New-Object System.IO.FileInfo($image)
    $base = "$($file.DirectoryName)\$($file.BaseName)"
    $ext = $file.Extension
    $out = "${base}${suffix}${ext}"
    Write-Host "  pointsize $pointsize"
    Write-Host "  saving to $out"
    magick $image -fill orange -stroke black -strokewidth 2 -pointsize $pointsize -weight $weight -gravity SouthEast -draw "text $posX,$posY $text" $out

    #$stopwatch.Stop()
    #$elapsed = $stopwatch.Elapsed.TotalSeconds
    #Write-Host "  took $elapsed seconds"
  }
  catch {
    Write-Host "No EXIF information for $image"
  }
}