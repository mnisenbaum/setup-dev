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

# Lista limpa: Oh My Posh e fontes removidos do fluxo de desinstalação
$AppsToRemove = @(
    "Ollama.Ollama"
    # Nota: Python, Git, VS Code e Node.js foram omitidos para evitar quebrar outros projetos do usuário.
    # Caso queira remover tudo instalado pelo script anterior, descomente as linhas abaixo:
    # "Python.Python.3.13",
    # "Git.Git",
    # "Nodejs.Nodejs.LTS",
    # "Microsoft.VisualStudioCode"
)

foreach ($App in $AppsToRemove) {
    Write-Host "Removendo: $App..." -ForegroundColor Cyan
    winget uninstall --id $App --silent --accept-source-agreements 2>$null
}

# ------------------------------------------------------------------------------
# 2. REMOÇÃO DOS MÓDULOS DO POWERSHELL
# ------------------------------------------------------------------------------
Write-Host "`n[2/4] Removendo módulos do PowerShell (Terminal-Icons)..." -ForegroundColor Yellow

# Remove o módulo de ícones do terminal instalado pelo setup
Uninstall-Module -Name Terminal-Icons -Force -ErrorAction SilentlyContinue

# Nota: PSReadLine é um módulo nativo do PowerShell moderno, mantemos ele intacto 
# e apenas removemos suas customizações através da limpeza do perfil abaixo.

# ------------------------------------------------------------------------------
# 3. RESTAURAÇÃO / LIMPEZA DO PERFIL ($PROFILE)
# ------------------------------------------------------------------------------
Write-Host "`n[3/4] Removendo customizações do arquivo de Perfil..." -ForegroundColor Yellow

if (Test-Path -Path $PROFILE) {
    $ProfileContent = Get-Content -Path $PROFILE -Raw

    # Se o perfil foi gerado de forma combinada (Append), removemos apenas o bloco NetDevOps
    if ($ProfileContent -match "# ==============================================================================\s*# BLOCO NETDEVOPS") {
        Write-Host "Encontrado bloco específico de NetDevOps. Removendo do seu perfil..." -ForegroundColor Cyan
        # Expressão regular para capturar e remover exatamente o bloco injetado pelo setup
        $CleanedContent = $ProfileContent -replace "(?s)# ==============================================================================\s*# BLOCO NETDEVOPS.*?# ==============================================================================", ""
        
        # Se o arquivo resultante estiver vazio ou apenas com linhas em branco, deletamos o arquivo
        if ([string]::IsNullOrWhiteSpace($CleanedContent)) {
            Remove-Item -Path $PROFILE -Force
            Write-Host "Arquivo de perfil limpo e removido por estar vazio." -ForegroundColor Cyan
        } else {
            Set-Content -Path $PROFILE -Value $CleanedContent.Trim()
            Write-Host "Configurações de NetDevOps removidas. Suas outras configurações pessoais foram preservadas!" -ForegroundColor Green
        }
    } 
    # Se o perfil continha apenas as nossas configurações ou era a versão antiga estruturada do zero, remove por completo
    else {
        Remove-Item -Path $PROFILE -Force
        Write-Host "Arquivo de perfil padrão do laboratório ($PROFILE) deletado com sucesso." -ForegroundColor Cyan
    }
} else {
    Write-Host "Nenhum arquivo de perfil encontrado para remover." -ForegroundColor Cyan
}

# ------------------------------------------------------------------------------
# 4. LIMPEZA DE VARIÁVEIS DE AMBIENTE DA SESSÃO ATUAL
# ------------------------------------------------------------------------------
Write-Host "`n[4/4] Atualizando variáveis de ambiente do terminal..." -ForegroundColor Yellow
# Força o PATH a voltar ao que está salvo de forma persistente no sistema
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# ------------------------------------------------------------------------------
# VALIDAÇÃO FINAL
# ------------------------------------------------------------------------------
Write-Host "`n======================================================================" -ForegroundColor Red
Write-Host "🎉 AMBIENTE REMOVIDO! POWERSHELL RESTAURADO AO PADRÃO." -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Red
Write-Host "O Ollama, o Terminal-Icons e as customizações de autocomplete/aliases foram removidos."
Write-Host "Abra uma nova janela do PowerShell e ele voltará ao comportamento original."
Write-Host "======================================================================" -ForegroundColor Red