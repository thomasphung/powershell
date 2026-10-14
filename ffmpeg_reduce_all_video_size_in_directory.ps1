# Usage
# .\ffmpeg_reduce_all_video_size_in_directory.ps1 -InputDirectory "C:\Videos"
# Requires ffmpeg installed; saves encoded .mp4 video files to /encoded subdirectory, keeping same file name
param(
    [Parameter(Mandatory = $true)]
    [string]$InputDirectory,

    [string]$OutputDirectory = (Join-Path $InputDirectory "encoded")
)

if (-not (Test-Path -LiteralPath $InputDirectory -PathType Container)) {
    throw "Input directory not found: $InputDirectory"
}

New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null

Get-ChildItem -LiteralPath $InputDirectory -File | ForEach-Object {
    $outputPath = Join-Path $OutputDirectory ($_.BaseName + ".mp4")

    $ffmpegArgs = @(
        "-i", $_.FullName,
        "-c:v", "libx264",
        "-crf", "23",
        "-preset", "medium",
        "-c:a", "aac",
        "-b:a", "128k",
        "-movflags", "+faststart",
        $outputPath
    )

    Write-Host "Converting $($_.Name)..."
    & ffmpeg @ffmpegArgs

    if ($LASTEXITCODE -ne 0) {
        Write-Warning "FFmpeg failed on $($_.Name) (exit code $LASTEXITCODE)"
    }
}
