# CriaPlaylist — Gerador de Playlists e Rotações para ZaraRadio

<div align="center">
  <img src="app_icon.png" width="160" height="160" alt="CriaPlaylist Logo" />
  <br />
  <strong>Gerenciador ágil de rotações de áudio (.rot) e montagem de Playlists Master (.lst) para emissoras de rádio e web rádios.</strong>
  <br /><br />
  
  ![Delphi 12](https://img.shields.io/badge/Delphi-12%20Athens-red.svg?logo=delphi)
  ![Platform Windows](https://img.shields.io/badge/Plataforma-Windows%20x86%20%7C%20x64-blue.svg?logo=windows)
  ![ZaraRadio](https://img.shields.io/badge/Compatibilidade-ZaraRadio-brightgreen.svg)
  ![License MIT](https://img.shields.io/badge/Licen%C3%A7a-MIT-orange.svg)
</div>

---

## 📌 Sobre o Projeto

O **CriaPlaylist** é uma ferramenta desenvolvida em **Delphi** voltada para radialistas, operadores e programadores musicais que utilizam o software de automação **ZaraRadio**. 

O objetivo do programa é eliminar tarefas manuais e lentas na montagem de programações radiofônicas, permitindo:
1. **Varredura rápida** de milhares de músicas em pastas e subpastas locais ou de rede;
2. **Cálculo automático de duração milimétrica** (em milissegundos) para arquivos de rotação `.rot`;
3. **Player de áudio integrado** para checagem rápida de faixas antes da inclusão;
4. **Montagem de Playlists Master `.lst`** com inserção de comandos horários (`.time`) e reordenação instantânea;
5. **Pré-visualização sincronizada** em tempo real do arquivo `.lst` gerado.

---

## ✨ Principais Funcionalidades

### 📻 1. Criação de Rotações de Músicas (`.rot`)
- Suporte a múltiplos formatos de mídia: `.mp3`, `.mp4`, `.wav`, `.wma`, `.ogg`, `.m4a` e `.aac`.
- Leitura exata da duração em milissegundos através da API **Windows Media Foundation** (`IMFSourceReader`).
- Tratamento automático com `-2` (código padrão do ZaraRadio para arquivos sem leitura prévia).
- Exportação no padrão oficial:
  ```ini
  [playlist]
  file0=D:\Musicas\Faixa1.mp3
  length0=198452
  file1=D:\Musicas\Faixa2.mp3
  length1=230279
  numberofentries=2
  nextindex=0
  ```
- Gravação com codificação **ANSI / Windows-1252** para 100% de compatibilidade com o ZaraRadio.

### 📋 2. Montagem de Playlist Master (`.lst`)
- Adição de arquivos de rotação (`.rot`) diretamente para a grade master.
- Botão rápido para inserção do comando de hora certa (**`.time`**).
- Controles de organização de sequência: **Subir**, **Descer** e **Remover Item**.
- **Preview em Tempo Real**: Painel lateral que reflete instantaneamente a estrutura do arquivo `.lst`:
  ```text
  3
  -1	D:\Rotacoes\Comerciais.rot
  .time
  -1	D:\Rotacoes\Musicas90.rot
  ```

### 🎧 3. Player de Áudio Integrado (Multi-threaded)
- Permite escutar qualquer faixa da lista para conferir vinhetas, chamadas e músicas.
- Controles de **Tocar (Play)**, **Pausar (Pause)** e **Parar (Stop)**.
- Atalho de **Duplo Clique** na lista de músicas para reprodução imediata.
- Reprodução via **Windows MCI (`mciSendString`)** desacoplada da interface por meio de threads dedicadas, impedindo qualquer travamento ou congelamento da tela durante a execução.

### ⚡ 4. Leitura Ultrarrápida de Pastas sem Engasgos
- Processamento em segundo plano via `TThread.CreateAnonymousThread`.
- Navegação iterativa com fila (`TQueue<string>`), imune a estouro de pilha (*stack overflow*) e rápida em discos com grande volume de pastas.
- Proteção inteligente contra pastas protegidas do Windows (`$RECYCLE.BIN`, `System Volume Information`), prevenindo erros de permissão negada.
- Barra de progresso com animação **Marquee** enquanto varre as pastas.

---

## 🖼️ Interface do Sistema

```
+-------------------------------------------------------------------------------------------------------------+
| CriaPlaylist - Gerador de Playlists e Rotações - ZaraRadio                                       [ _ ][ X ] |
+-------------------------------------------------------------------------------------------------------------+
| Diretório com músicas: [ D:\Backup\Musicas\                      ] [ Localizar... ]                         |
|                                                                                                             |
| Músicas do Diretório (Thread)    Ações           Músicas da Playlist (.rot)    Playlist Master (.lst)       |
| +-----------------------------+  +------------+  +-------------------------+   +--------------------------+ |
| | Faixa 01 - Rock.mp3         |  | Adicionar> |  | Faixa 01 - Rock.mp3     |   | Comerciais.rot           | |
| | Faixa 02 - Pop.mp3          |  | Add Todos>>|  | Faixa 02 - Pop.mp3      |   | .time                    | |
| | Faixa 03 - Dance.mp3        |  | <Remover   |  +-------------------------+   | Musicas90.rot            | |
| | ...                         |  |<<Rem Todos |  [ Salvar Playlist (.rot) ]    +--------------------------+ |
| +-----------------------------+  +------------+                                [Buscar .rot] [.time] [X]    |
| [▶ Play] [⏸ Pause] [⏹ Stop]                                                   [▲ Subir] [▼ Descer] [Salvar]|
| Status: Player: Tocando...                                                     Preview em Tempo Real (.lst) |
+-------------------------------------------------------------------------------------------------------------+
| Barra de Progresso: [==================================] Status e Logs: 142 arquivos lidos com sucesso.     |
+-------------------------------------------------------------------------------------------------------------+
```

---

## 🚀 Como Compilar o Projeto

### Pré-requisitos
- **Embarcadero Delphi 12 Athens** (ou superior / compatível com VCL moderna).
- **Windows 10 ou Windows 11** (x86 ou x64).

### Compilação via Linha de Comando (DCC32)
Abra o prompt de comando ou PowerShell na raiz do projeto:

```powershell
# Compilar recursos e ícone
brcc32 Project1.rc -fo Project1.res

# Compilar o executável
dcc32 Project1.dpr

# Compilar versão de Debug
dcc32 -B -EWin32\Debug -NUWin32\Debug Project1.dpr
```

---

## 📦 Gerando o Instalador

O instalador oficial é gerado utilizando o **Inno Setup 6**.

1. Certifique-se de que o Inno Setup 6 está instalado em sua máquina.
2. Execute o compilador de script de instalação:
   ```powershell
   & "C:\Users\Denize Abreu\AppData\Local\Programs\Inno Setup 6\ISCC.exe" CriaPlaylist_Setup.iss
   ```
3. O instalador final será gerado em:
   ```
   installer_output\Instalador_CriaPlaylist_v1.0.0.exe
   ```

O instalador inclui:
- Assistente moderno em **Português do Brasil**;
- Criação de atalhos na Área de Trabalho e no Menu Iniciar;
- Associação com o ícone temático de alta resolução;
- Desinstalador limpo integrado ao Painel de Controle / Configurações do Windows.

---

## 📂 Estrutura de Arquivos

```plaintext
├── Project1.dpr            # Ponto de entrada do programa Delphi
├── Project1.dproj          # Arquivo de projeto do RAD Studio
├── Project1.rc             # Definição de recursos (MAINICON)
├── Project1.res            # Recursos binários compilados (com ícone)
├── UnitPrincipal.pas       # Lógica central (Player, Threads, ZaraRadio .rot/.lst)
├── UnitPrincipal.dfm       # Layout visual da interface gráfica VCL
├── app_icon.ico            # Ícone multi-resolução do sistema (256 a 16px)
├── app_icon.png            # Logotipo oficial em alta definição
├── CriaPlaylist_Setup.iss  # Script do instalador Inno Setup 6
├── .gitignore              # Regras de exclusão para Git
└── README.md               # Esta documentação
```

---

## 📄 Licença

Distribuído sob a licença **MIT**. Consulte o arquivo de licença ou sinta-se à vontade para utilizar e estender o projeto.
