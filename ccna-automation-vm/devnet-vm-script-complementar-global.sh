#!/usr/bin/env bash

# ==============================================================================
# SCRIPT COMPLEMENTAR: LABS OFICIAIS CCNA DEVNET (PROGRAMAÇÃO & INFRA)
# Alvo: Integração com o setup_linux_netdevops-global.sh
# ==============================================================================

YELLOW='\033[1;33m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${BLUE}======================================================================${NC}"
echo -e "${GREEN}  Instalando Complementos Oficiais para Labs CCNA DevNet (Fase 2)    ${NC}"
echo -e "${BLUE}======================================================================${NC}"

# ------------------------------------------------------------------------------
# 1. VALIDAÇÃO DO DOCKER (WSL vs VM TRADICIONAL)
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[1/3] Verificando ambiente para configuração do Docker...${NC}"

if grep -qEi "(Microsoft|WSL)" /proc/version; then
  echo -e "${GREEN}💡 Detectado ambiente WSL!${NC}"
  echo -e "O Docker Desktop do Windows deve ser usado com a integração WSL ativada."
  echo -e "Ignorando a instalação do daemon do Docker para evitar conflitos."
  
  # Apenas garante que se o docker do windows não mapeou o binário por algum motivo,
  # o aluno tenha as ferramentas de CLI locais se necessário.
  sudo apt install -y docker-buildx-plugin docker-compose-plugin 2>/dev/null || true
else
  echo -e "${BLUE}🐧 Detectado Ubuntu Nativo/VM Tradicional. Instalando Docker Engine...${NC}"
  sudo apt update
  sudo apt install -y docker.io
  sudo systemctl enable --now docker
  # Adiciona o usuário atual ao grupo docker para não precisar de sudo nos labs
  sudo usermod -aG docker $USER
  echo -e "${GREEN}✓ Docker instalado. Nota: Pode ser necessário deslogar/logar para aplicar permissões do grupo.${NC}"
fi

# ------------------------------------------------------------------------------
# 2. UTILITÁRIOS DE REDE E BANCO DE DADOS (APT)
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[2/3] Instalando utilitários de sistema exigidos nos laboratórios...${NC}"

sudo apt install -y \
    net-tools \
    tcpdump \
    telnet \
    sshpass \
    sqlitebrowser \
    nmap \
    mtr-tiny

# ------------------------------------------------------------------------------
# 3. BIBLIOTECAS PYTHON ESPECÍFICAS/LEGADAS (PIP GLOBAL)
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[3/3] Instalando bibliotecas DevNet fundamentais (NETCONF, YANG, Webex)...${NC}"

# Forçando o bypass do Ubuntu que você já configurou no script principal
pip3 install --break-system-packages \
    ncclient \
    pyang \
    xmltodict \
    pysnmp \
    webexteamssdk \
    unicon

# ------------------------------------------------------------------------------
# CONCLUSÃO
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}======================================================================${NC}"
echo -e "${GREEN}🎉 COMPLEMENTOS INSTALADOS COM SUCESSO!${NC}"
echo -e "${BLUE}======================================================================${NC}"
echo -e " O ambiente agora está 100% equiparado à VM oficial para os laboratórios de:"
echo -e " 🌐 Modelagem de Dados (YANG) & Protocolos (NETCONF com ncclient/xmltodict)"
echo -e " 💬 ChatOps & Colaboração (Webex SDK)"
echo -e " 🗄️ Bancos de Dados Locais (Labs de SQL/SQLite com SQLiteBrowser)"
echo -e " 🐋 Conteinerização (Docker configurado de acordo com seu ecossistema)"
echo -e "\nPróximo Passo: Se preferir, podemos unificar os dois scripts em um único arquivo mestre."
echo -e "${BLUE}======================================================================${NC}"