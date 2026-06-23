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

Para **OpenCode** — usar o plugin community:

```bash
# Plugin OpenCode RTK
# https://github.com/withakay/opencode-rtk
git clone https://github.com/withakay/opencode-rtk ~/.opencode/plugins/rtk
# Seguir README do plugin para configurar
```

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

### Instalação

```bash
# Python (requer Python 3.10+)
pip install "headroom-ai[proxy]"

# Verificar
headroom --help
```

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
# 1. pip install "headroom-ai[proxy]"
# 2. Configurar como proxy para DeepSeek
# 3. Testar com OpenCode
# 4. Ver savings no dashboard: headroom dashboard
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

**Não.** RTK não tem flag `--opencode` no `rtk init`. A integração é via plugins community:
- `withakay/opencode-rtk` — plugin OpenCode
- `strotgen/opencode-rtk-plugin` — alternativa

Alternativa mais simples: usar RTK como hook global (`rtk init -g`) que funciona para qualquer CLI que execute comandos shell (incluindo OpenCode), sem precisar de plugin específico.

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

# Headroom
pip install "headroom-ai[proxy]"
headroom proxy --port 8787      # iniciar proxy
headroom dashboard              # dashboard ao vivo
headroom perf                   # benchmark

# OpenUsage
# App macOS nativo - download do GitHub Releases
```
