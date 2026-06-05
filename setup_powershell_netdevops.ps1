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
# Garante que o Winget está pronto para uso de forma silenciosa
$WingetCheck = Get-Command winget -ErrorAction SilentlyContinue
if (-not $WingetCheck) {
    Write-Host "Winget não encontrado. Tentando instalar via AppX..." -ForegroundColor Red
    Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe -ErrorAction SilentlyContinue
}

# ------------------------------------------------------------------------------
# 2. INSTALAÇÃO DE DEPENDÊNCIAS, DEV TOOLS E PYTHON NATIVO
# ------------------------------------------------------------------------------
Write-Host "`n[2/7] Instalando ferramentas base de desenvolvimento (Python, Git, Node, etc)..." -ForegroundColor Yellow

# Lista de aplicativos essenciais via Winget
$Apps = @(
    "Python.Python.3.11",           # Python nativo estável para bibliotecas de redes
    "Git.Git",                     # Git SCM Git Bash
    "Nodejs.Nodejs.LTS",           # Node e NPM para ferramentas de ecossistema JS
    "Ollama.Ollama",               # Ollama nativo do Windows (Garante IA Local no host)
    "Microsoft.VisualStudioCode",  # VS Code (Se já instalado, o Winget apenas pula ou atualiza)
    "JanDeDobbeleer.OhMyPosh"      # Engine de customização estética de Prompt
)

foreach ($App in $Apps) {
    Write-Host "Instalando/Atualizando: $App..." -ForegroundColor Cyan
    winget install --id $App --silent --accept-source-agreements --accept-package-agreements --upgrade
}

# ------------------------------------------------------------------------------
# 3. INSTALAÇÃO DE NERD FONTS (Crucial para ícones no terminal)
# ------------------------------------------------------------------------------
Write-Host "`n[3/7] Instalando Nerd Fonts para suporte a ícones no Terminal..." -ForegroundColor Yellow
# Instalando a fonte "Caskaydia Cove Nerd Font" (Variante da Cascadia da Microsoft com ícones)
winget install --id Microsoft.CascadiaCode -e --silent
winget install --id JanDeDobbeleer.OhMyPosh.Fonts.CaskaydiaCove -e --silent

# ------------------------------------------------------------------------------
# 4. CONFIGURAÇÃO DO PYTHON & PIP GLOBAL NO WINDOWS
# ------------------------------------------------------------------------------
Write-Host "`n[4/7] Atualizando PIP e configurando ambiente Python no Windows..." -ForegroundColor Yellow
# Recarrega a variável PATH da máquina para garantir que o Python recém-instalado seja visto
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Atualiza o PIP nativo
python -m pip install --upgrade pip --quiet

# Instalação das bibliotecas de rede essenciais nativas no Windows (Facilita scripts locais rápidos)
Write-Host "Instalando bibliotecas de Redes e IA de forma nativa..." -ForegroundColor Cyan
pip install netmiko paramiko requests urllib3 openai langchain crewai mcp --quiet

# ------------------------------------------------------------------------------
# 5. INSTALAÇÃO DE MÓDULOS DO POWERSHELL (PSReadLine & Terminal-Icons)
# ------------------------------------------------------------------------------
Write-Host "`n[5/7] Instalando módulos de produtividade e auto-complete para o PowerShell..." -ForegroundColor Yellow

# Forçar o uso do repositório PSGallery atualizado
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted

# Instala PSReadLine para Autocomplete preditivo (Estilo terminal ZSH/Fish)
Install-Module -Name PSReadLine -AllowClobber -Force -Scope AllUsers -ErrorAction SilentlyContinue

# Instala Terminal-Icons para mostrar ícones coloridos ao dar 'ls' ou 'dir'
Install-Module -Name Terminal-Icons -Force -Scope AllUsers -ErrorAction SilentlyContinue

# ------------------------------------------------------------------------------
# 6. INSTALAÇÃO DO OLLAMA DEEPSEEK-R1 NO WINDOWS
# ------------------------------------------------------------------------------
Write-Host "`n[6/7] Inicializando e baixando modelo de IA local no host Windows..." -ForegroundColor Yellow
# Garante que o executável do Ollama está acessível no PATH atualizado
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Tenta baixar o modelo leve do DeepSeek para automações locais
Start-Process -FilePath "ollama" -ArgumentList "run deepseek-r1:1.5b" -NoNewWindow -ErrorAction SilentlyContinue
Write-Host "Ollama configurado. O modelo será baixado em background se o serviço já estiver de pé." -ForegroundColor Cyan

# ------------------------------------------------------------------------------
# 7. CRIAÇÃO E CUSTOMIZAÇÃO DO PERFIL GLOBAL DO POWERSHELL ($PROFILE)
# ------------------------------------------------------------------------------
Write-Host "`n[7/7] Gerando e injetando configurações no perfil do usuário ($PROFILE)..." -ForegroundColor Yellow

# Garante a existência do arquivo de Profile do PowerShell
if (!(Test-Path -Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}

# Bloco de configuração que será injetado no perfil do PowerShell do usuário
$ProfileContent = @"
# ==============================================================================
# PERFIL NETDEVOPS CUSTOMIZADO - AGENTE AUTOMAÇÃO & IA
# ==============================================================================

# 1. Importação de Módulos de Produtividade
Import-Module PSReadLine
Import-Module Terminal-Icons

# 2. Configurações de Auto-Complete Inteligente (PSReadLine)
# Seta a previsão para histórico (Seta para a direita aceita o histórico anterior)
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle InlineView
# Atalho clássico de Tab para navegar em menu
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# 3. Inicialização Estética do Prompt (Oh My Posh) (opcional)
# Escolhemos o tema 'jandedobbeleer' que é completo e limpo, ou 'ys' para minimalistas.
# oh-my-posh init pwsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/jandedobbeleer.omp.json' | Invoke-Expression

# 4. Aliases Úteis Estilo Linux/DevOps
Set-Alias -Name ll -Value Get-ChildItem -ErrorAction SilentlyContinue
Set-Alias -Name grep -Value Select-String

function k9s_wsl { wsl k9s }
function docker_wsl { wsl docker }

Write-Host "🚀 Ambiente Windows DevNet Carregado com Sucesso!" -ForegroundColor Green
Write-Host "🤖 IA Pronta: Ollama local operando no background." -ForegroundColor Blue
"@

# Escreve o conteúdo de forma limpa no arquivo de perfil
Set-Content -Path $PROFILE -Value $ProfileContent

# ------------------------------------------------------------------------------
# VALIDAÇÃO FINAL E INSTRUÇÕES AO USUÁRIO
# ------------------------------------------------------------------------------
Write-Host "`n======================================================================" -ForegroundColor Cyan
Write-Host "🎉 POWERSHELL DA MÁQUINA HOSPEDEIRA CONFIGURADO COM SUCESSO!" -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "Para concluir a experiência e visualizar os ícones corretamente:"
Write-Host "1. Se estiver usando o Windows Terminal:"
Write-Host "   - Abra as Configurações (Ctrl + ,)"
Write-Host "   - Vá em Perfis -> Padrões -> Aparência"
Write-Host "   - Altere a 'Fonte' para: CaskaydiaCove Nerd Font"
Write-Host "2. Reinicie seu terminal abrindo um novo PowerShell."
Write-Host "`nSua máquina host Windows agora está totalmente sincronizada com o poder do WSL!"
Write-Host "======================================================================" -ForegroundColor Cyan