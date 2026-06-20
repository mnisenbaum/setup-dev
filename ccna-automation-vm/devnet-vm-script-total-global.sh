#!/usr/bin/env bash

# ==============================================================================
# SCRIPT DE CONFIGURAÇÃO MESTRE: NETDEVOPS, CCNA DEVNET ASSOCIATE & IA LOCAL
# Alvo: Ubuntu 22.04 / 24.04 / 26.04 LTS ou WSL (Instalação 100% Global)
# v1.0 - Full DEVASC-VM Replacer (Modernizado)
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}======================================================================${NC}"
echo -e "${GREEN}  Configurando Ambiente Global NetDevOps, CCNA DevNet e IA v1.0     ${NC}"
echo -e "${BLUE}======================================================================${NC}"

# ------------------------------------------------------------------------------
# DISCLAIMER INTERATIVO (GLOBAL)
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}AVISO: Este script fará instalações GLOBAIS no sistema (pode afetar outros projetos).${NC}"
echo -e "${YELLOW}⚠️  Este script é recomendado APENAS para máquinas virtuais de estudo/teste ou WSL dedicado.${NC}"
echo -e "${RED}🚫 NUNCA execute este script em máquinas de produção ou computadores pessoais de uso diário.${NC}"
echo -e "${CYAN}💡 Em máquinas pessoais de uso diário, prefira usar ambientes virtuais isolados (venvs).${NC}"
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
# 1. ATUALIZAÇÃO E DEPENDÊNCIAS CRÍTICAS DO SISTEMA (APT)
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[1/8] Instalando dependências essenciais do sistema e utilitários de rede...${NC}"
sudo apt update && sudo apt upgrade -y

sudo apt install -y \
    curl wget git unzip build-essential software-properties-common \
    ca-certificates gnupg jq zstd libssl-dev \
    libffi-dev libxml2-dev libxslt1-dev zlib1g-dev \
    python3-dev python3-pip python3-venv \
    net-tools tcpdump telnet sshpass sqlitebrowser nmap mtr-tiny

# ------------------------------------------------------------------------------
# 2. LIBERAÇÃO DO PIP GLOBAL (Bypass de Segurança do Ubuntu)
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[2/8] Desbloqueando instalação de pacotes globais no Python do sistema...${NC}"
sudo pip3 config set global.break-system-packages true 2>/dev/null || true
python3 -m pip install --upgrade pip --break-system-packages

# ------------------------------------------------------------------------------
# 3. TRATAMENTO INTELIGENTE DO DOCKER (WSL vs VM TRADICIONAL)
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[3/8] Verificando ambiente para configuração do Docker...${NC}"

if grep -qEi "(Microsoft|WSL)" /proc/version; then
  echo -e "${GREEN}💡 Ambiente WSL detectado!${NC}"
  echo -e "O Docker Desktop do Windows deve gerenciar o daemon. Ative a integração WSL nas configurações dele."
  echo -e "Ignorando instalação do motor nativo para evitar conflitos de portas/daemons."
  sudo apt install -y docker-buildx-plugin docker-compose-plugin 2>/dev/null || true
else
  echo -e "${BLUE}🐧 Ambiente Ubuntu Nativo/VM Tradicional detectado. Instalando Docker Engine...${NC}"
  sudo apt install -y docker.io
  sudo systemctl enable --now docker
  sudo usermod -aG docker $USER
  echo -e "${GREEN}✓ Docker instalado com sucesso (as permissões de grupo exigem novo login).${NC}"
fi

# ------------------------------------------------------------------------------
# 4. INSTALAÇÃO DO OLLAMA (IA Local)
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[4/8] Instalando o Ollama para execução de IA Local...${NC}"
curl -fsSL https://ollama.com/install.sh | sh
sudo systemctl start ollama 2>/dev/null || true

echo -e "${BLUE}Baixando o modelo DeepSeek-R1 destilado (1.5b) localmente...${NC}"
ollama pull deepseek-r1:1.5b

# ------------------------------------------------------------------------------
# 5. INSTALAÇÃO DO PIPX, UV e UVX (Gerenciadores Modernos)
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[5/8] Instalando gerenciadores de pacotes modernos...${NC}"
sudo apt install -y pipx
pipx ensurepath

curl -LsSf https://astral.sh/uv/install.sh | sh

# Atualizar o PATH imediatamente para esta sessão de instalação
export PATH="$HOME/.local/bin:$PATH"
source "$HOME/.local/bin/env" 2>/dev/null || true
source ~/.bashrc 2>/dev/null || true

# ------------------------------------------------------------------------------
# 6. INSTALAÇÃO DO OPENCODE
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[6/8] Instalação do OpenCode AI...${NC}"
curl -fsSL https://opencode.ai/install | bash

# ------------------------------------------------------------------------------
# 7. INSTALAÇÃO DO NODE.JS & NPM (Escopo do Sistema)
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[7/8] Configurando repositório e instalando Node.js...${NC}"
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg --yes
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt update && sudo apt install nodejs -y

# ------------------------------------------------------------------------------
# 8. INSTALAÇÃO GLOBAL DE BIBLIOTECAS DE REDE, CCNA DEVNET E IA (PIP GLOBAL)
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[8/8] Instalando Ansible, Bibliotecas DevNet (NETCONF/YANG), IA e CML2...${NC}"

# Ansible via pipx (isolado para binários globais limpos)
pipx install --include-deps ansible

# Instalação massiva combinando seu ecossistema moderno com os requisitos do CCNA DevNet
pip3 install --break-system-packages \
    netmiko paramiko napalm pyats genie requests urllib3 virl2-client \
    openai anthropic google-genai langchain crewai openclaw mcp \
    ncclient pyang xmltodict pysnmp webexteamssdk unicon

# Instalação do servidor CML Model Context Protocol via UV
echo -e "${BLUE}Instalando cml-mcp...${NC}"
uv tool install "cml-mcp[pyats]" --with pyats 2>/dev/now || pip3 install --break-system-packages "cml-mcp[pyats]"

# ------------------------------------------------------------------------------
# VALIDAÇÃO FINAL
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}======================================================================${NC}"
echo -e "${GREEN}🎉 AMBIENTE MESTRE CONFIGURADO COM SUCESSO!${NC}"
echo -e "${BLUE}======================================================================${NC}"
echo -e "Tudo pronto! Seu ambiente substitui 100% a DEVASC-VM antiga de forma moderna."
echo -e "Ferramentas disponíveis globalmente em qualquer terminal:"
echo -e ""
echo -e " 🚀 DevNet & Automação: Netmiko, NAPALM, pyATS, Ansible, virl2-client, ncclient (NETCONF), pyang (YANG)"
echo -e " 🤖 Inteligência Local:  Ollama (DeepSeek-R1), OpenCode, CML-MCP, LangChain, CrewAI"
echo -e " 🐋 Containers & Infra: Docker (Configurado para o ecossistema atual), tcpdump, telnet, net-tools"
echo -e " 🗄️ Utilitários:        SQLiteBrowser (para os laboratórios de Banco de Dados locais)"
echo -e " 📦 Motores:            Node.js, NPM, Pip, Pipx, UV / UVX"
echo -e "\n👉 Basta abrir o terminal e começar a criar códigos incríveis para a infraestrutura!"
echo -e "${BLUE}======================================================================${NC}"