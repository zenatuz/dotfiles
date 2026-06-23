# AI Cost Optimization

Teste da stack **RTK + Headroom + Caveman** para redução de tokens LLM, com monitoramento via **OpenUsage**.

Branch: `ai-cost-optimization`

## Stack

| Ferramenta | Função | Instalação |
|------------|--------|------------|
| **RTK** | Compacta output de comandos shell (git, ls, grep, test, curl) | `brew install rtk` |
| **Headroom** | Proxy que comprime tool outputs antes do LLM | `pip install "headroom-ai[proxy]"` |
| **Caveman** | Skill para saída tersa do modelo | `curl ... \| bash` (Claude Code) |
| **OpenUsage** | Monitor de assinaturas na menu bar | DMG do GitHub Releases |

## Setup

| IDE | Provider | Integração Stack |
|-----|----------|------------------|
| VSCode | GitHub Copilot (trabalho) | RTK hook + OpenUsage |
| OpenCode | DeepSeek (pessoal) | Headroom proxy + RTK |

## Como testar

```bash
# Mac work machine
cd ~/projects/dotfiles && yadm checkout ai-cost-optimization

# Depois seguir: ai-cost-optimization/INSTALL.md
```

## Leitura base

- [Cutting LLM Token Costs with rtk, headroom, and caveman](https://codepointer.substack.com/p/cutting-llm-token-costs-with-rtk)
- [rtk-ai/rtk](https://github.com/rtk-ai/rtk)
- [headroomlabs-ai/headroom](https://github.com/headroomlabs-ai/headroom)
- [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman)
- [robinebers/openusage](https://github.com/robinebers/openusage)

## Escopo

1. ✅ Branch criada para testes
2. ⬜ Fase 1: RTK (maior impacto imediato)
3. ⬜ Fase 2: OpenUsage (monitoramento)
4. ⬜ Fase 3: Headroom (proxy avançado)
5. ⬜ Fase 4: Skill terso (OpenCode)
6. ⬜ Definir escopo final e merge no main
