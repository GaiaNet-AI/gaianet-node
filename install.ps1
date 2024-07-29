# PowerShell script

# Exit on error
$ErrorActionPreference = "Stop"

# Target name
$target = (Get-CimInstance Win32_ComputerSystem).SystemType

# Represents the directory where the script is located
$cwd = Get-Location

$repo_branch = "main"
$version = "0.2.4"
$rag_api_server_version = "0.7.5"
$llama_api_server_version = "0.12.5"
$ggml_bn = "b3445"
$vector_version = "0.38.0"
$dashboard_version = "v3.1"

# false: do not reinstall, true: reinstall
$reinstall = $false
# false: do not upgrade, true: upgrade
$upgrade = $false
# URL to the config file
$config_url = ""
# Path to the gaianet base directory
$gaianet_base_dir = "$HOME\gaianet"
# Qdrant binary
$qdrant_version = "v1.10.1"
# Tmp directory
$tmp_dir = "$gaianet_base_dir\tmp"
# Specific CUDA enabled GGML plugin
$ggmlcuda = ""
# false: disable vector, true: enable vector
$enable_vector = $false

# Print in red color
$RED = "Red"
# Print in green color
$GREEN = "Green"
# Print in yellow color
$YELLOW = "Yellow"
# No Color
$NC = "Default"

function Info {
    param (
        [string]$message
    )
    $green = "`e[32m"
    $reset = "`e[0m"
    Write-Output "${green}${message}${reset}"
}

function Warning {
    param (
        [string]$message
    )
    $yellow = "`e[33m"
    $reset = "`e[0m"
    Write-Output "${yellow}${message}${reset}"
}

function Error {
    param (
        [string]$message
    )
    $red = "`e[31m"
    $reset = "`e[0m"
    Write-Output "${red}${message}${reset}"
}

function Print-Usage {
    Write-Host "Usage:"
    Write-Host "  ./install.ps1 [Options]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  --config <Url>     Specify a url to the config file"
    Write-Host "  --base <Path>      Specify a path to the gaianet base directory"
    Write-Host "  --reinstall        Install and download all required deps"
    Write-Host "  --upgrade          Upgrade the gaianet node"
    Write-Host "  --tmpdir <Path>    Specify a path to the temporary directory [default: $gaianet_base_dir/tmp]"
    Write-Host "  --ggmlcuda [11/12] Install a specific CUDA enabled GGML plugin version [Possible values: 11, 12]."
    Write-Host "  --enable-vector:   Install vector log aggregator"
    Write-Host "  --version          Print version"
    Write-Host "  --help             Print usage"
}

while ($args.Count -gt 0) {
    $key = $args[0]
    switch ($key) {
        '--config' {
            $config_url = $args[1]
            $args = $args[2..$args.Length]
        }
        '--base' {
            $gaianet_base_dir = $args[1]
            $args = $args[2..$args.Length]
        }
        '--reinstall' {
            $reinstall = 1
            $args = $args[1..$args.Length]
        }
        '--upgrade' {
            $upgrade = 1
            $args = $args[1..$args.Length]
        }
        '--tmpdir' {
            $tmp_dir = $args[1]
            $args = $args[2..$args.Length]
        }
        '--ggmlcuda' {
            $ggmlcuda = $args[1]
            $args = $args[2..$args.Length]
        }
        '--enable-vector' {
            $enable_vector = 1
            $args = $args[1..$args.Length]
        }
        '--version' {
            Write-Host "Gaianet-node Installer v$version"
            exit 0
        }
        '--help' {
            print_usage
            exit 0
        }
        default {
            Write-Host "Unknown argument: $key"
            print_usage
            exit 1
        }
    }
}


function Download-File {
    param (
        [string]$url,
        [string]$output
    )

    $retryCount = 3
    $progressPreference = "SilentlyContinue"

    for ($i = 1; $i -le $retryCount; $i++) {
        try {
            Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing
            Write-Output "Download successful"
            return
        } catch {
            if ($i -eq $retryCount) {
                Write-Error "    * Failed to download $url"
                exit 1
            }
        }
    }
}

