<#
.SYNOPSIS
    Script de Configuração NetDevOps para PowerShell (Windows Nativo)
    Alvo: Windows 10 / 11 (PowerShell 5.1 ou PowerShell 7+)
    Garante ferramentas locais de desenvolvimento, IA e produtividade no terminal.
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
Write-Host "  Configurando Ambiente Local Windows PowerShell para NetDevOps v0.9 " -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "`nAVISO: Este script fará alterações na máquina (instala pacotes e configura o ambiente)." -ForegroundColor Yellow
Write-Host "Leia o DISCLAIMER completo em README.md antes de continuar." -ForegroundColor Yellow
$ans = Read-Host "Deseja continuar por sua conta e risco? (s/N)"
if ($ans -ne 's' -and $ans -ne 'S') {
    Write-Host "Operação cancelada pelo usuário. Nenhuma alteração será feita." -ForegroundColor Red
    Exit
}

# ------------------------------------------------------------------------------
# 1. ATUALIZAÇÃO DO GERENCIADOR DE PACOTES (WINGET)
# ------------------------------------------------------------------------------
Write-Host "`n[1/6] Validando e atualizando o Windows Package Manager (Winget)..." -ForegroundColor Yellow
$WingetCheck = Get-Command winget -ErrorAction SilentlyContinue
if (-not $WingetCheck) {
    Write-Host "Winget não encontrado. Tentando instalar via AppX..." -ForegroundColor Red
    Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe -ErrorAction SilentlyContinue
}

# ------------------------------------------------------------------------------
# 2. INSTALAÇÃO DE DEPENDÊNCIAS, DEV TOOLS E PYTHON NATIVO
# ------------------------------------------------------------------------------
Write-Host "`n[2/6] Instalando ferramentas base de desenvolvimento (Python, Git, Node, etc)..." -ForegroundColor Yellow

# Lista de aplicativos essenciais via Winget (Oh My Posh removido com sucesso)
$Apps = @(
    "Python.Python.3.13",           # Python nativo estável para bibliotecas de redes (3.13)
    "Git.Git",                     # Git SCM / Git Bash
    "Nodejs.Nodejs.LTS",           # Node e NPM para ferramentas de ecossistema JS
    "Ollama.Ollama",               # Ollama nativo do Windows (Garante IA Local no host)
    "Microsoft.VisualStudioCode"   # VS Code
)

foreach ($App in $Apps) {
    Write-Host "Instalando/Atualizando: $App..." -ForegroundColor Cyan
    winget install --id $App --silent --accept-source-agreements --accept-package-agreements
}

# ------------------------------------------------------------------------------
# 3. CONFIGURAÇÃO DO PYTHON & PIP GLOBAL NO WINDOWS
# ------------------------------------------------------------------------------
Write-Host "`n[3/6] Atualizando PIP e configurando ambiente Python no Windows..." -ForegroundColor Yellow
# Recarrega a variável PATH da máquina para garantir que o Python recém-instalado seja visto
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Atualiza o PIP nativo
python -m pip install --upgrade pip --quiet

# Instalação das bibliotecas de rede essenciais nativas no Windows (Facilita scripts locais rápidos)
Write-Host "Instalando bibliotecas de Redes e IA de forma nativa..." -ForegroundColor Cyan
pip install netmiko paramiko requests urllib3 openai langchain crewai mcp --quiet

# ------------------------------------------------------------------------------
# 4. INSTALAÇÃO DE MÓDULOS DO POWERSHELL (PSReadLine & Terminal-Icons)
# ------------------------------------------------------------------------------
Write-Host "`n[4/6] Instalando módulos de produtividade e auto-complete para o PowerShell..." -ForegroundColor Yellow

# Forçar o uso do repositório PSGallery atualizado
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted

# Instala PSReadLine para Autocomplete preditivo (Estilo terminal ZSH/Fish)
Install-Module -Name PSReadLine -AllowClobber -Force -Scope AllUsers -ErrorAction SilentlyContinue

# Instala Terminal-Icons para mostrar ícones coloridos ao dar 'ls' ou 'dir'
Install-Module -Name Terminal-Icons -Force -Scope AllUsers -ErrorAction SilentlyContinue

# ------------------------------------------------------------------------------
# 5. INSTALAÇÃO E DOWNLOAD DO MODELO DE IA LOCAL (CORRIGIDO)
# ------------------------------------------------------------------------------
Write-Host "`n[5/6] Baixando modelo de IA local no host Windows..." -ForegroundColor Yellow

