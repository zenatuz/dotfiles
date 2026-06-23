# AI Cost Optimization Stack — Instalação no Mac

Stack: **RTK** + **Headroom** + **Caveman** + **OpenUsage**

## Setup Atual

| IDE | Provider | Tipo |
|-----|----------|------|
| VSCode | GitHub Copilot | Trabalho |
| OpenCode | DeepSeek | Pessoal |

## Visão Geral da Arquitetura

```
┌─────────────────────────────────────────────────────────┐
│                    Mac Work Machine                       │
│                                                          │
│  ┌──────────┐    ┌──────────────┐    ┌───────────────┐   │
│  │  VSCode   │    │   OpenCode   │    │  OpenUsage    │   │
│  │  Copilot  │    │   DeepSeek   │    │  (menu bar)   │   │
│  └─────┬────┘    └──────┬───────┘    └───────┬───────┘   │
│        │                │                     │          │
│  ┌─────▼────┐     ┌─────▼──────┐              │          │
│  │   RTK    │     │  Headroom  │              │          │
│  │  (hook)  │     │  (proxy)   │              │          │
│  └──────────┘     └─────┬──────┘              │          │
│                         │                     │          │
│  ┌──────────────────────▼─────────────────────▼──────┐   │
│  │               API Providers                         │   │
│  │  GitHub Copilot API  │  DeepSeek API                │   │
│  └───────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

---

## 1. RTK — Compactação de Output de Comandos

Rust binary, zero dependências. Filtra output de `git`, `ls`, `grep`, `test`, etc.

### Instalação

```bash
# Homebrew (recomendado no Mac)
brew install rtk

# Verificar
rtk --version
rtk gain
```

### Configuração

Para **GitHub Copilot** no terminal:

```bash
rtk init -g                    # hook global para Claude Code / Copilot
```

Para **OpenCode** — usar o plugin `openrtk` (npm):

```bash
# 1. Instalar o plugin via npm
npm install openrtk

# 2. Adicionar ao opencode.json (~/.config/opencode/opencode.json)
# "plugin": ["openrtk"]

# 3. Verificar se está carregado
opencode plugin list
```

Exemplo de `~/.config/opencode/opencode.json` com o plugin:

```json
{
  "plugin": ["openrtk"],
  "default_agent": "caveman",
  "provider": "deepseek"
}
```

O plugin `openrtk` (163 ⭐ no GitHub, 11.1 kB, zero deps) hooka no evento `tool.execute.before` do OpenCode e reescreve comandos shell para passar pelo RTK automaticamente. Suporta git, cargo, npm, docker, kubectl, grep, ls, pytest, curl e dezenas de outros comandos.

> **Alternativa sem plugin**: `rtk init -g` cria um hook global que funciona para qualquer CLI em shell (incluindo OpenCode quando executa comandos bash), mas não captura comandos executados via tool calls internas.

### Como funciona

O hook do RTK intercepta comandos Bash antes de executá-los e reescreve para versões compactadas:

| Comando | Tokens (antes) | Tokens (depois) | Economia |
|---------|:--------------:|:---------------:|:--------:|
| `git status` | ~300 | ~60 | ~80% |
| `grep/rg` | ~2.000 | ~200 | ~90% |
| `ls -la` | ~800 | ~150 | ~81% |
| `cargo test` | ~5.000 | ~500 | ~90% |

---

## 2. Headroom — Proxy de Compressão

Python/TypeScript. Proxy que comprime payloads de tool outputs antes de enviar ao LLM.

### Instalação (via venv dedicado)

Headroom será instalado em um **venv dedicado** para não poluir seu Python global:

```bash
# 1. Criar o venv dedicado
python3 -m venv ~/.local/venvs/headroom

# 2. Ativar e instalar
source ~/.local/venvs/headroom/bin/activate
pip install "headroom-ai[proxy]"
deactivate

