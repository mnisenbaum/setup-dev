#!/usr/bin/env bash

# ==============================================================================
# SCRIPT DE CONFIGURAÇÃO GLOBAL: NETDEVOPS, CML2 MCP, IA & OLLAMA
# Alvo: macOS (Intel ou Apple Silicon M-Series) - Instalação 100% Global
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================================${NC}"
echo -e "${GREEN}  Configurando Ambiente Global NetDevOps, CML2 e IA no Mac (v0.9)     ${NC}"
echo -e "${BLUE}======================================================================${NC}"

# O Homebrew não permite e não deve ser executado como root/sudo
if [ "$EUID" -eq 0 ]; then
  echo -e "${RED}[ERRO] Não execute este script com sudo direto. O Homebrew precisa rodar no seu usuário comum.${NC}"
  exit 1
fi

# ------------------------------------------------------------------------------
# 1. VERIFICAÇÃO E INSTALAÇÃO DO HOMEBREW
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[1/7] Verificando o Homebrew...${NC}"
if ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}Homebrew não encontrado. Instalando agora...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Configura o PATH do Homebrew dinamicamente dependendo da arquitetura do Mac
    if [[ "$(uname -m)" == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    echo -e "${GREEN}✓ Homebrew já está instalado.${NC}"
    brew update
fi

# ------------------------------------------------------------------------------
# DISCLAIMER INTERATIVO (GLOBAL)
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}AVISO: Este script fará instalações GLOBAIS via Homebrew e pode afetar o sistema.${NC}"
echo -e "${YELLOW}⚠️  Este script é recomendado APENAS para máquinas virtuais de estudo/teste ou computadores sem nada instalado.${NC}"
echo -e "${RED}🚫 NUNCA execute este script em máquinas de produção ou máquinas pessoais de uso diário.${NC}"
echo -e "${CYAN}💡 Em máquinas pessoais, prefira: ./setup_mac_netdevops.sh (ambiente virtual isolado).${NC}"
echo -e "${YELLOW}Leia o DISCLAIMER completo em README.md antes de continuar.${NC}"
read -p "\nDeseja continuar por sua conta e risco? (s/N): " __confirm
if [[ ! "${__confirm}" =~ ^[Ss]$ ]]; then
    echo -e "${RED}Operação cancelada pelo usuário. Nenhuma alteração será feita.${NC}"
    exit 1
fi

# ------------------------------------------------------------------------------
# 2. INSTALAÇÃO DE DEPENDÊNCIAS DO SISTEMA VIA BREW
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[2/7] Instalando ferramentas base e utilitários...${NC}"
# Pedimos explicitamente o Python 3.13 via Homebrew
brew install wget curl git unzip jq zstd python@3.13 node xz

# ------------------------------------------------------------------------------
# 3. INSTALAÇÃO DO OLLAMA (IA Local otimizada para Mac)
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[3/7] Instalando Ollama...${NC}"
brew install --cask ollama

# Inicia o serviço do Ollama em background
echo -e "${BLUE}Iniciando o serviço do Ollama...${NC}"
brew services start ollama 2>/dev/null || open -a Ollama

# Pequena pausa para garantir que o serviço do Ollama inicializou completamente
sleep 3

echo -e "${BLUE}Baixando o modelo DeepSeek-R1 destilado (1.5b) localmente...${NC}"
ollama pull deepseek-r1:1.5b

# ------------------------------------------------------------------------------
# 4. INSTALAÇÃO DO PIPX, UV e UVX
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[4/7] Instalando gerenciadores de pacotes Python...${NC}"
brew install pipx
pipx ensurepath

# Instalação oficial do UV/UVX da Astral
curl -LsSf https://astral.sh/uv/install.sh | sh

# Atualiza as variáveis de ambiente para a sessão atual do script
export PATH="$HOME/.local/bin:$PATH"
source "$HOME/.local/bin/env" 2>/dev/null || true

# ------------------------------------------------------------------------------
# 5. INSTALAÇÃO DO OPENCODE
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[5/7] Instalação do OpenCode AI...${NC}"
curl -fsSL https://opencode.ai/install | bash

# ------------------------------------------------------------------------------
# 6. INSTALAÇÃO DO ANSIBLE GLOBAL
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[6/7] Instalando Ansible de forma isolada via pipx...${NC}"
pipx install --include-deps ansible

# ------------------------------------------------------------------------------
# 7. INSTALAÇÃO GLOBAL DE BIBLIOTECAS DE REDE, CML2 E IA
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[7/7] Instalando bibliotecas de Redes e IA no Python global do sistema...${NC}"

# Atualiza o pip do interpretador do Homebrew
python3 -m pip install --upgrade pip 2>/dev/null || true

# Instalação direta no ecossistema global do Mac
python3 -m pip install \
    netmiko \
    paramiko \
    napalm \
    pyats \
    genie \
    requests \
    urllib3 \
    virl2-client \
    openai \
    anthropic \
    google-genai \
    langchain \
    crewai \
    openclaw \
    mcp

# Instalação do ecossistema do CML Model Context Protocol via UV
echo -e "${BLUE}Instalando cml-mcp globalmente via UV...${NC}"
uv tool install "cml-mcp[pyats]" --with pyats 2>/dev/null || python3 -m pip install "cml-mcp[pyats]"

# ------------------------------------------------------------------------------
# VALIDAÇÃO FINAL
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}======================================================================${NC}"
echo -e "${GREEN}🎉 AMBIENTE GLOBAL DO MACOS CONFIGURADO COM SUCESSO!${NC}"
echo -e "${BLUE}======================================================================${NC}"
echo -e "Nenhum ambiente virtual foi criado. Você pode fechar este script e usar"
echo -e "qualquer uma das ferramentas de qualquer pasta do seu Mac:"
echo -e ""
echo -e " 🚀 Redes/Automação: Netmiko, NAPALM, pyATS, Ansible, virl2-client"
echo -e " 🤖 IA Aplicada:     Ollama (DeepSeek-R1), OpenCode, CML-MCP, LangChain"
echo -e " 📦 Utilitários:     Node.js, NPM, Pipx, UV / UVX"
echo -e "\n💡 Lembrete OpenCode: Use Ctrl+P dentro do prompt para escolher os modelos!"
echo -e "${BLUE}======================================================================${NC}"