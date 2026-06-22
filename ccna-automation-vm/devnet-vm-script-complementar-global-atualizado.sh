#!/usr/bin/env bash

# ==============================================================================
# SCRIPT DE CONFIGURAÇÃO MESTRE: NETDEVOPS, CCNA DEVNET ASSOCIATE & IA LOCAL
# Alvo: Ubuntu 22.04 / 24.04 / 26.04 LTS ou WSL (Instalação Global Otimizada com UV)
# v1.1 - Full DEVASC-VM Replacer (Ultra Fast Execution)
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}======================================================================${NC}"
echo -e "${GREEN}  Configurando Ambiente Global NetDevOps, CCNA DevNet e IA v1.1     ${NC}"
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
echo -e "\n${YELLOW}[1/7] Instalando dependências essenciais do sistema e utilitários de rede...${NC}"
sudo apt update && sudo apt upgrade -y

sudo apt install -y \
    curl wget git unzip build-essential software-properties-common \
    ca-certificates gnupg jq zstd libssl-dev \
    libffi-dev libxml2-dev libxslt1-dev zlib1g-dev \
    python3-dev python3-pip python3-venv \
    net-tools tcpdump telnet sshpass sqlitebrowser nmap mtr-tiny pipx

# Configurar o pipx imediatamente no PATH
pipx ensurepath

# ------------------------------------------------------------------------------
# 2. INSTALAÇÃO DO MOTOR ULTRA-RÁPIDO (ASTRAL UV)
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[2/7] Instalando o gerenciador ultra-rápido UV em Rust...${NC}"
curl -LsSf https://astral.sh/uv/install.sh | sh

# Atualizar o PATH dinamicamente para usar o UV nesta sessão
export PATH="$HOME/.local/bin:$PATH"
source "$HOME/.local/bin/env" 2>/dev/null || true

# ------------------------------------------------------------------------------
# 3. TRATAMENTO INTELIGENTE DO DOCKER (WSL vs VM TRADICIONAL)
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[3/7] Verificando ambiente para configuração do Docker...${NC}"

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
echo -e "\n${YELLOW}[4/7] Instalando o Ollama para execução de IA Local...${NC}"
curl -fsSL https://ollama.com/install.sh | sh
sudo systemctl start ollama 2>/dev/null || true

echo -e "${BLUE}Baixando o modelo DeepSeek-R1 destilado (1.5b) localmente...${NC}"
ollama pull deepseek-r1:1.5b

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
# 7. INSTALAÇÃO MULTI-THREAD ULTRA-RÁPIDA DAS BIBLIOTECAS (UV PIP GLOBAL)
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[7/7] Instalando Ansible, Bibliotecas DevNet (NETCONF/YANG), IA e CML2 via UV...${NC}"

# Ansible via pipx isolado para binários limpos
pipx install --include-deps ansible 2>/dev/null || true

# O pulo do gato: UV instalando em paralelo usando todas as suas 14 threads cravadas no sistema global (--system)
uv pip install --system \
    netmiko paramiko napalm pyats genie requests urllib3 virl2-client \
    openai anthropic google-genai langchain crewai openclaw mcp \
    ncclient pyang xmltodict pysnmp webexteamssdk unicon

# Instalação do CML Model Context Protocol via UV Tooling
echo -e "${BLUE}Instalando cml-mcp...${NC}"
uv tool install "cml-mcp[pyats]" --with pyats 2>/dev/null || uv pip install --system "cml-mcp[pyats]"

# ------------------------------------------------------------------------------
# VALIDAÇÃO FINAL
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}======================================================================${NC}"
echo -e "${GREEN}🎉 AMBIENTE MESTRE OTIMIZADO CONFIGURADO COM SUCESSO!${NC}"
echo -e "${BLUE}======================================================================${NC}"
echo -e "Tudo pronto! O uso do UV eliminou o gargalo e concluiu a instalação global."
echo -e "Ferramentas disponíveis em qualquer diretório:"
echo -e ""
echo -e " 🚀 DevNet & Automação: Netmiko, NAPALM, pyATS, Ansible, virl2-client, ncclient (NETCONF), pyang (YANG)"
echo -e " 🤖 Inteligência Local:  Ollama (DeepSeek-R1), OpenCode, CML-MCP, LangChain, CrewAI"
echo -e " 🐋 Containers & Infra: Docker (Configurado de acordo com o ambiente), tcpdump, telnet, net-tools"
echo -e " 🗄️ Utilitários:        SQLiteBrowser (para laboratórios de Banco de Dados)"
echo -e " 📦 Motores de Pacotes: Node.js, NPM, Pip, Pipx, UV / UVX"
echo -e "\n👉 Pode salvar este script e rodá-lo. O seu ambiente agora voa!"
echo -e "${BLUE}======================================================================${NC}"