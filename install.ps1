<#
    뼈대 템플릿(Template/)을 Unity 프로젝트의 Assets 폴더로 복사하고 네임스페이스를 치환한다.
    규칙과 종료 코드는 Docs/Design/2026-09-18-복사템플릿설계.md 4장을 본다.
#>
[CmdletBinding()]
param(
    [string] $AssetsPath = '',
    [string] $Namespace = '',
    [switch] $DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$TemplateToken = 'Officina'

function Write-Fail {
    param(
        [string] $Message,
        [int] $Code
    )

    [Console]::Error.WriteLine("오류 : $Message")
    exit $Code
}

function Test-UnderRoot {
    param(
        [string] $Path,
        [string] $Root
    )

    $one = $Path.TrimEnd('\')
    $two = $Root.TrimEnd('\')
    if ($one.Equals($two, [System.StringComparison]::OrdinalIgnoreCase)) { return $true }

    return $one.StartsWith($two + '\', [System.StringComparison]::OrdinalIgnoreCase)
}

function Test-ReparsePoint {
    param([System.IO.FileSystemInfo] $Item)

    return (($Item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0)
}

# ---------------------------------------------------------------- 1) 인자 검사

if ([string]::IsNullOrWhiteSpace($AssetsPath)) {
    Write-Fail "-AssetsPath 를 줘야 한다 (Unity 프로젝트의 Assets 폴더)" 2
}

if ([string]::IsNullOrWhiteSpace($Namespace)) {
    Write-Fail "-Namespace 를 줘야 한다 (예: MyGame)" 2
}

$namespacePattern = '^[A-Za-z_][A-Za-z0-9_]*(\.[A-Za-z_][A-Za-z0-9_]*)*$'
if ($Namespace -notmatch $namespacePattern) {
    Write-Fail "네임스페이스 꼴이 아니다 : $Namespace" 2
}

if ($Namespace.Split('.') -contains $TemplateToken) {
    Write-Fail "네임스페이스에 템플릿 이름 토큰이 들어 있다 (치환이 무의미하고 잔여 검사가 못 돈다) : $Namespace" 2
}

$reserved = @(
    'abstract', 'as', 'base', 'bool', 'break', 'byte', 'case', 'catch', 'char', 'checked',
    'class', 'const', 'continue', 'decimal', 'default', 'delegate', 'do', 'double', 'else',
    'enum', 'event', 'explicit', 'extern', 'false', 'finally', 'fixed', 'float', 'for',
    'foreach', 'goto', 'if', 'implicit', 'in', 'int', 'interface', 'internal', 'is', 'lock',
    'long', 'namespace', 'new', 'null', 'object', 'operator', 'out', 'override', 'params',
    'private', 'protected', 'public', 'readonly', 'ref', 'return', 'sbyte', 'sealed',
    'short', 'sizeof', 'stackalloc', 'static', 'string', 'struct', 'switch', 'this',
    'throw', 'true', 'try', 'typeof', 'uint', 'ulong', 'unchecked', 'unsafe', 'ushort',
    'using', 'virtual', 'void', 'volatile', 'while'
)
foreach ($part in $Namespace.Split('.')) {
    if ($reserved -ccontains $part) {
        Write-Fail "네임스페이스 토막이 C# 예약어다 : $part" 2
    }
}

# ---------------------------------------------------------------- 2) 목적지 검사

$rawParts = $AssetsPath -split '[\\/]'
if ($rawParts -contains '..') {
    Write-Fail "대상 경로에 '..' 이 있다 : $AssetsPath" 3
}
if ($AssetsPath.IndexOfAny([char[]]@('*', '?', '[', ']')) -ge 0) {
    Write-Fail "대상 경로에 와일드카드 글자(* ? [ ])가 있다 (-Destination 이 해석한다) : $AssetsPath" 2
}

if (-not (Test-Path -LiteralPath $AssetsPath)) {
    Write-Fail "대상 경로가 없다 : $AssetsPath" 2
}

$destItem = Get-Item -LiteralPath $AssetsPath -Force
if (-not $destItem.PSIsContainer) {
    Write-Fail "대상이 폴더가 아니다 : $AssetsPath" 2
}
if (Test-ReparsePoint $destItem) {
    Write-Fail "대상 폴더가 링크·정션이다 : $AssetsPath" 3
}

$dest = (Resolve-Path -LiteralPath $AssetsPath).ProviderPath.TrimEnd('\')
if ((Split-Path -Leaf $dest) -ne 'Assets') {
    Write-Fail "대상은 Unity 프로젝트의 Assets 폴더여야 한다 : $dest" 2
}

$projectRoot = Split-Path -Parent $dest
$versionFile = Join-Path $projectRoot 'ProjectSettings\ProjectVersion.txt'
if (-not (Test-Path -LiteralPath $versionFile -PathType Leaf)) {
    Write-Fail "ProjectSettings\ProjectVersion.txt 가 없다 (Unity 프로젝트가 아니다) : $projectRoot" 2
}

$unityVersion = (Get-Content -LiteralPath $versionFile -TotalCount 1) -replace '^m_EditorVersion:\s*', ''

# git 미커밋 변경은 막지 않고 경고만 한다 (설계 4-5).
# 오류를 삼키는 자리 ① — git 이 없거나 저장소가 아니면 경고를 건너뛴다.
$dirtyCount = 0
$savedPreference = $ErrorActionPreference
try {
    # PS 5.1 은 네이티브 명령의 stderr 를 오류로 본다. Stop 이면 git 이 경고만 찍어도 여기가 통째로 날아간다.
    $ErrorActionPreference = 'Continue'
    $gitLines = & git -C $projectRoot status --porcelain 2>$null
    if ($LASTEXITCODE -eq 0) {
        foreach ($line in $gitLines) {
            if ($line.Trim().Length -gt 0) { $dirtyCount++ }
        }
    }
}
catch {
    $dirtyCount = 0
}
finally {
    $ErrorActionPreference = $savedPreference
}

# ---------------------------------------------------------------- 3) 원본 훑기

$templateRoot = Join-Path $PSScriptRoot 'Template'
if (-not (Test-Path -LiteralPath $templateRoot -PathType Container)) {
    Write-Fail "원본 폴더가 없다 : $templateRoot" 2
}

$srcRoot = (Resolve-Path -LiteralPath $templateRoot).ProviderPath.TrimEnd('\')

# PS 5.1 의 -Recurse 는 정션 폴더를 따라 들어가 Template 밖 내용을 긁어 온다. 직접 내려간다.
$sourceFiles = @()
$skippedLinks = 0
$pending = New-Object System.Collections.Stack
$pending.Push($srcRoot) | Out-Null
while ($pending.Count -gt 0) {
    $dir = $pending.Pop()
    foreach ($found in (Get-ChildItem -LiteralPath $dir -Force)) {
        if (Test-ReparsePoint $found) {
            $skippedLinks++
            continue
        }
        if (-not (Test-UnderRoot $found.FullName $srcRoot)) {
            $skippedLinks++
            continue
        }

        if ($found.PSIsContainer) {
            $pending.Push($found.FullName) | Out-Null
            continue
        }

        $sourceFiles += $found
    }
}

if ($sourceFiles.Count -eq 0) {
    Write-Fail "원본에 복사할 파일이 0장이다 (Template 폴더가 비었거나 전부 링크다 · 링크 $skippedLinks 개) : $srcRoot" 2
}

# ---------------------------------------------------------------- 4) 목적지 계산 + 경로 감옥 + 5) 계획표

$plan = @()
$checkedDirs = @{}
foreach ($source in $sourceFiles) {
    $rel = $source.FullName.Substring($srcRoot.Length).TrimStart('\', '/')

    $relDir = Split-Path -Parent $rel
    $leaf = Split-Path -Leaf $rel
    if ($leaf -like '*.asmdef') {
        $leaf = $leaf -replace ('^' + $TemplateToken + '\.'), ($Namespace + '.')
    }

    if ($relDir.Length -eq 0) { $rel = $leaf }
    if ($relDir.Length -gt 0) { $rel = Join-Path $relDir $leaf }

    if ($rel -match '(^|[\\/])\.\.([\\/]|$)') {
        Write-Fail "상대경로에 '..' 이 있다 : $rel" 3
    }
    if ($rel.Contains(':')) {
        Write-Fail "상대경로에 ':' 이 있다 : $rel" 3
    }
    if ([System.IO.Path]::IsPathRooted($rel)) {
        Write-Fail "상대경로가 절대경로다 : $rel" 3
    }

    $target = Join-Path $dest $rel

    $probe = Split-Path -Parent $target
    while (-not (Test-Path -LiteralPath $probe)) {
        $probe = Split-Path -Parent $probe
    }

    $probeFull = (Resolve-Path -LiteralPath $probe).ProviderPath.TrimEnd('\')
    if (-not (Test-UnderRoot $probeFull $dest)) {
        Write-Fail "목적지가 Assets 밖으로 나간다 : $target" 3
    }

    # 가장 가까운 조상 하나만 봐서는 중간 정션을 놓친다. $dest 까지 모든 조상을 본다.
    $walk = $probeFull
    while ($true) {
        if (-not $checkedDirs.ContainsKey($walk.ToLowerInvariant())) {
            $walkItem = Get-Item -LiteralPath $walk -Force
            if (Test-ReparsePoint $walkItem) {
                Write-Fail "목적지 조상 폴더가 링크·정션이다 : $walk" 3
            }

            $checkedDirs[$walk.ToLowerInvariant()] = $true
        }

        if ($walk.Equals($dest, [System.StringComparison]::OrdinalIgnoreCase)) { break }

        $up = Split-Path -Parent $walk
        if ([string]::IsNullOrEmpty($up) -or $up.TrimEnd('\').Equals($walk, [System.StringComparison]::OrdinalIgnoreCase)) {
            Write-Fail "목적지 조상을 거슬러 올라가다 Assets 를 못 만났다 : $probeFull" 3
        }

        $walk = $up.TrimEnd('\')
    }

    if (Test-Path -LiteralPath $target -PathType Container) {
        Write-Fail "목적지가 이미 폴더다 : $target" 3
    }

    $action = '만듦'
    if (Test-Path -LiteralPath $target -PathType Leaf) {
        $action = '건너뜀'
        if ([System.IO.Path]::GetExtension($leaf) -eq '.globalconfig') { $action = '덮음' }
    }

    $plan += [PSCustomObject]@{
        Action = $action
        Rel    = $rel
        Source = $source.FullName
        Target = $target
        Backup = ''
    }
}

# ---------------------------------------------------------------- 6) 계획 찍기

if ($dirtyCount -gt 0) {
    Write-Host "경고 : 목적지 저장소에 미커밋 변경 $dirtyCount 건이 있다."
    Write-Host ''
}

$mode = '실복사'
if ($DryRun) { $mode = 'dry-run (아무것도 쓰지 않는다)' }

Write-Host "대상  : $dest            (Unity $unityVersion · ProjectSettings 확인)"
Write-Host "이름  : $TemplateToken.  ->  $Namespace."
Write-Host "모드  : $mode"
Write-Host ''
Write-Host '| 처리  | 경로 |'
Write-Host '| ---   | --- |'
foreach ($item in $plan) {
    Write-Host ("| {0,-4} | {1} |" -f $item.Action, $item.Rel)
}
Write-Host ''

$plannedCreate = 0
$plannedOver = 0
$plannedSkip = 0
foreach ($item in $plan) {
    if ($item.Action -eq '만듦') { $plannedCreate++ }
    if ($item.Action -eq '덮음') { $plannedOver++ }
    if ($item.Action -eq '건너뜀') { $plannedSkip++ }
}

if ($DryRun) {
    Write-Host "만듦 $plannedCreate · 덮음 $plannedOver · 건너뜀 $plannedSkip (dry-run 이라 쓰지 않았다)"
    exit 0
}

# ---------------------------------------------------------------- 7) 쓰기

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$written = @()
$replaceCount = 0

foreach ($item in $plan) {
    if ($item.Action -eq '건너뜀') { continue }

    try {
        $text = [System.IO.File]::ReadAllText($item.Source, [System.Text.Encoding]::UTF8)

        $patternDotted = '\b' + $TemplateToken + '\.'
        $replacement = $Namespace + '.'
        $replaceCount += ([regex]$patternDotted).Matches($text).Count
        $text = [regex]::Replace($text, $patternDotted, $replacement)

        if ($item.Rel -like '*.asmdef') {
            $patternQuoted = '"' + $TemplateToken + '"'
            $replaceCount += ([regex]$patternQuoted).Matches($text).Count
            $text = [regex]::Replace($text, $patternQuoted, ('"' + $Namespace + '"'))
        }

        $text = $text -replace "`r`n", "`n"
        $text = $text -replace "`r", "`n"

        if ($item.Action -eq '덮음') {
            # 백업은 Assets 밖(프로젝트 루트)에 둔다. Assets 안에 두면 Unity 가 .meta 를 만든다.
            $item.Backup = Join-Path $projectRoot "$(Split-Path -Leaf $item.Target).bak-$stamp"
            Copy-Item -LiteralPath $item.Target -Destination $item.Backup
        }

        $parent = Split-Path -Parent $item.Target
        if (-not (Test-Path -LiteralPath $parent)) {
            New-Item -ItemType Directory -Path $parent | Out-Null
        }

        $tmp = "$($item.Target).tmp-$PID"
        [System.IO.File]::WriteAllText($tmp, $text, $utf8NoBom)
        try {
            Move-Item -LiteralPath $tmp -Destination $item.Target -Force
        }
        catch {
            # 스크립트 안의 유일한 삭제 — 방금 자기가 만든 tmp 파일만 지운다.
            if (Test-Path -LiteralPath $tmp -PathType Leaf) {
                Remove-Item -LiteralPath $tmp -ErrorAction SilentlyContinue
            }
            throw
        }

        if ($item.Action -eq '덮음') {
            $readBack = [System.IO.File]::ReadAllText($item.Target, [System.Text.Encoding]::UTF8)
            if ($readBack -ne $text) {
                Write-Fail "덮어쓴 파일을 다시 읽었더니 내용이 다르다 : $($item.Target)" 6
            }
        }

        $written += $item
    }
    catch {
        [Console]::Error.WriteLine("쓰기 실패 : $($item.Target)")
        [Console]::Error.WriteLine($_.Exception.Message)
        [Console]::Error.WriteLine("여기까지 쓴 파일 $($written.Count) 장 :")
        foreach ($done in $written) {
            [Console]::Error.WriteLine("  $($done.Rel)")
        }
        exit 4
    }
}

# ---------------------------------------------------------------- 8) 치환 잔여 검사

$residual = @()
foreach ($item in $written) {
    $lines = [System.IO.File]::ReadAllLines($item.Target, [System.Text.Encoding]::UTF8)
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match ('\b' + $TemplateToken + '\.')) {
            $residual += "$($item.Rel):$($i + 1)"
        }
        if (($item.Rel -like '*.asmdef') -and ($lines[$i] -match ('"' + $TemplateToken + '"'))) {
            $residual += "$($item.Rel):$($i + 1)"
        }
    }
}

if ($residual.Count -gt 0) {
    [Console]::Error.WriteLine("치환 잔여 $($residual.Count) 곳 (고치지도 지우지도 않았다) :")
    foreach ($spot in $residual) {
        [Console]::Error.WriteLine("  $spot")
    }
    exit 5
}

# ---------------------------------------------------------------- 9) 보고

$doneCreate = 0
$doneOver = 0
foreach ($item in $written) {
    if ($item.Action -eq '만듦') { $doneCreate++ }
    if ($item.Action -eq '덮음') {
        $doneOver++
        Write-Host "백업  : $($item.Backup)"
    }
}

Write-Host "만듦 $doneCreate · 덮음 $doneOver · 건너뜀 $plannedSkip · 치환 $replaceCount 곳 · 잔여 토큰 0"
Write-Host ''
Write-Host '사용자가 할 일'
# 이 스크립트는 게임 저장소 자리에서 도는 일이 많다. 상대 경로로 찍으면 거기엔 없는 길이 된다.
$unityCliDoc = Join-Path $PSScriptRoot 'Docs\Guide\UnityCLI함정.md'
Write-Host '  1. Unity 를 열어 컴파일 오류 0 을 본다'
Write-Host "     (에디터가 열려 있고 Unity CLI 가 있으면 recompile 과 콘솔 오류 보기로 확인한다 — $unityCliDoc)"
Write-Host '  2. .meta 가 새로 생긴 것을 커밋한다'
Write-Host '  3. Sample 폴더를 .meta 와 함께 지우고 자기 Master 를 만든다'
Write-Host '     (Unity 의 Project 창에서 지우거나 Unity CLI 의 자산 지우기 명령으로)'

exit 0
