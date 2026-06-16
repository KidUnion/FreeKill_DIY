param(
  [string]$Root,
  [Alias("PathSpec")]
  [string]$FileGlob = "../../*/pkg/*/init.lua",
  [switch]$Plain,
  [switch]$SelfTest
)

if ($env:OS -eq "Windows_NT") {
  chcp.com 65001 | Out-Null
}

$OutputEncoding = [System.Text.UTF8Encoding]::new()
[Console]::InputEncoding = [System.Text.UTF8Encoding]::new()
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$env:LESSCHARSET = "utf-8"

function Get-ThirdQuotedValue {
  param([string]$Line)

  $quotes = [regex]::Matches($Line, '"')
  if ($quotes.Count -lt 4) {
    return $null
  }

  $start = $quotes[2].Index + 1
  $length = $quotes[3].Index - $start
  if ($length -lt 0) {
    return $null
  }

  $value = $Line.Substring($start, $length)
  if ($value -match "[\u4e00-\u9fff]") {
    return $value
  }

  return $null
}

function Get-TranslationNamesFromAddedLines {
  param([string[]]$AddedLines)

  $names = New-Object System.Collections.Generic.List[string]

  for ($i = 0; $i -lt $AddedLines.Count - 1; $i++) {
    if ($AddedLines[$i] -like "*Fk:loadTranslationTable{*") {
      $name = Get-ThirdQuotedValue -Line $AddedLines[$i + 1]
      if ($null -ne $name -and $name -ne "") {
        $names.Add($name)
      }
    }
  }

  return $names
}

function ConvertTo-GitRelativePath {
  param(
    [string]$BasePath,
    [string]$Path
  )

  $trimChars = [char[]]@('\', '/')
  $baseFullPath = [System.IO.Path]::GetFullPath($BasePath).TrimEnd($trimChars) + [System.IO.Path]::DirectorySeparatorChar
  $targetFullPath = [System.IO.Path]::GetFullPath($Path)
  $baseUri = New-Object System.Uri($baseFullPath)
  $targetUri = New-Object System.Uri($targetFullPath)

  return [System.Uri]::UnescapeDataString($baseUri.MakeRelativeUri($targetUri).ToString()) -replace "\\", "/"
}

if ($SelfTest) {
  $nameA = "$([char]0x59cb)$([char]0x7ec8)$([char]0x4e4b)$([char]0x7565)"
  $nameB = "$([char]0x79fb)$([char]0x52a8)$([char]0x7248)"
  $sample = @(
    "Fk:loadTranslationTable{",
    "  [""shzl""] = ""$nameA"",",
    "}",
    "Fk:loadTranslationTable{",
    "  [""mobile""] = ""$nameB"","
  )

  $actual = @(Get-TranslationNamesFromAddedLines -AddedLines $sample)
  $expected = @($nameA, $nameB)

  if ($actual.Count -ne $expected.Count) {
    throw "Self test failed: expected $($expected.Count) results, got $($actual.Count)."
  }

  for ($i = 0; $i -lt $expected.Count; $i++) {
    if ($actual[$i] -ne $expected[$i]) {
      throw "Self test failed at index ${i}: expected '$($expected[$i])', got '$($actual[$i])'."
    }
  }

  "Self test passed."
  exit 0
}

if ([string]::IsNullOrWhiteSpace($Root)) {
  if ([string]::IsNullOrWhiteSpace($PSScriptRoot)) {
    $Root = (Get-Location).Path
  } else {
    $Root = $PSScriptRoot
  }
}

$rootPath = (Resolve-Path -LiteralPath $Root).Path
$searchPath = if ([System.IO.Path]::IsPathRooted($FileGlob)) {
  $FileGlob
} else {
  Join-Path $rootPath $FileGlob
}

$files = @(
  Get-ChildItem -Path $searchPath -File -ErrorAction SilentlyContinue |
    Sort-Object -Property FullName -Unique
)

$repoFiles = @{}

foreach ($file in $files) {
  $topLevel = (& git -C $file.DirectoryName rev-parse --show-toplevel 2>$null)
  if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($topLevel)) {
    continue
  }

  $repoRoot = [System.IO.Path]::GetFullPath($topLevel.Trim())
  $relativePath = ConvertTo-GitRelativePath -BasePath $repoRoot -Path $file.FullName

  if (-not $repoFiles.ContainsKey($repoRoot)) {
    $repoFiles[$repoRoot] = New-Object System.Collections.Generic.List[string]
  }

  $repoFiles[$repoRoot].Add($relativePath)
}

foreach ($repoRoot in ($repoFiles.Keys | Sort-Object)) {
  $paths = @($repoFiles[$repoRoot] | Sort-Object -Unique)
  if ($paths.Count -eq 0) {
    continue
  }

  $gitArgs = @(
    "-c", "core.quotepath=false",
    "-c", "i18n.logOutputEncoding=utf-8",
    "-C", $repoRoot,
    "diff", "HEAD~1", "HEAD", "--unified=0", "--"
  ) + $paths

  $diff = & git @gitArgs 2>$null

  if ($LASTEXITCODE -ne 0) {
    continue
  }

  $addedLines = @(
    foreach ($line in $diff) {
      if ($line -match "^\+[^+]") {
        $line.Substring(1)
      }
    }
  )

  $names = @(Get-TranslationNamesFromAddedLines -AddedLines $addedLines)
  $repoName = Split-Path -Leaf $repoRoot
  foreach ($name in $names) {
    if ($Plain) {
      $name
    } else {
      "$repoName`t$name"
    }
  }
}
