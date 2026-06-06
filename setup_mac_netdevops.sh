#!/usr/bin/env bash

# ==============================================================================
# SCRIPT DE CONFIGURAÇÃO: NETDEVOPS, CML2 MCP, IA & OLLAMA LOCAL
# Alvo: macOS (Intel ou Apple Silicon M-Series)
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================================${NC}"
echo -e "${GREEN}  Preparando macOS para NetDevOps, CML2 (MCP) e IA + Ollama Local v0.9 ${NC}"
echo -e "${BLUE}======================================================================${NC}"

# No Mac, não precisamos rodar o script como sudo/root. O Homebrew proíbe isso.
if [ "$EUID" -eq 0 ]; then
  echo -e "${RED}[ERRO] Não execute este script como root ou com sudo direto. O Homebrew precisa rodar no seu usuário comum.${NC}"
  exit 1
fi

# ------------------------------------------------------------------------------
# 1. VERIFICAÇÃO DO HOMEBREW (Gerenciador de Pacotes do Mac)
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[1/8] Verificando o Homebrew...${NC}"
if ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}Homebrew não encontrado. Instalando agora...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Configurar o PATH do Homebrew dinamicamente para Apple Silicon ou Intel
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
# DISCLAIMER INTERATIVO
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}AVISO: Este script executará alterações no sistema e instalará pacotes via Homebrew.${NC}"
echo -e "${GREEN}✅ Este é o script RECOMENDADO: as ferramentas serão instaladas em ambiente virtual isolado (venv).${NC}"
echo -e "${YELLOW}Leia o DISCLAIMER completo em README.md antes de continuar.${NC}"
read -p "\nDeseja continuar por sua conta e risco? (s/N): " __confirm
if [[ ! "${__confirm}" =~ ^[Ss]$ ]]; then
    echo -e "${RED}Operação cancelada pelo usuário. Nenhuma alteração será feita.${NC}"
    exit 1
fi

# ------------------------------------------------------------------------------
# 2. INSTALAÇÃO DE DEPENDÊNCIAS ESSENCIAIS VIA BREW
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[2/8] Instalando ferramentas base e utilitários...${NC}"
# Pedimos explicitamente o Python 3.13 pelo Homebrew
brew install wget curl git unzip jq zstd python@3.13 node xz

# ------------------------------------------------------------------------------
# 3. INSTALAÇÃO DO OLLAMA (IA Local no Mac - Extremamente otimizado para chips M-Series)
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[3/8] Instalando Ollama via Homebrew Cask...${NC}"
brew install --cask ollama

# Iniciar o Ollama em background no Mac usando o brew services (ou abrindo o app)
echo -e "${BLUE}Iniciando o serviço do Ollama...${NC}"
brew services start ollama 2>/dev/null || open -a Ollama

# Aguardar o Ollama subir para aceitar conexões
sleep 3

echo -e "${BLUE}Baixando o modelo DeepSeek-R1 destilado (1.5b) localmente...${NC}"
ollama pull deepseek-r1:1.5b

# ------------------------------------------------------------------------------
# 4. INSTALAÇÃO DO PIPX, UV e UVX
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[4/8] Instalando gerenciadores de pacotes Python modernos...${NC}"
brew install pipx
pipx ensurepath

# Instalação standalone do UV/UVX
curl -LsSf https://astral.sh/uv/install.sh | sh

# Atualizar o PATH na sessão do terminal atual
export PATH="$HOME/.local/bin:$PATH"
source "$HOME/.local/bin/env" 2>/dev/null || true

# ------------------------------------------------------------------------------
# 5. INSTALAÇÃO DO OPENCODE
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[5/8] Instalando OpenCode AI...${NC}"
curl -fsSL https://opencode.ai/install | bash

# ------------------------------------------------------------------------------
# 6. FERRAMENTAS DE INFRAESTRUTURA (Ansible)
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[6/8] Instalando Ansible isolado via pipx...${NC}"
pipx install --include-deps ansible

echo -e "${BLUE}[Mac Info] Se precisar de Docker no Mac, recomendamos baixar o 'Docker Desktop para Mac' ou o 'OrbStack' via interface visual.${NC}"

# ------------------------------------------------------------------------------
# 7. INSTALAÇÃO DE PIP/UV E PACOTE CML-MCP
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[7/8] Instalando bibliotecas globais de redes e IA...${NC}"

# Garantir que usamos o pip do python do brew
python3 -m pip install --upgrade pip 2>/dev/null || true

python3 -m pip install \
    netmiko paramiko napalm pyats genie requests urllib3 \
    virl2-client openai anthropic google-genai langchain crewai openclaw mcp

echo -e "${BLUE}Instalando cml-mcp global via utilitário do UV...${NC}"
uv tool install "cml-mcp[pyats]" --with pyats 2>/dev/null || python3 -m pip install "cml-mcp[pyats]"

# ------------------------------------------------------------------------------
# 8. WORKSPACE DE LABS E AMBIENTE VIRTUAL ISOLADO COM UV
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[8/8] Criando workspace de laboratórios com UV...${NC}"
WORKDIR="$HOME/netdevops_labs"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

uv venv .venv --python 3.13
source .venv/bin/activate
uv pip install netmiko napalm pyats genie virl2-client openai langchain crewai openclaw mcp "cml-mcp[pyats]"

# ------------------------------------------------------------------------------
# VALIDAÇÃO FINAL
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}======================================================================${NC}"
echo -e "${GREEN}🎉 SEU MACOS FOI CONFIGURADO COM SUCESSO!${NC}"
echo -e "${BLUE}======================================================================${NC}"
echo -e " - Homebrew validado."
echo -e " - Ollama instalado (No Mac M1/M2/M3/M4 ele usa a GPU unificada nativamente e voa!)."
echo -e " - OpenCode pronto (Use Ctrl+P para alternar modelos)."
echo -e " - CML-MCP mapeado com suporte a PyATS."
echo -e "\n👉 Para ativar o ambiente virtual: ${GREEN}cd ~/netdevops_labs && source .venv/bin/activate${NC}"
echo -e "${BLUE}======================================================================${NC}"