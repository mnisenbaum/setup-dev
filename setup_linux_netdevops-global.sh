#!/usr/bin/env bash

# ==============================================================================
# SCRIPT DE CONFIGURAÇÃO GLOBAL: NETDEVOPS, CML2 MCP, IA & OLLAMA
# Alvo: Ubuntu 22.04 / 24.04 / 26.04 LTS ou WSL (Instalação 100% Global)
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================================${NC}"
echo -e "${GREEN}  Configurando Ambiente Global NetDevOps, CML2 e IA (Sem Venv) v0.9  ${NC}"
echo -e "${BLUE}======================================================================${NC}"

# ------------------------------------------------------------------------------
# DISCLAIMER INTERATIVO (GLOBAL)
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}AVISO: Este script fará instalações GLOBAIS no sistema (pode afetar outros projetos).${NC}"
echo -e "${YELLOW}⚠️  Este script é recomendado APENAS para máquinas virtuais de estudo/teste ou computadores sem nada instalado.${NC}"
echo -e "${RED}🚫 NUNCA execute este script em máquinas de produção ou máquinas pessoais de uso diário.${NC}"
echo -e "${CYAN}💡 Em máquinas pessoais, prefira: ./setup_linux_netdevops.sh (ambiente virtual isolado).${NC}"
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
# 1. ATUALIZAÇÃO E DEPENDÊNCIAS CRÍTICAS DO SISTEMA
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[1/7] Instalando dependências essenciais do sistema...${NC}"
sudo apt update && sudo apt upgrade -y

sudo apt install -y \
    curl wget git unzip build-essential software-properties-common \
    ca-certificates gnupg jq zstd libssl-dev \
    libffi-dev libxml2-dev libxslt1-dev zlib1g-dev \
    python3-dev python3-pip python3-venv

# ------------------------------------------------------------------------------
# 2. LIBERAÇÃO DO PIP GLOBAL (Bypass de Segurança do Ubuntu)
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[2/7] Desbloqueando instalação de pacotes globais no Python do sistema...${NC}"
# Força o PIP a aceitar instalações globais sem reclamar de ambiente gerenciado externamente
sudo pip3 config set global.break-system-packages true 2>/dev/null || true
python3 -m pip install --upgrade pip --break-system-packages

# ------------------------------------------------------------------------------
# 3. INSTALAÇÃO DO OLLAMA (IA Local)
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[3/7] Instalando o Ollama para execução de IA Local...${NC}"
curl -fsSL https://ollama.com/install.sh | sh

# Iniciar o serviço do Ollama em background
sudo systemctl start ollama 2>/dev/null || true

# Baixar o modelo do DeepSeek-R1 (1.5b) para uso local imediato
echo -e "${BLUE}Baixando o modelo DeepSeek-R1 destilado (1.5b) localmente...${NC}"
ollama pull deepseek-r1:1.5b

# ------------------------------------------------------------------------------
# 4. INSTALAÇÃO DO PIPX, UV e UVX (Disponíveis Globalmente no PATH)
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[4/7] Instalando gerenciadores de pacotes modernos...${NC}"
sudo apt install -y pipx
pipx ensurepath

# Instalação oficial do UV/UVX
curl -LsSf https://astral.sh/uv/install.sh | sh

# Garantir que o terminal reconheça os novos binários imediatamente nesta sessão
export PATH="$HOME/.local/bin:$PATH"
source "$HOME/.local/bin/env" 2>/dev/null || true
source ~/.bashrc 2>/dev/null || true

# ------------------------------------------------------------------------------
# 5. INSTALAÇÃO DO OPENCODE
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[5/7] Instalação do OpenCode AI...${NC}"
curl -fsSL https://opencode.ai/install | bash

# ------------------------------------------------------------------------------
# 6. INSTALAÇÃO DO NODE.JS & NPM (Escopo do Sistema)
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[6/7] Configurando repositório e instalando Node.js...${NC}"
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg --yes
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt update && sudo apt install nodejs -y

# ------------------------------------------------------------------------------
# 7. INSTALAÇÃO GLOBAL DE BIBLIOTECAS DE REDE, CML2 E IA
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[7/7] Instalando Ansible, Bibliotecas de Redes, IA e CML2 de forma GLOBAL...${NC}"

# Ansible global via pipx (melhor prática para binários CLI)
pipx install --include-deps ansible

# Instalação massiva de bibliotecas de Redes e IA direto no Python global do Ubuntu
pip3 install \
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

# Instalação do servidor CML Model Context Protocol global via UV
echo -e "${BLUE}Instalando cml-mcp globalmente...${NC}"
uv tool install "cml-mcp[pyats]" --with pyats 2>/dev/null || pip3 install "cml-mcp[pyats]"

# ------------------------------------------------------------------------------
# VALIDAÇÃO FINAL
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}======================================================================${NC}"
echo -e "${GREEN}🎉 AMBIENTE GLOBAL CONFIGURADO COM SUCESSO!${NC}"
echo -e "${BLUE}======================================================================${NC}"
echo -e "Tudo pronto! NENHUM ambiente virtual foi criado. Todas as ferramentas abaixo"
echo -e "podem ser chamadas de QUALQUER diretório do seu terminal:"
echo -e ""
echo -e " 🚀 Automação:  Netmiko, NAPALM, pyATS, Ansible, virl2-client"
echo -e " 🤖 Inteligência: Ollama (DeepSeek-R1), OpenCode, CML-MCP, LangChain, CrewAI"
echo -e " 📦 Motores:     Node.js, NPM, Pip, Pipx, UV / UVX"
echo -e "\n👉 Basta abrir o terminal e começar a programar!"
echo -e "${BLUE}======================================================================${NC}"
echo -e "${BLUE}======================================================================${NC}"