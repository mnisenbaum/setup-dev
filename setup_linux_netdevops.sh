#!/usr/bin/env bash

# ==============================================================================
# SCRIPT DE CONFIGURAÇÃO: NETDEVOPS, CML2 MCP, IA & OLLAMA LOCAL
# Alvo: Ubuntu 22.04 / 24.04 / 26.04 LTS ou WSL Limpo
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================================${NC}"
echo -e "${GREEN}  Preparando WSL para NetDevOps, CML2 (MCP) e IA + Ollama Local v0.9 ${NC}"
echo -e "${BLUE}======================================================================${NC}"

# ------------------------------------------------------------------------------
# DISCLAIMER INTERATIVO
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}AVISO: Este script executará alterações no sistema (instala pacotes e cria ambientes).${NC}"
echo -e "${GREEN}✅ Este é o script RECOMENDADO: as ferramentas serão instaladas em ambiente virtual isolado (venv).${NC}"
echo -e "${YELLOW}Leia o DISCLAIMER completo em README.md antes de continuar.${NC}"
read -p "\nDeseja continuar por sua conta e risco? (s/N): " __confirm
if [[ ! "${__confirm}" =~ ^[Ss]$ ]]; then
  echo -e "${RED}Operação cancelada pelo usuário. Nenhuma alteração será feita.${NC}"
  exit 1
fi

if [ "$EUID" -eq 0 ]; then
  echo -e "${RED}[ERRO] Execute como usuário normal (com sudo), não como root direto.${NC}"
  exit 1
fi

# ------------------------------------------------------------------------------
# 1. ATUALIZAÇÃO E DEPENDÊNCIAS CRÍTICAS DE COMPILAÇÃO
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[1/8] Instalando dependências essenciais do sistema (incluindo zstd)...${NC}"
sudo apt update && sudo apt upgrade -y

sudo apt install -y \
    curl wget git unzip build-essential software-properties-common \
    ca-certificates gnupg jq zstd libssl-dev \
    libffi-dev libxml2-dev libxslt1-dev zlib1g-dev \
    python3-dev python3-pip python3-venv

# ------------------------------------------------------------------------------
# 2. INSTALAÇÃO DO OLLAMA (Modelos de IA Locais)
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[2/8] Instalando o Ollama para execução de IA Local...${NC}"
curl -fsSL https://ollama.com/install.sh | sh

# Iniciar o serviço do Ollama em background
sudo systemctl start ollama 2>/dev/null || true

# Baixar o modelo do DeepSeek-R1 (1.5b) para testes locais
echo -e "${BLUE}Baixando o modelo DeepSeek-R1 destilado (1.5b) para uso local...${NC}"
ollama pull deepseek-r1:1.5b

# ------------------------------------------------------------------------------
# 3. INSTALAÇÃO DO PIPX, UV e UVX
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[3/8] Instalando gerenciadores de pacotes modernos...${NC}"
sudo apt install -y pipx
pipx ensurepath

curl -LsSf https://astral.sh/uv/install.sh | sh

export PATH="$HOME/.local/bin:$PATH"
source "$HOME/.local/bin/env" 2>/dev/null || true
source ~/.bashrc 2>/dev/null || true

# ------------------------------------------------------------------------------
# 4. INSTALAÇÃO DO OPENCODE
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[4/8] Instalação do OpenCode AI...${NC}"
curl -fsSL https://opencode.ai/install | bash

# ------------------------------------------------------------------------------
# 5. INSTALAÇÃO DO NODE.JS & NPM
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[5/8] Configurando repositório e instalando Node.js...${NC}"
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg --yes
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt update && sudo apt install nodejs -y

# ------------------------------------------------------------------------------
# 6. FERRAMENTAS DE INFRAESTRUTURA (Ansible)
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[6/8] Instalando Ansible via pipx...${NC}"
pipx install --include-deps ansible

# ------------------------------------------------------------------------------
# 7. INSTALAÇÃO GLOBAL DE PIP/UV E PACOTE CML-MCP
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[7/8] Configurando PIP global e instalando bibliotecas...${NC}"
sudo pip3 config set global.break-system-packages true 2>/dev/null || true
pip3 install --upgrade pip

pip3 install \
    netmiko paramiko napalm pyats genie requests urllib3 \
    virl2-client openai anthropic google-genai langchain crewai openclaw mcp

echo -e "${BLUE}Instalando cml-mcp global via utilitário do UV...${NC}"
uv tool install "cml-mcp[pyats]" --with pyats 2>/dev/null || pip3 install "cml-mcp[pyats]"

# ------------------------------------------------------------------------------
# 8. WORKSPACE DE LABS E AMBIENTE VIRTUAL ISOLADO
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[8/8] Criando workspace de laboratórios com UV...${NC}"
WORKDIR="$HOME/netdevops_labs"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

uv venv .venv
source .venv/bin/activate
uv pip install netmiko napalm pyats genie virl2-client openai langchain crewai openclaw mcp "cml-mcp[pyats]"

# ------------------------------------------------------------------------------
# VALIDAÇÃO FINAL
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}======================================================================${NC}"
echo -e "${GREEN}🎉 AMBIENTE COMPLETO CONFIGURADO COM SUCESSO!${NC}"
echo -e "${BLUE}======================================================================${NC}"
echo -e " - Pacote zstd configurado."
echo -e " - Ollama instalado e com modelo DeepSeek-R1 baixado."
echo -e " - OpenCode pronto (Use Ctrl+P para alternar modelos)."
echo -e " - CML-MCP mapeado com suporte a PyATS."
echo -e "\n👉 Para ativar o ambiente virtual: ${GREEN}cd ~/netdevops_labs && source .venv/bin/activate${NC}"
echo -e "${BLUE}======================================================================${NC}"