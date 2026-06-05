#!/bin/bash

# ====================================================================
# SCRIPT DE DESINSTALAÇÃO - macOS
# Remove o ambiente virtual e pacotes específicos do Homebrew
# ====================================================================

echo "🧹 Iniciando a limpeza do ambiente macOS..."

# 1. Desativar o ambiente virtual se ele estiver ativo
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

# 3. Perguntar sobre a remoção de pacotes instalados via Homebrew
read -p "❓ Deseja desinstalar Node.js, Python3 e JQ via Homebrew? (s/N): " confirm_brew
if [[ "$confirm_brew" =~ ^[Ss]$ ]]; then
    echo "🍺 Removendo pacotes do Homebrew..."
    brew uninstall python node jq
    brew autoremove
fi

# 4. Limpando caches locais de instalação
echo "🧹 Limpando caches de pacotes locais..."
rm -rf ~/Library/Caches/pip

echo "✅ Limpeza concluída no macOS!"