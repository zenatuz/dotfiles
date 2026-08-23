#!/bin/bash
# Strip Aikido certificate injection blocks from .zshrc on commit
# Lines between # aikido-endpoint-*-cert-config-start and # aikido-endpoint-*-cert-config-end are removed
# Standalone export lines with Aikido paths are also removed
sed -E \
  -e '/# aikido-endpoint-.*cert-config-start/,/# aikido-endpoint-.*cert-config-end/d' \
  -e '/^export.*AikidoSecurity/d' \
  -e '/^local aikido_.*=\/Library\/Application Support\/AikidoSecurity/d' \
  -e '/^unset aikido_/d'