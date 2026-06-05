<#
.SYNOPSIS
    Script de Rollback: Desfaz as configurações do ambiente NetDevOps no Windows.
    Remove os programas instalados via Winget e limpa o perfil do PowerShell.
#>

# ------------------------------------------------------------------------------
# CONFIGURAÇÕES INICIAIS E SEGURANÇA
# ------------------------------------------------------------------------------
$AdminCheck = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $AdminCheck) {
    Write-Error "Por favor, execute este script como ADMINISTRADOR."
    Exit
}

Set-ExecutionPolicy Bypass -Scope Process -Force

Write-Host "======================================================================" -ForegroundColor Red
Write-Host "     Removendo Ambiente Local Windows PowerShell (Rollback)          " -ForegroundColor Yellow
Write-Host "======================================================================" -ForegroundColor Red

# ------------------------------------------------------------------------------
# 1. REMOÇÃO DOS PROGRAMAS INSTALADOS VIA WINGET
# ------------------------------------------------------------------------------
Write-Host "`n[1/4] Desinstalando ferramentas de desenvolvimento..." -ForegroundColor Yellow

$AppsToRemove = @(
    "JanDeDobbeleer.OhMyPosh",
    "JanDeDobbeleer.OhMyPosh.Fonts.CaskaydiaCove",
    "Ollama.Ollama"
    # Nota: Python, Git, VS Code e Node.js foram omitidos para evitar quebrar outros projetos.
    # Caso queira remover o Python instalado pelo script anterior, descomente as linhas abaixo:
    # "Python.Python.3.11",
    # "Git.Git",
    # "Nodejs.Nodejs.LTS"
)

foreach ($App in $AppsToRemove) {
    Write-Host "Removendo: $App..." -ForegroundColor Cyan
    winget uninstall --id $App --silent --accept-source-agreements 2>$null
}

# ------------------------------------------------------------------------------
# 2. REMOÇÃO DOS MÓDULOS DO POWERSHELL
# ------------------------------------------------------------------------------
Write-Host "`n[2/4] Removendo módulos do PowerShell (Terminal-Icons e PSReadLine)..." -ForegroundColor Yellow

# PSReadLine não pode ser totalmente removido se estiver em uso, mas limpamos o escopo
Uninstall-Module -Name Terminal-Icons -Force -ErrorAction SilentlyContinue

# ------------------------------------------------------------------------------
# 3. RESTAURAÇÃO / LIMPEZA DO PERFIL ($PROFILE)
# ------------------------------------------------------------------------------
Write-Host "`n[3/4] Removendo customizações do arquivo de Perfil..." -ForegroundColor Yellow

if (Test-Path -Path $PROFILE) {
    # Remove o arquivo de perfil completamente para restaurar o comportamento padrão do PowerShell
    Remove-Item -Path $PROFILE -Force
    Write-Host "Arquivo de perfil ($PROFILE) deletado com sucesso." -ForegroundColor Cyan
} else {
    Write-Host "Nenhum arquivo de perfil encontrado para remover." -ForegroundColor Cyan
}

# ------------------------------------------------------------------------------
# 4. LIMPEZA DE VARIÁVEIS DE AMBIENTE DA SESSÃO ATUAL
# ------------------------------------------------------------------------------
Write-Host "`n[4/4] Atualizando variáveis de ambiente do terminal..." -ForegroundColor Yellow
# Força o PATH a voltar ao que está salvo no sistema, ignorando alterações temporárias da sessão
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# ------------------------------------------------------------------------------
# VALIDAÇÃO FINAL
# ------------------------------------------------------------------------------
Write-Host "`n======================================================================" -ForegroundColor Red
Write-Host "🎉 AMBIENTE REMOVIDO! POWERSHELL RESTAURADO AO PADRÃO." -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Red
Write-Host "O Oh My Posh, a Nerd Font, o Ollama e as customizações foram removidos."
Write-Host "Abra uma nova janela do PowerShell e ele voltará ao visual original de fábrica."
Write-Host "======================================================================" -ForegroundColor Red