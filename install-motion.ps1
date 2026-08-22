<#
.SYNOPSIS
    Automates installation of Framer Motion and Lucide React icons in a Next.js project.
.DESCRIPTION
    Detects the current package manager (pnpm, yarn, bun, or npm), verifies package.json,
    and installs framer-motion and lucide-react along with standard UI utilities (clsx, tailwind-merge).
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

try {
    Write-Host "==========================================" -ForegroundColor Magenta
    Write-Host "  Next.js Animation & Icon Setup Script   " -ForegroundColor Magenta
    Write-Host "==========================================" -ForegroundColor Magenta

    # 1. Verify package.json exists
    if (-not (Test-Path "package.json")) {
        Write-Err "package.json not found in the current directory: $(Get-Location)"
        Write-Host "Please run this script from the root of your Next.js project." -ForegroundColor Yellow
        exit 1
    }

    # 2. Detect Package Manager
    Write-Step "Detecting package manager..."
    $pkgManager = "npm"
    $installCmd = "install"

    if (Test-Path "pnpm-lock.yaml") {
        $pkgManager = "pnpm"
        $installCmd = "add"
    } elseif (Test-Path "yarn.lock") {
        $pkgManager = "yarn"
        $installCmd = "add"
    } elseif ((Test-Path "bun.lockb") -or (Test-Path "bun.lock")) {
        $pkgManager = "bun"
        $installCmd = "add"
    } elseif (Test-Path "package-lock.json") {
        $pkgManager = "npm"
        $installCmd = "install"
    } else {
        Write-Warn "No lockfile detected. Defaulting to npm."
    }

    Write-Success "Using package manager: $pkgManager"

    # 3. Packages to install
    $packages = @(
        "framer-motion",
        "lucide-react",
        "clsx",
        "tailwind-merge"
    )

    Write-Step "Installing dependencies: $($packages -join ', ')..."

    $argsList = @($installCmd) + $packages
    if ($pkgManager -eq "npm" -and $Force) {
        $argsList += "--legacy-peer-deps"
    }

    Write-Host "Executing: $pkgManager $($argsList -join ' ')" -ForegroundColor DarkGray
    & $pkgManager $argsList

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to install dependencies with $pkgManager."
    }

    Write-Success "Dependencies successfully installed!"

    # 4. Check / Suggest cn helper for Tailwind CSS
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

    Write-Host "`nAll set! You can now import 'framer-motion' and 'lucide-react' in your Next.js components." -ForegroundColor Green
} catch {
    Write-Err "An error occurred during installation: $_"
    exit 1
}
