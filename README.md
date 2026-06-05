🌐 DevNet, Automação & IA em Redes de ComputadoresEste repositório contém um conjunto completo de scripts de automação para preparar ambientes de desenvolvimento voltados para engenharia de redes, programabilidade, automação e Inteligência Artificial.Com suporte multiplataforma (Ubuntu/WSL, macOS e Windows), os scripts realizam o deploy de ferramentas essenciais como Python, Node.js, gerenciadores de pacotes e as principais bibliotecas do ecossistema Cisco DevNet e IA.🚀 Como Começar (Clonando o Repositório)Para utilizar os scripts na sua máquina local ou ambiente de laboratório, abra o terminal e clone o repositório utilizando os comandos abaixo:# Clone o repositório
git clone [https://github.com/mnisenbaum/setup-dev.git](https://github.com/mnisenbaum/setup-dev.git)

# Acesse a pasta do projeto
cd setup-dev
📊 Stack de Ferramentas InstaladasCategoriaTecnologias / BibliotecasDescriçãoLinguagens BasePython 3, Node.js (LTS), pip, npmMotores de execução para scripts de rede e automação.Automação ClássicaNetmiko, Paramiko, NAPALM, AnsibleConectividade SSH/API, gerenciamento de configuração e multi-vendor.Frameworks de TestepyATS, GenieFramework da Cisco para testes de estado de rede e parsing de CLI.Cisco Modeling Labscmlmisc, virlutils (MCP)Integração e controle programático do CML2.Inteligência ArtificialOpenAI SDK, LangChainDesenvolvimento de agentes inteligentes e assistentes de rede (LLM).Análise de DadosPandas, NumPy, MatplotlibProcessamento, modelagem e visualização de dados de telemetria.🗂️ Estrutura de Arquivos do RepositórioAs instalações para os sistemas Unix-like (Linux/macOS) estão divididas em duas modalidades:Modo Virtual (venv) - Recomendado: Instala as dependências Python em um ambiente isolado, protegendo o Python nativo do sistema operacional.Modo Global (global): Instala as dependências diretamente no escopo do usuário/sistema (ideal para containers ou máquinas virtuais dedicadas).Todos os scripts estão padronizados e localizados na raiz do projeto:📂 setup-dev (Diretório Raiz)

├── 📄 README.md                             # Este guia de instruções
│
├── 📄 setup_linux_netdevops.sh              # Linux: Setup isolado com ambiente virtual (Recomendado)
├── 📄 setup_linux_netdevops-global.sh       # Linux: Setup global no sistema/usuário
├── 📄 cleanup_linux_netdevops.sh            # Linux: Remove venv, limpa pacotes e caches
│
├── 📄 setup_mac_netdevops.sh                # macOS: Setup isolado com Homebrew + venv (Recomendado)
├── 📄 setup_mac_netdevops-global.sh         # macOS: Setup global no sistema
├── 📄 cleanup_mac_netdevops.sh              # macOS: Desinstala pacotes e limpa caches localmente
│
├── 📄 setup_powershell_netdevops.ps1        # Windows: Setup via PowerShell + Chocolatey + venv
└── 📄 cleanup_powershell_netdevops.ps1      # Windows: Remove ambiente virtual e limpa caches

🔧 Guia de Uso Passo a Passo🐧 1. Ubuntu / WSL (Linux)Antes de executar, conceda permissão de execução aos scripts que irá utilizar:chmod +x setup_linux_netdevops*.sh cleanup_linux_netdevops.sh
Opção A: Instalação com Ambiente Virtual (Altamente Recomendado)Cria um ambiente virtual isolado em ~/venv-devnet para evitar conflitos com o sistema../setup_linux_netdevops.sh
Como ativar o ambiente após a instalação:source ~/venv-devnet/bin/activate
Opção B: Instalação GlobalInstala todos os pacotes Python e ferramentas diretamente no escopo do sistema operacional../setup_linux_netdevops-global.sh
🧹 Desinstalação / Rollback (Linux):Se optou pelo Modo Virtual (venv), a desinstalação consiste simplesmente em apagar a pasta local.Remoção Manual (Apenas o ambiente virtual):deactivate 2>/dev/null
rm -rf ~/venv-devnet
Remoção Automática (Limpeza Completa via script):Remove o ambiente virtual, limpa os caches do pip do sistema e oferece a opção de expurgar o Node.js:./cleanup_linux_netdevops.sh
🍏 2. macOS (Apple Silicon M1/M2/M3 ou Intel)Os scripts detectam automaticamente a arquitetura do processador e instalam o gerenciador Homebrew caso ele não esteja presente. Conceda permissão de execução antes de iniciar:chmod +x setup_mac_netdevops*.sh cleanup_mac_netdevops.sh
Opção A: Instalação com Ambiente Virtual (Altamente Recomendado)Isola todas as bibliotecas de IA e Redes em ~/venv-devnet../setup_mac_netdevops.sh
Como ativar o ambiente após a instalação:source ~/venv-devnet/bin/activate
Opção B: Instalação GlobalInstala as dependências diretamente nas pastas do sistema gerenciadas pelo Python global do Homebrew../setup_mac_netdevops-global.sh
🧹 Desinstalação / Rollback (macOS):Se utilizou o Modo Virtual (venv), a desinstalação pode ser feita limpando a pasta do ambiente.Remoção Manual (Apenas o ambiente virtual):deactivate 2>/dev/null
rm -rf ~/venv-devnet
Remoção Automática (Limpeza Completa via script):Exclui o ambiente virtual, limpa os caches do pip no macOS e gerencia a remoção de ferramentas associadas via Homebrew:./cleanup_mac_netdevops.sh
🖧 3. Windows (PowerShell)O script para Windows utiliza o gerenciador Chocolatey para instalar Git, Python 3 e Node.js de forma silenciosa, configurando o ambiente virtual de forma nativa em C:\venv-devnet.Abra o PowerShell como Administrador e execute:Set-ExecutionPolicy Bypass -Scope Process -Force
Execute o script de instalação:.\setup_powershell_netdevops.ps1
Como ativar o ambiente no Windows:& C:\venv-devnet\Scripts\Activate.ps1
🧹 Desinstalação / Rollback (Windows):Toda a instalação das dependências Python e IA fica restrita ao diretório C:\venv-devnet.Remoção Manual (Apenas o ambiente virtual):deactivate
Remove-Item -Recurse -Force C:\venv-devnet
Remoção Automática (Limpeza Completa via script):Para remover o diretório virtual e limpar os arquivos temporários e caches do Windows:.\cleanup_powershell_netdevops.ps1
💡 Boas Práticas de LaboratórioSempre que abrir um novo terminal, lembre-se de ativar o ambiente virtual (caso tenha optado por essa modalidade):Linux/Mac: source ~/venv-devnet/bin/activateWindows (PS): C:\venv-devnet\Scripts\Activate.ps1Testando a Instalação: Para garantir que tudo foi instalado com sucesso, ative seu ambiente e execute no terminal:python -c "import netmiko; import pyats; import openai; print('🔥 Ambiente pronto para automação!')"
✒️ Guia mantido no repositório oficial mnisenbaum/setup-dev para laboratórios e estudos de infraestrutura como código.
