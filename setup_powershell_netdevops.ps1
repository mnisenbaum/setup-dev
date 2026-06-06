<#
.SYNOPSIS
    Script de Configuração NetDevOps para PowerShell (Windows Nativo)
    Alvo: Windows 10 / 11 (PowerShell 5.1 ou PowerShell 7+)
    Garante ferramentas locais de desenvolvimento, IA e embelezamento do terminal.
#>

# ------------------------------------------------------------------------------
# CONFIGURAÇÕES INICIAIS E SEGURANÇA
# ------------------------------------------------------------------------------
$AdminCheck = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $AdminCheck) {
    Write-Error "Por favor, execute este script como ADMINISTRADOR (Botão direito no PowerShell -> Executar como Administrador)."
    Exit
}

# Define a política de execução para permitir rodar o script e instalações na sessão atual
Set-ExecutionPolicy Bypass -Scope Process -Force
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "     Configurando Ambiente Local Windows PowerShell para NetDevOps   " -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Cyan

# ------------------------------------------------------------------------------
# 1. ATUALIZAÇÃO DO GERENCIADOR DE PACOTES (WINGET)
# ------------------------------------------------------------------------------
Write-Host "`n[1/7] Validando e atualizando o Windows Package Manager (Winget)..." -ForegroundColor Yellow
$WingetCheck = Get-Command winget -ErrorAction SilentlyContinue
if (-not $WingetCheck) {
    Write-Host "Winget não encontrado. Tentando instalar via AppX..." -ForegroundColor Red
    Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe -ErrorAction SilentlyContinue
}

# ------------------------------------------------------------------------------
# 2. INSTALAÇÃO DE DEPENDÊNCIAS, DEV TOOLS E PYTHON NATIVO (CORRIGIDO)
# ------------------------------------------------------------------------------
Write-Host "`n[2/7] Instalando ferramentas base de desenvolvimento (Python, Git, Node, etc)..." -ForegroundColor Yellow

$Apps = @(
    "Python.Python.3.11",           
    "Git.Git",                     
    "Nodejs.Nodejs.LTS",           
    "Ollama.Ollama",               
    "Microsoft.VisualStudioCode",  
    "JanDeDobbeleer.OhMyPosh"      
)

foreach ($App in $Apps) {
    Write-Host "Instalando/Atualizando: $App..." -ForegroundColor Cyan
    winget install --id $App --silent --accept-source-agreements --accept-package-agreements
}

# ------------------------------------------------------------------------------
# 4. CONFIGURAÇÃO DO PYTHON & PIP GLOBAL NO WINDOWS
# ------------------------------------------------------------------------------
Write-Host "`n[4/7] Atualizando PIP e configurando ambiente Python no Windows..." -ForegroundColor Yellow
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

python -m pip install --upgrade pip --quiet

Write-Host "Instalando bibliotecas de Redes e IA de forma nativa..." -ForegroundColor Cyan
pip install netmiko paramiko requests urllib3 openai langchain crewai mcp --quiet

# ------------------------------------------------------------------------------
# 5. INSTALAÇÃO DE MÓDULOS DO POWERSHELL (PSReadLine & Terminal-Icons)
# ------------------------------------------------------------------------------
Write-Host "`n[5/7] Instalando módulos de produtividade e auto-complete para o PowerShell..." -ForegroundColor Yellow

Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
Install-Module -Name PSReadLine -AllowClobber -Force -Scope AllUsers -ErrorAction SilentlyContinue
Install-Module -Name Terminal-Icons -Force -Scope AllUsers -ErrorAction SilentlyContinue

# ------------------------------------------------------------------------------
# 6. INSTALAÇÃO DO OLLAMA DEEPSEEK-R1 NO WINDOWS
# ------------------------------------------------------------------------------
Write-Host "`n[6/7] Inicializando e baixando modelo de IA local no host Windows..." -ForegroundColor Yellow
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

Start-Process -FilePath "ollama" -ArgumentList "run deepseek-r1:1.5b" -NoNewWindow -ErrorAction SilentlyContinue
Write-Host "Ollama configurado. O modelo será baixado em background." -ForegroundColor Cyan

# ------------------------------------------------------------------------------
# 7. CRIAÇÃO E CUSTOMIZAÇÃO DO PERFIL GLOBAL DO POWERSHELL ($PROFILE)
# ------------------------------------------------------------------------------
Write-Host "`n[7/7] Gerando e injetando configurações no perfil do usuário ($PROFILE)..." -ForegroundColor Yellow

if (!(Test-Path -Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}

$ProfileContent = @"
# ==============================================================================
# PERFIL NETDEVOPS CUSTOMIZADO - AGENTE AUTOMAÇÃO & IA
# ==============================================================================

Import-Module PSReadLine
Import-Module Terminal-Icons

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle InlineView
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

Set-Alias -Name ll -Value Get-ChildItem -ErrorAction SilentlyContinue
Set-Alias -Name grep -Value Select-String

function k9s_wsl { wsl k9s }
function docker_wsl { wsl docker }

Write-Host "🚀 Ambiente Windows DevNet Carregado com Sucesso!" -ForegroundColor Green
Write-Host "🤖 IA Pronta: Ollama local operando no background." -ForegroundColor Blue
"@

Set-Content -Path $PROFILE -Value $ProfileContent

# ------------------------------------------------------------------------------
# VALIDAÇÃO FINAL
# ------------------------------------------------------------------------------
Write-Host "`n======================================================================" -ForegroundColor Cyan
Write-Host "🎉 POWERSHELL DA MÁQUINA HOSPEDEIRA CONFIGURADO COM SUCESSO!" -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "Abra uma nova janela do PowerShell para aplicar as mudanças."