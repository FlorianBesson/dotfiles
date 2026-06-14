#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="${ROFI_AI_CONFIG:-$HOME/.config/rofi/ai.env}"
ROFI_THEME="${ROFI_AI_THEME:-$HOME/.config/rofi/ketzon-zoomed.rasi}"
OLLAMA_HOST="${OLLAMA_HOST:-http://localhost:11434}"

if [[ -f "$CONFIG_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$CONFIG_FILE"
fi

MODEL="${OLLAMA_MODEL:-gemma4:latest}"

prompt="$(rofi -dmenu -i -p "AI" -theme "$ROFI_THEME" -lines 0)"
if [[ -z "${prompt// }" ]]; then
  exit 0
fi

if ! command -v ollama >/dev/null 2>&1; then
  rofi -e "Ollama est introuvable.

Installe Ollama, puis lance un modèle local."
  exit 1
fi

if ! curl -fsS "$OLLAMA_HOST/api/tags" >/dev/null 2>&1; then
  rofi -e "Ollama ne répond pas.

Essaie:
sudo systemctl start ollama

Ou, si tu utilises un service utilisateur:
systemctl --user start ollama"
  exit 1
fi

if ! ollama list | awk 'NR > 1 {print $1}' | grep -Fxq "$MODEL"; then
  available_models="$(ollama list | awk 'NR > 1 {print $1}' | sed '/^$/d')"
  if [[ -z "$available_models" ]]; then
    rofi -e "Aucun modèle Ollama installé.

Exemple:
ollama pull gemma3:4b"
  else
    rofi -e "Modèle Ollama introuvable: $MODEL

Modèles disponibles:
$available_models

Tu peux changer le modèle dans:
$CONFIG_FILE"
  fi
  exit 1
fi

notify-send "AI" "Question envoyée à Ollama..." >/dev/null 2>&1 || true

payload="$(
  jq -n \
    --arg model "$MODEL" \
    --arg prompt "$prompt" \
    '{
      model: $model,
      stream: false,
      system: "Réponds en français, directement et brièvement. Pour une question technique, donne la commande ou l’explication utile sans blabla.",
      prompt: $prompt
    }'
)"

response="$(
  curl -fsS "$OLLAMA_HOST/api/generate" \
    -H "Content-Type: application/json" \
    -d "$payload"
)"

if jq -e '.error' >/dev/null 2>&1 <<<"$response"; then
  message="$(jq -r '.error // "Erreur Ollama inconnue"' <<<"$response")"
  rofi -e "Erreur Ollama:
$message"
  exit 1
fi

answer="$(
  jq -r '.response // empty' <<<"$response"
)"

if [[ -z "${answer// }" || "$answer" == "null" ]]; then
  rofi -e "Réponse vide ou format inattendu."
  exit 1
fi

if command -v xclip >/dev/null 2>&1; then
  printf '%s' "$answer" | xclip -selection clipboard
fi

choice="$(
  printf '%s\n' "Copier la réponse" "Copier question + réponse" "Fermer" |
    rofi -dmenu -i -p "Réponse" -theme "$ROFI_THEME" -mesg "$answer" -lines 3
)"

case "$choice" in
  "Copier la réponse")
    printf '%s' "$answer" | xclip -selection clipboard
    notify-send "AI" "Réponse copiée." >/dev/null 2>&1 || true
    ;;
  "Copier question + réponse")
    printf 'Q: %s\n\nR: %s' "$prompt" "$answer" | xclip -selection clipboard
    notify-send "AI" "Question et réponse copiées." >/dev/null 2>&1 || true
    ;;
esac
