# 🌐 DevNet, Automação & IA em Redes de Computadores

> Scripts multiplataforma para preparar um ambiente completo de **NetDevOps**, **CML2 (MCP)** e **Inteligência Artificial Local** em poucos minutos — seja no Linux, macOS ou Windows.

---

## 📋 Índice

- [O que este repositório faz?](#-o-que-este-repositório-faz)
- [Stack de ferramentas instaladas](#-stack-de-ferramentas-instaladas)
- [Estrutura do repositório](#-estrutura-do-repositório)
- [Pré-requisitos](#-pré-requisitos)
- [Guia de instalação por plataforma](#-guia-de-instalação-por-plataforma)
  - [🐧 Linux / WSL (Ubuntu)](#-1-linux--wsl-ubuntu)
  - [🍏 macOS (Apple Silicon ou Intel)](#-2-macos-apple-silicon-ou-intel)
  - [🖧 Windows (PowerShell)](#-3-windows-powershell)
- [Desinstalação e Rollback](#-desinstalação-e-rollback)
- [Boas práticas de laboratório](#-boas-práticas-de-laboratório)
- [Testando o ambiente](#-testando-o-ambiente)

---

## 🎯 O que este repositório faz?

Este projeto automatiza a instalação de um ambiente de desenvolvimento focado em **engenharia de redes com programabilidade**, cobrindo:

- **Automação de redes** com Netmiko, NAPALM, pyATS e Ansible
- **Integração com CML2** via Model Context Protocol (MCP)
- **IA Local** com Ollama + DeepSeek-R1 rodando diretamente na sua máquina
- **IA em Nuvem** com OpenAI, Anthropic, Google Generative AI
- **Frameworks de agentes** com LangChain e CrewAI

Os scripts detectam a plataforma, instalam dependências de sistema, configuram o ambiente Python e deixam tudo pronto para os labs.

---

## 📦 Stack de Ferramentas Instaladas

| Categoria | Tecnologias / Bibliotecas | Descrição |
|---|---|---|
| **Linguagens Base** | Python 3, Node.js (LTS), pip, npm | Motores de execução para scripts de rede e automação |
| **Automação Clássica** | Netmiko, Paramiko, NAPALM, Ansible | Conectividade SSH/API e gerenciamento multi-vendor |
| **Frameworks de Teste** | pyATS, Genie | Framework Cisco para testes de estado de rede e parsing de CLI |
| **Cisco Modeling Labs** | cml-mcp, virl2-client | Integração e controle programático do CML2 via MCP |
| **IA Local** | Ollama, DeepSeek-R1 (1.5b) | Modelo de linguagem rodando 100% offline na sua máquina |
| **IA em Nuvem** | OpenAI SDK, Anthropic, Google GenAI | Integração com modelos GPT, Claude e Gemini |
| **Agentes Inteligentes** | LangChain, CrewAI | Desenvolvimento de agentes e assistentes de rede |
| **Análise de Dados** | Pandas, NumPy, Matplotlib | Processamento e visualização de dados de telemetria |
| **Gerenciadores Modernos** | UV, UVX, Pipx | Gerenciamento rápido e isolado de ambientes Python |
| **Terminal Aprimorado** | Oh My Posh, PSReadLine, Terminal-Icons | Produtividade e autocomplete no PowerShell (Windows) |

---

## 🗂️ Estrutura do Repositório

```
📂 setup-dev/
│
├── 📄 README.md                          # Este guia
│
├── 📄 setup_linux_netdevops.sh           # Linux: ambiente virtual isolado ✅ Recomendado
├── 📄 setup_linux_netdevops-global.sh    # Linux: instalação global no sistema
├── 📄 cleanup_linux_netdevops.sh         # Linux: desinstalação e limpeza
│
├── 📄 setup_mac_netdevops.sh             # macOS: Homebrew + ambiente virtual ✅ Recomendado
├── 📄 setup_mac_netdevops-global.sh      # macOS: instalação global
├── 📄 cleanup_mac_netdevops.sh           # macOS: desinstalação e limpeza
│
├── 📄 setup_powershell_netdevops.ps1     # Windows: PowerShell + Winget + Ollama
└── 📄 cleanup_powershell_netdevops.ps1   # Windows: rollback e limpeza
```

### Modo Virtual vs. Modo Global

| | Modo Virtual (`venv`) ✅ | Modo Global |
|---|---|---|
| **Isola** o Python do sistema | ✅ Sim | ❌ Não |
| **Ideal para** máquinas pessoais e notebooks | ✅ | Containers e VMs dedicadas |
| **Requer ativação** antes de usar | ✅ `source .venv/bin/activate` | ❌ Não |
| **Desinstalação** | Simples — apaga a pasta | Pode afetar o sistema |

---

## ✅ Pré-requisitos

| Plataforma | Requisito |
|---|---|
| Linux / WSL | Ubuntu 22.04, 24.04 ou 26.04 LTS. Usuário comum com `sudo`. |
| macOS | macOS 12+. Usuário comum (sem `sudo`). Homebrew será instalado automaticamente. |
| Windows | Windows 10/11. PowerShell aberto **como Administrador**. `winget` disponível. |

> ⚠️ **Atenção:** Os scripts de Linux e macOS bloqueiam execução como `root` para proteger o sistema.

---

## 🔧 Guia de Instalação por Plataforma

### 🐧 1. Linux / WSL (Ubuntu)

#### Passo 1 — Clone o repositório

```bash
git clone https://github.com/mnisenbaum/setup-dev.git
cd setup-dev
```

#### Passo 2 — Conceda permissão de execução

```bash
chmod +x setup_linux_netdevops*.sh cleanup_linux_netdevops.sh
```

#### Passo 3 — Escolha sua modalidade de instalação

**Opção A: Ambiente Virtual (Recomendado)**

Cria um workspace isolado em `~/netdevops_labs/.venv`, sem tocar no Python nativo do sistema.

```bash
./setup_linux_netdevops.sh
```

Após a instalação, ative o ambiente sempre que abrir um novo terminal:

```bash
cd ~/netdevops_labs && source .venv/bin/activate
```

**Opção B: Instalação Global**

Instala todas as ferramentas diretamente no Python do sistema. Ideal para containers ou VMs dedicadas.

```bash
./setup_linux_netdevops-global.sh
```

---

### 🍏 2. macOS (Apple Silicon ou Intel)

Os scripts detectam automaticamente a arquitetura do processador (`arm64` ou `x86_64`) e configuram o Homebrew no caminho correto.

> 💡 Nos chips M-Series, o Ollama utiliza a GPU unificada nativamente para inferência ultrarrápida.

#### Passo 1 — Clone o repositório

```bash
git clone https://github.com/mnisenbaum/setup-dev.git
cd setup-dev
```

#### Passo 2 — Conceda permissão de execução

```bash
chmod +x setup_mac_netdevops*.sh cleanup_mac_netdevops.sh
```

#### Passo 3 — Escolha sua modalidade de instalação

**Opção A: Ambiente Virtual (Recomendado)**

Cria um workspace isolado em `~/netdevops_labs/.venv` usando Python 3.12 do Homebrew.

```bash
./setup_mac_netdevops.sh
```

Após a instalação, ative o ambiente:

```bash
cd ~/netdevops_labs && source .venv/bin/activate
```

**Opção B: Instalação Global**

Instala tudo no Python gerenciado pelo Homebrew, acessível de qualquer pasta do sistema.

```bash
./setup_mac_netdevops-global.sh
```

---

### 🖧 3. Windows (PowerShell)

O script utiliza o **Winget** (gerenciador nativo do Windows) para instalar Python, Git, Node.js, VS Code e Ollama de forma silenciosa, além de configurar o terminal com autocomplete preditivo e ícones.

#### Passo 1 — Clone o repositório

```powershell
git clone https://github.com/mnisenbaum/setup-dev.git
cd setup-dev
```

#### Passo 2 — Abra o PowerShell como Administrador

> Botão direito no ícone do PowerShell → **"Executar como Administrador"**

#### Passo 3 — Libere a política de execução e rode o script

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\setup_powershell_netdevops.ps1
```

#### O que o script faz no Windows?

- Instala **Python 3.11**, **Git**, **Node.js LTS**, **VS Code** e **Ollama** via Winget
- OPCIONAL - Instala **Oh My Posh** + **CaskaydiaCove Nerd Font** para um terminal com ícones (está desativado por padrão)
- Configura **PSReadLine** com autocomplete preditivo (seta `→` aceita sugestão do histórico)
- Instala **Terminal-Icons** para exibir ícones coloridos no `ls`/`dir`
- Baixa o modelo **DeepSeek-R1 (1.5b)** no Ollama em background
- Gera um `$PROFILE` customizado com aliases Linux (`ll`, `grep`) e mensagem de boas-vindas

#### Após a instalação — Configure a fonte no Windows Terminal

Para que os ícones apareçam corretamente:

1. Abra o Windows Terminal → `Ctrl + ,` (Configurações)
2. Vá em **Perfis → Padrões → Aparência**
3. Altere a **Fonte** para: `CaskaydiaCove Nerd Font`
4. Salve e reinicie o terminal

---

## 🧹 Desinstalação e Rollback

### Linux

**Remoção Manual** (apenas apaga o workspace):
```bash
cd ~
rm -rf ~/netdevops_labs
```

**Remoção Automática** (limpa caches e oferece remover Node.js):
```bash
./cleanup_linux_netdevops.sh
```

### macOS

**Remoção Manual:**
```bash
rm -rf ~/netdevops_labs
```

**Remoção Automática** (limpa caches e oferece desinstalar via Homebrew):
```bash
./cleanup_mac_netdevops.sh
```

### Windows

**Remoção Manual:**
```powershell
# Abra o PowerShell como Administrador
Remove-Item -Recurse -Force C:\venv-devnet
```

**Remoção Automática** (remove Oh My Posh, Ollama, Terminal-Icons e restaura o `$PROFILE`):
```powershell
.\cleanup_powershell_netdevops.ps1
```

> ⚠️ O script de limpeza do Windows **não remove** Python, Git, Node.js e VS Code por padrão, para não quebrar outros projetos. Descomente as linhas relevantes no script se quiser removê-los também.

---

## 💡 Boas Práticas de Laboratório

**1. Sempre ative o ambiente virtual ao abrir um novo terminal (modo venv)**

```bash
# Linux / macOS
cd ~/netdevops_labs && source .venv/bin/activate

# Windows (PowerShell)
& C:\venv-devnet\Scripts\Activate.ps1
```

Você saberá que o ambiente está ativo quando o prompt exibir `(.venv)` no início.

**2. Interagindo com o Ollama (IA Local)**

```bash
# Conversar com o DeepSeek-R1 no terminal
ollama run deepseek-r1:1.5b

# Listar modelos baixados
ollama list

# Baixar outro modelo
ollama pull llama3.2
```

**3. Usando o OpenCode (Terminal AI)**

Após a instalação, basta digitar `opencode` no terminal. Use `Ctrl+P` para alternar entre modelos de IA.

---

## 🧪 Testando o Ambiente

Após ativar o ambiente virtual, execute o comando abaixo para validar que as principais bibliotecas foram instaladas com sucesso:

```python
python -c "
import netmiko
import pyats
import openai
import langchain
print('🔥 Ambiente NetDevOps pronto para automação!')
"
```

Para testar a integração com o CML2:

```python
python -c "
from virl2_client import ClientLibrary
print('✅ virl2-client importado com sucesso!')
"
```

---

## ✒️ Sobre

Repositório mantido em [mnisenbaum/setup-dev](https://github.com/mnisenbaum/setup-dev) para laboratórios e estudos de infraestrutura como código, automação de redes e Inteligência Artificial aplicada a NetDevOps.