# Recarrega as variáveis de ambiente para garantir o acesso ao executável do Ollama
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

Write-Host "Iniciando o download do DeepSeek-R1 (1.5b) via Ollama..." -ForegroundColor Cyan
Write-Host "Isso pode levar alguns minutos dependendo da sua conexão. Aguarde..." -ForegroundColor Gray

# Correção: Alterado de 'run' para 'pull'. O 'pull' baixa e valida o modelo de forma 
# não-interativa em background, eliminando o erro 'The parameter is incorrect' causado pelo chat.
Start-Process -FilePath "ollama" -ArgumentList "pull deepseek-r1:1.5b" -NoNewWindow -Wait -ErrorAction SilentlyContinue

Write-Host "✅ Modelo DeepSeek-R1 verificado e pronto para o ecossistema NetDevOps!" -ForegroundColor Green
# ------------------------------------------------------------------------------
# 6. CRIAÇÃO, BACKUP E CUSTOMIZAÇÃO DO PERFIL DO POWERSHELL ($PROFILE)
# ------------------------------------------------------------------------------
Write-Host "`n[6/6] Gerando e injetando configurações no perfil do usuário ($PROFILE)..." -ForegroundColor Yellow

# Bloco de configuração limpo (Sem nenhuma referência ao Oh My Posh)
$NetDevOpsSettings = @"

# ==============================================================================
# BLOCO NETDEVOPS - AGENTE AUTOMAÇÃO & IA (INJETADO AUTOMATICAMENTE)
# ==============================================================================
Import-Module PSReadLine
Import-Module Terminal-Icons

# Configurações de Auto-Complete Inteligente (PSReadLine)
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle InlineView
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# Aliases Úteis Estilo Linux/DevOps
Set-Alias -Name ll -Value Get-ChildItem -ErrorAction SilentlyContinue
Set-Alias -Name grep -Value Select-String

function k9s_wsl { wsl k9s }
function docker_wsl { wsl docker }

Write-Host "🚀 Ambiente Windows DevNet Carregado com Sucesso!" -ForegroundColor Green
Write-Host "🤖 IA Pronta: Ollama local operando no background." -ForegroundColor Blue
# ==============================================================================
"@

# Se o arquivo de perfil já existe, criamos um backup e usamos a técnica de Append Seguro
if (Test-Path -Path $PROFILE) {
    $Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $BackupPath = "$PROFILE.bak_$Timestamp"
    Copy-Item -Path $PROFILE -Destination $BackupPath -Force
    Write-Host "💾 Backup do perfil existente criado em: $BackupPath" -ForegroundColor Cyan

    $ProfileContent = Get-Content -Path $PROFILE -Raw
    if ($ProfileContent -match "BLOCO NETDEVOPS") {
        Write-Host "ℹ️ As configurações de NetDevOps já constam no seu perfil. Pulando anexo." -ForegroundColor Cyan
    } else {
        Add-Content -Path $PROFILE -Value "`n$NetDevOpsSettings"
        Write-Host "➕ Configurações de NetDevOps anexadas ao perfil existente com sucesso!" -ForegroundColor Green
    }
} 
# Se o perfil não existia, cria do zero
else {
    $ProfileDirectory = Split-Path -Path $PROFILE
    if (!(Test-Path -Path $ProfileDirectory)) {
        New-Item -ItemType Directory -Path $ProfileDirectory -Force | Out-Null
    }
    Set-Content -Path $PROFILE -Value $NetDevOpsSettings
    Write-Host "✨ Novo perfil criado do zero com sucesso!" -ForegroundColor Green
}

# ------------------------------------------------------------------------------
# VALIDAÇÃO FINAL E INSTRUÇÕES AO USUÁRIO
# ------------------------------------------------------------------------------
Write-Host "`n======================================================================" -ForegroundColor Cyan
Write-Host "🎉 POWERSHELL DA MÁQUINA HOSPEDEIRA CONFIGURADO COM SUCESSO!" -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "Para concluir a experiência e visualizar os ícones corretamente:"
Write-Host "1. Abra uma nova janela ou aba do PowerShell."
Write-Host "2. O terminal manterá o prompt original padrão do Windows, porém com superpoderes."
Write-Host "`nSua máquina host Windows agora está totalmente sincronizada com o poder do WSL!"
Write-Host "======================================================================" -ForegroundColor Cyan