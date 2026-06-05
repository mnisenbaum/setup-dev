#!/bin/bash

# ====================================================================
# SCRIPT DE DESINSTALAÇÃO - UBUNTU / WSL
# Remove o ambiente virtual, bibliotecas e pacotes DevNet/IA
# ====================================================================

echo "🧹 Iniciando a limpeza do ambiente Ubuntu/WSL..."

# 1. Desativar o ambiente virtual se ele estiver ativo nesta sessão
if [[ "$VIRTUAL_ENV" != "" ]]; then
    echo "🔄 Desativando o ambiente virtual Python ativo..."
    deactivate
fi

# 2. Remover a pasta do ambiente virtual
if [ -d "$HOME/venv-devnet" ]; then
    echo "🗑️ Removendo o ambiente virtual Python (~/venv-devnet)..."
    rm -rf "$HOME/venv-devnet"
else
    echo "ℹ️ Ambiente virtual em ~/venv-devnet não encontrado."
fi

# 3. Remover Node.js e NPM (opcional, dependendo se o usuário já os usava antes)
read -p "❓ Deseja remover o Node.js e o NPM instalados pelo script de setup? (s/N): " confirm_node
if [[ "$confirm_node" =~ ^[Ss]$ ]]; then
    echo "🗑️ Removendo Node.js e NPM..."
    sudo apt purge -y nodejs
    sudo apt autoremove -y
fi

# 4. Limpeza de caches do gerenciador de pacotes
echo "🧹 Limpando caches do sistema..."
sudo apt clean
rm -rf ~/.cache/pip

echo "✅ Limpeza concluída no Ubuntu/WSL!"