# 3. Verificar
~/.local/venvs/headroom/bin/headroom --help
```

### Aliases no .zshrc

Adicione ao `~/.zsh/zsh-custom.sh` (ou direto no `.zshrc`):

```bash
# Headroom — proxy de compressão LLM
alias headroom='$HOME/.local/venvs/headroom/bin/headroom'

# Iniciar proxy Headroom (modo manual)
alias headroom-proxy='headroom proxy --port 8787'

# Iniciar proxy com output shaper ativado
alias headroom-proxy-verbose='HEADROOM_OUTPUT_SHAPER=1 headroom proxy --port 8787'
```

Isso garante que o binário do headroom está disponível sem precisar ativar o venv manualmente. A shell function resolve o path absoluto do venv.

### Configuração

**Modo Proxy** (mais versátil para múltiplos providers):

```bash
# Iniciar proxy na porta 8787
headroom proxy --port 8787

# DeepSeek é compatível com OpenAI API — configurar OpenCode
# para usar http://localhost:8787/v1 como base URL
```

**Output Token Shaper** (reduz tokens de saída também):

```bash
export HEADROOM_OUTPUT_SHAPER=1
headroom proxy --port 8787
```

### Integração com OpenCode

Configure o OpenCode para usar Headroom como proxy:

```json
// opencode.json
{
  "provider": "openai",   // ou "deepseek"
  "apiBase": "http://localhost:8787/v1",
  "model": "deepseek-chat"
}
```

### Integração com GitHub Copilot

```bash
# Login OAuth do Copilot (via Headroom)
headroom copilot-auth login
headroom wrap copilot --subscription -- --model gpt-4o
```

---

## 3. Caveman — Prompt de Saída Terso

Claude Code skill (~75% menos tokens de saída). No OpenCode, usar skill equivalente.

### Instalação (se usar Claude Code no futuro)

```bash
curl -fsSL https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh | bash
```

### Para OpenCode — Skill Terse equivalente

Criar um skill/CLAUDE.md para o OpenCode com instruções de saída concisa:

```markdown
# AI Cost Optimization - OpenCode Skill
- Seja conciso. Sem saudações, sem cerimônia.
- Use fragments. Drop artigos/filler/hedging.
- Código, paths, erros: manter exatos.
- Padrão: [coisa] [ação] [motivo]. [próximo passo].
```

**Níveis de intensidade:**
| Nível | Comportamento |
|-------|---------------|
| `lite` | Frases completas, só corta filler |
| `full` | Prosa abreviada (config → cfg, porque → pq) |
| `ultra` | Telegráfico, setas para causa/efeito |

---

## 4. OpenUsage — Monitor de Assinaturas

App macOS nativo na menu bar. Mostra uso de: Copilot, Claude, Codex, Cursor, OpenCode.

### Instalação

```bash
# Download do último release
curl -fsSL -o /tmp/OpenUsage.dmg \
  "https://github.com/robinebers/openusage/releases/latest/download/OpenUsage.dmg"
# Montar e arrastar para /Applications
hdiutil attach /tmp/OpenUsage.dmg
cp -R /Volumes/OpenUsage/OpenUsage.app /Applications/
hdiutil detach /Volumes/OpenUsage
```

Ou baixar manualmente de: https://github.com/robinebers/openusage/releases/latest

### Providers suportados que você usa

| Provider | Suporte OpenUsage | Notas |
|----------|:-----------------:|-------|
| GitHub Copilot | ✅ | premium, chat, completions |
| OpenCode | ✅ (OpenCode Go) | 5h, weekly, monthly spend |
| Claude | ✅ | session, weekly, extra |
| DeepSeek | ❌ (não listado) | Pode ser adicionado via plugin API |

### Local HTTP API

OpenUsage expõe API em `http://127.0.0.1:6736` para outras apps consumirem dados de uso.

---

## Plano de Teste (Ordem)

### Fase 1 — RTK (mais impacto imediato)

```bash
# 1. Instalar
brew install rtk
rtk --version

# 2. Ativar hook global para terminal
rtk init -g

# 3. Verificar savings
rtk gain

# 4. Testar no VSCode integrado com Copilot
# Abrir terminal no VSCode, rodar git status e ver output compactado
```

