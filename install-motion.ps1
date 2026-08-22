<#
.SYNOPSIS
    Automates full installation of Next.js dependencies, Framer Motion, and Lucide React icons.
.DESCRIPTION
    Detects the active package manager (pnpm, yarn, bun, or npm), discovers Node.js / npm even if
    not in PATH, installs all dependencies, and configures the cn() helper utility.
#>

[CmdletBinding()]
param (
    [switch]$Force
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host "`n[+] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "[!] $Message" -ForegroundColor Yellow
}

function Write-Err {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Ensure-NodePath {
    # Check if npm or node is already reachable
    if (Get-Command "npm" -ErrorAction SilentlyContinue) {
        return
    }

    # Search common Node.js install paths on Windows
    $candidatePaths = @(
        "C:\Program Files\nodejs",
        "C:\Program Files (x86)\nodejs",
        "$env:LOCALAPPDATA\Programs\node",
        "$env:LOCALAPPDATA\Programs\nodejs",
        "$env:APPDATA\npm",
        "$env:LOCALAPPDATA\fnm_multishells\*",
        "$env:LOCALAPPDATA\Volta\bin",
        "$env:APPDATA\nvm\*"
    )

    foreach ($pathPattern in $candidatePaths) {
        $matched = Get-Item $pathPattern -ErrorAction SilentlyContinue
        foreach ($item in $matched) {
            $testExe = Join-Path $item.FullName "npm.cmd"
            if (Test-Path $testExe) {
                Write-Warn "Found Node.js at $($item.FullName). Adding to PATH for this session..."
                $env:Path = "$($item.FullName);$env:Path"
                return
            }
        }
    }
}

try {
    Write-Host "==========================================" -ForegroundColor Magenta
    Write-Host "  Next.js Animation & Icon Setup Script   " -ForegroundColor Magenta
    Write-Host "==========================================" -ForegroundColor Magenta

    # 1. Verify package.json exists
    if (-not (Test-Path "package.json")) {
        Write-Err "package.json not found in $(Get-Location)"
        Write-Host "Please run this script from the root of your Next.js project." -ForegroundColor Yellow
        exit 1
    }

    # 2. Check Node.js / Package Manager availability
    Ensure-NodePath

    $pkgManager = $null
    $addCmd = "install"

    if (Get-Command "pnpm" -ErrorAction SilentlyContinue) {
        if (Test-Path "pnpm-lock.yaml") { $pkgManager = "pnpm"; $addCmd = "add" }
    }
    if (-not $pkgManager -and (Get-Command "yarn" -ErrorAction SilentlyContinue)) {
        if (Test-Path "yarn.lock") { $pkgManager = "yarn"; $addCmd = "add" }
    }
    if (-not $pkgManager -and (Get-Command "bun" -ErrorAction SilentlyContinue)) {
        if ((Test-Path "bun.lockb") -or (Test-Path "bun.lock")) { $pkgManager = "bun"; $addCmd = "add" }
    }
    if (-not $pkgManager -and (Get-Command "npm" -ErrorAction SilentlyContinue)) {
        $pkgManager = "npm"
        $addCmd = "install"
    }

    # If npm is still not found, check if user needs to install Node.js
    if (-not $pkgManager) {
        Write-Err "Node.js / npm is not installed or not found on your system."
        Write-Host "`nTo resolve this:" -ForegroundColor Yellow
        Write-Host "1. Download and install Node.js (LTS) from: https://nodejs.org/" -ForegroundColor White
        Write-Host "   OR run in terminal: winget install OpenJS.NodeJS.LTS" -ForegroundColor Cyan
        Write-Host "2. Reopen your PowerShell terminal and run this script again.`n" -ForegroundColor White
        exit 1
    }

    Write-Step "Detecting package manager..."
    Write-Success "Using package manager: $pkgManager"

    # 3. Ensure base project dependencies are installed if node_modules is missing
    if (-not (Test-Path "node_modules")) {
        Write-Step "node_modules missing. Installing base project dependencies..."
        & $pkgManager install
        if ($LASTEXITCODE -ne 0) {
            Write-Warn "Base install returned a non-zero exit code. Continuing with motion packages..."
        } else {
            Write-Success "Base dependencies installed."
        }
    }

    # 4. Packages to install
    $packages = @(
        "framer-motion",
        "lucide-react",
        "clsx",
        "tailwind-merge"
    )

    Write-Step "Installing motion & icon dependencies: $($packages -join ', ')..."

    $argsList = @($addCmd) + $packages
    if ($pkgManager -eq "npm" -and $Force) {
        $argsList += "--legacy-peer-deps"
    }

    Write-Host "Executing: $pkgManager $($argsList -join ' ')" -ForegroundColor DarkGray
    & $pkgManager $argsList

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to install dependencies with $pkgManager."
    }

    Write-Success "Dependencies successfully installed!"

    # 5. Check / Setup cn helper for Tailwind CSS
    $libUtilsPath = "src/lib/utils.ts"
    $libUtilsAlt = "lib/utils.ts"

    if (-not (Test-Path $libUtilsPath) -and -not (Test-Path $libUtilsAlt)) {
        Write-Step "Setting up clsx + tailwind-merge helper (cn utility)..."
        $targetDir = if (Test-Path "src") { "src/lib" } else { "lib" }
        $targetFile = Join-Path $targetDir "utils.ts"

        if (-not (Test-Path $targetDir)) {
            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        }

        $cnCode = @"
import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
"@
        Set-Content -Path $targetFile -Value $cnCode -Encoding UTF8
        Write-Success "Created $targetFile with 'cn()' helper."
    }

    Write-Host "`nAll set! You can now run 'npm run dev' to start the project." -ForegroundColor Green
} catch {
    Write-Err "An error occurred during installation: $_"
    exit 1
}
