#!/bin/bash

if command -v fd >/dev/null 2>&1; then
    FD="fd"
elif command -v fdfind >/dev/null 2>&1; then
    FD="fdfind"
else
    echo "Error: Neither fd nor fdfind found. Please install one of them."
    exit 1
fi

if [[ "$(uname)" == "Darwin" ]]; then
    DIRS=(
        "$HOME/Documents"
        "$HOME/Developer"
        "$HOME"
    )
else
    DIRS=(
        "$HOME/Documents"
        "$HOME"
    )
fi

if [[ $# -eq 1 ]]; then
    selected=$1
else
    # Use fzf with preview (fallback to sk if fzf not available)
    if command -v fzf &> /dev/null; then
        FUZZY="fzf"
        # Note: Preview désactivé temporairement, problème avec ls options dans fzf
        FUZZY_OPTS="--height 50% --layout=reverse --border --margin=1"
    elif command -v sk &> /dev/null; then
        FUZZY="sk"
        FUZZY_OPTS="--margin 10% --color=bw"
    else
        echo "Error: Neither fzf nor sk found. Please install one of them."
        exit 1
    fi
    
    selected=$($FD . "${DIRS[@]}" --type=directory --max-depth=3 --full-path \
        | sed "s|^$HOME/||" \
        | $FUZZY $FUZZY_OPTS)
    [[ $selected ]] && selected="$HOME/$selected"
fi

[[ ! $selected ]] && exit 0

selected_name=$(basename "$selected" | tr . _)

# Si on est dans tmux, créer une nouvelle window (tab) dans la session actuelle
if [ -n "$TMUX" ]; then
    tmux new-window -n "$selected_name" -c "$selected"
else
    # Si on n'est pas dans tmux, créer une nouvelle session ou s'y attacher
    if ! tmux has-session -t "$selected_name" 2>/dev/null; then
        tmux new-session -ds "$selected_name" -c "$selected"
    fi
    tmux attach-session -t "$selected_name"
fi