### Fase 2 — OpenUsage (monitoramento)

```bash
# 1. Instalar app
# 2. Abrir e configurar providers (Copilot, OpenCode)
# 3. Verificar menu bar
```

### Fase 3 — Headroom (proxy avançado)

```bash
# 1. Instalar no venv
python3 -m venv ~/.local/venvs/headroom
source ~/.local/venvs/headroom/bin/activate
pip install "headroom-ai[proxy]"
deactivate

# 2. Configurar alias no .zshrc (ver seção Headroom)
# 3. Iniciar proxy como teste
headroom proxy --port 8787

# 4. Configurar como proxy para DeepSeek no OpenCode
# 5. Ver savings: headroom dashboard
```

### Fase 4 — Skill Terso (OpenCode)

```bash
# 1. Adicionar skill de output conciso no OpenCode
# 2. Testar com prompts reais
# 3. Comparar tamanho de output
```

---

## Observações Importantes

### Da análise do artigo (CodePointer, Jun 2026)

- **Savings reais combinados: ~3.7%** (não 60-90% individual)
- RTK só atinge comandos shell (78% do output passa pelos hooks nativos Read/Grep/Glob)
- Headroom comprime em cache_read rate (o token mais barato)
- Caveman só reduz output tokens, não thinking tokens
- **Decisão de segurança**: todas as 3 ferramentas veem seu código/prompts — avaliar risco vs benefício

### RTK tem suporte nativo a OpenCode?

**Não diretamente.** RTK não tem flag `--opencode` no `rtk init`. Mas o plugin `openrtk` (npm) faz a ponte — hook no evento `tool.execute.before` do OpenCode e reescreve comandos para passar pelo RTK.

**Duas formas de integrar:**

| Forma | Vantagem | Desvantagem |
|-------|----------|-------------|
| `rtk init -g` (hook global) | Funciona para qualquer CLI em shell | Não captura tool calls internas do OpenCode |
| `openrtk` plugin (npm) | Captura TODOS os comandos shell via plugin API | Requer npm + config no opencode.json |

**Recomendação**: usar ambos — o hook global cobre o terminal do VSCode/Copilot, e o plugin `openrtk` cobre o OpenCode por dentro.

### Por que o `withakay/opencode-rtk` não funciona?

O repositório `github.com/withakay/opencode-rtk` está vazio (repo em branco). O plugin real e funcional é o **`openrtk`** no npm (`npm install openrtk`), mantido por `martinstannard`. Ele hooka no evento `tool.execute.before` do OpenCode e reescreve comandos como `git status` → `rtk git status` automaticamente.

### Headroom no venv

Headroom roda em um **venv dedicado** (`~/.local/venvs/headroom/`) para não contaminar seu Python global. Os aliases no `.zshrc` usam o path absoluto do venv, então você pode chamar `headroom` de qualquer lugar sem ativar nada.

### Segurança

| Ferramenta | Acesso | Risco se comprometida |
|------------|--------|----------------------|
| RTK | Stdout de comandos, shell hook | Execução arbitrária de comandos |
| Headroom | Prompts, responses, API keys | Vaza chaves e código |
| Caveman | Mensagens (via hooks) | Código executado a cada prompt |

Todas são local-first hoje, mas qualquer release malicioso pode adicionar chamada de rede.

---

## Comandos Rápidos

```bash
# RTK
brew install rtk              # instalar
rtk init -g                    # hook global
rtk gain                       # ver savings
rtk discover                   # oportunidades perdidas

# Headroom (via venv dedicado)
python3 -m venv ~/.local/venvs/headroom
source ~/.local/venvs/headroom/bin/activate
pip install "headroom-ai[proxy]"
deactivate
headroom proxy --port 8787      # iniciar proxy
headroom dashboard              # dashboard ao vivo
headroom perf                   # benchmark

# OpenUsage
# App macOS nativo - download do GitHub Releases
```
