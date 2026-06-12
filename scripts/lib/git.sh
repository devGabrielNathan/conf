#!/usr/bin/env bash
# git.sh — Inicializa e prepara o repositório Git
#
# Se git estiver disponível e o diretório ainda não for
# um repositório, faz init e stage de todos os arquivos.
# Se já for um repositório, apenas adiciona mudanças.

git_main() {
  if ! command -v git &>/dev/null; then
    echo ""
    echo "  [AVISO]: 'git' não está instalado."
    echo "  O NixOS continuará compilando via path local,"
    echo "  mas instale git para usar Nix Flakes."
    return
  fi

  if git -C "$PROJECT_DIR" rev-parse --is-inside-work-tree &>/dev/null; then
    echo "  ✓ Repositório Git ativo em $PROJECT_DIR"
    git -C "$PROJECT_DIR" add -A || true
  else
    echo "  Inicializando repositório Git em $PROJECT_DIR..."
    if git -C "$PROJECT_DIR" init && git -C "$PROJECT_DIR" add -A; then
      echo "  ✓ Repositório Git inicializado e arquivos adicionados."
    else
      echo "  [AVISO]: Falha ao inicializar o Git."
    fi
  fi
}