function Check-CurlSilent {
    param (
        [string]$url,
        [string]$output
    )

    $retryCount = 3

    for ($i = 1; $i -le $retryCount; $i++) {
        try {
            Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing -ErrorAction Stop > $null
            Write-Output "Download successful"
            return
        } catch {
            if ($i -eq $retryCount) {
                Write-Error "    * Failed to download $url"
                exit 1
            }
        }
    }
}

# Write-Host ""
# Write-Host @"
#  ██████╗  █████╗ ██╗ █████╗ ███╗   ██╗███████╗████████╗
# ██╔════╝ ██╔══██╗██║██╔══██╗████╗  ██║██╔════╝╚══██╔══╝
# ██║  ███╗███████║██║███████║██╔██╗ ██║█████╗     ██║
# ██║   ██║██╔══██║██║██╔══██║██║╚██╗██║██╔══╝     ██║
# ╚██████╔╝██║  ██║██║██║  ██║██║ ╚████║███████╗   ██║
#  ╚═════╝ ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝
# "@
# Write-Host ""
# Write-Host ""

# if (Test-Path -Path $gaianet_base_dir -PathType Container) {
#     Write-Host "Gaianet node is already installed in $gaianet_base_dir"
#     if ($upgrade) {
#         Write-Host "Upgrading Gaianet node..."
#     } elseif ($reinstall) {
#         Write-Host "Use --upgrade to upgrade the Gaianet node"
#         exit 0
#     }
# }

# Create base directory if it does not exist
if (-not (Test-Path -Path $gaianet_base_dir -PathType Container)) {
    New-Item -Path $gaianet_base_dir -ItemType Directory -Force
    icacls $gaianet_base_dir /grant 'Everyone:(OI)(CI)F'

    Write-Output "Directory created with permissions set to 777."
}
Set-Location -Path $gaianet_base_dir

# Create log directory if it does not exist
if (-not (Test-Path -Path "$gaianet_base_dir/log" -PathType Container)) {
    New-Item -Path "$gaianet_base_dir/log" -ItemType Directory -Force
    icacls "$gaianet_base_dir/log" /grant 'Everyone:(OI)(CI)F'

    Write-Output "Log directory created with permissions set to 777."
}
$log_dir = "$gaianet_base_dir/log"

# Create bin directory if it does not exist
if (-not (Test-Path -Path "$gaianet_base_dir/bin" -PathType Container)) {
    New-Item -Path "$gaianet_base_dir/bin" -ItemType Directory -Force
    icacls "$gaianet_base_dir/bin" /grant 'Everyone:(OI)(CI)F'

    Write-Output "Bin directory created with permissions set to 777."
}
$bin_dir = "$gaianet_base_dir/bin"

# 1. Install `gaianet` CLI tool.


# 2. Download default `config.json`
# 3. Download `nodeid.json`
if ($upgrade) {
    Write-Output "unimplemented"
} else {
    Write-Output "[+] Downloading default config.json ...\n"

    # Check if config.json exists
    if (-not (Test-Path -Path "$gaianet_base_dir/config.json" -PathType Leaf)) {
        $config_url = "https://github.com/GaiaNet-AI/gaianet-node/releases/download/$version/config.json"
        $config_output = "$gaianet_base_dir/config.json"

        Download-File -url $config_url -output $config_output

        Info "    * The default config file is downloaded in $gaianet_base_dir"
    } else {
        Warning "    * Use the cached config file in $gaianet_base_dir"
    }


    # 3. download nodeid.json
    if (-not (Test-Path -Path "$gaianet_base_dir/nodeid.json" -PathType Leaf)) {
        Write-Output "[+] Downloading nodeid.json ...\n"
        $nodeid_url = "https://github.com/GaiaNet-AI/gaianet-node/releases/download/$version/nodeid.json"
        $nodeid_output = "$gaianet_base_dir/nodeid.json"

        Download-File -url $nodeid_url -output $nodeid_output

        Info "    * The nodeid.json is downloaded in $gaianet_base_dir"
    }
}


