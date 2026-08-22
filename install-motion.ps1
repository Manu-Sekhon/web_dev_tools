<#
.SYNOPSIS
    Automates full installation of Next.js dependencies, Framer Motion, and Lucide React icons.
.DESCRIPTION
    Detects the active package manager (pnpm, yarn, bun, or npm), installs all project dependencies,
    ensures framer-motion and lucide-react are installed, and configures the cn() helper utility.
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
    $addCmd = "install"

    if (Get-Command "pnpm" -ErrorAction SilentlyContinue) {
        if (Test-Path "pnpm-lock.yaml") { $pkgManager = "pnpm"; $addCmd = "add" }
    }
    if (Get-Command "yarn" -ErrorAction SilentlyContinue) {
        if (Test-Path "yarn.lock") { $pkgManager = "yarn"; $addCmd = "add" }
    }
    if (Get-Command "bun" -ErrorAction SilentlyContinue) {
        if ((Test-Path "bun.lockb") -or (Test-Path "bun.lock")) { $pkgManager = "bun"; $addCmd = "add" }
    }

    Write-Success "Using package manager: $pkgManager"

    # 3. Ensure base project dependencies are installed if node_modules is missing
    if (-not (Test-Path "node_modules")) {
        Write-Step "node_modules missing. Installing base project dependencies..."
        & $pkgManager install
        if ($LASTEXITCODE -ne 0) {
            Write-Warn "Base install returned a non-zero code. Proceeding with package installation..."
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

    Write-Host "`nAll set! You can now run 'npm run dev' and use Framer Motion & Lucide icons." -ForegroundColor Green
} catch {
    Write-Err "An error occurred during installation: $_"
    exit 1
}
