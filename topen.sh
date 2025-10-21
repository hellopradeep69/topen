#!/usr/bin/bash

# Colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
RESET="\e[0m"

name="$1"
FILE="$2"

check_argument() {
    if [ ! -f "$FILE" ]; then
        echo -e "${RED}Error:${RESET} File not found!"
        exit 1
    fi
}

check_tmux() {
    if [ -z "$TMUX" ]; then
        notify-send -u normal "WARN:" "Not Inside tmux session"
    else
        session_name="$(tmux display-message -p '#S')"
    fi
}

window_create() {

    win_name="Code"
    tmux kill-pane -t "$session_name:$win_name"

    if ! tmux list-windows -t "$session_name" | grep -q "$win_name"; then
        tmux new-window -t "$session_name" -n "$win_name" -c "#{pane_current_path}"
    else
        tmux select-window -t "$session_name:$win_name"
    fi
}

code_start() {
    check_argument "$FILE"
    check_tmux
    window_create
    tmux send-keys -t "$session_name:$win_name" "clear;code.sh "$FILE"" Enter
    tmux select-window -t "$session_name:$win_name"
}

exclude_dir() {
    EXCLUDE_DIRS=(~/.tmux ~/Templates ~/.cache ~/.rustup ~/.npm ~/.zen ~/.linuxmint
        ~/Public ~/.icons ~/Desktop ~/.cargo ~/.mozilla ~/.themes ~/.w3m ~/.golf ~/.java ~/.cursor)

    exclude_args=""
    for d in "${EXCLUDE_DIRS[@]}"; do
        exclude_args+=" -not -path '$d*'"
    done

    eval "find ~ -mindepth 1 -maxdepth 2 -type d -not -path '*/\.git*' $exclude_args 2>/dev/null"
}

fzfdir() {
    # list TMUX sessions
    if [[ -n "${TMUX}" ]]; then
        current_session=$(tmux display-message -p '#S')
        tmux list-sessions -F "[TMUX] #{session_name}" 2>/dev/null | grep -vFx "[TMUX] $current_session"
    else
        tmux list-sessions -F "[TMUX] #{session_name}" 2>/dev/null | sort
    fi

    exclude_dir

}

open_fzf() {

    selected=$(fzfdir | fzf \
        --prompt="Select tmux item (q to quit): " \
        --border \
        --reverse \
        --bind "q:abort" \
        --inline-info \
        --cycle)

    [ -z "$selected" ] && exit 0

    if [[ -d "$selected" ]]; then
        dir="$selected"

        session_name=$(basename "$dir" | tr . _)

        if tmux has-session -t "$1" "$session_name" 2>/dev/null; then
            [ -n "$TMUX" ] && tmux switch-client -t "$session_name" || tmux attach -t "$session_name"
        else
            tmux new-session -d -s "$session_name" -c "$dir" -n "main"
            [ -n "$TMUX" ] && tmux switch-client -t "$session_name" || tmux attach -t "$session_name"
        fi
        exit 0

    else
        # Existing session
        session_name=$(echo "$selected" | awk '{print $2}')
        [ -n "$TMUX" ] && tmux switch-client -t "$session_name" || tmux attach -t "$session_name"
    fi
}

open_it() {
    selected_name=$(basename "$selected" | tr . _)

    # echo "$selected_name"
    if ! tmux has-session -t "$selected_name" 2>/dev/null; then
        tmux new-session -ds "$selected_name" -c "$selected" -n "main"
        tmux select-window -t "$selected_name:1"
    fi

    tmux switch-client -t "$selected_name"
}

home_open() {

    session_name="home"
    if tmux has-session -t "$session_name" 2>/dev/null; then
        [ -n "$TMUX" ] && tmux switch-client -t "$session_name" || tmux attach -t "$session_name"
    else
        tmux new-session -d -s "$session_name" -c "$HOME" -n "main"
        [ -n "$TMUX" ] && tmux switch-client -t "$session_name" || tmux attach -t "$session_name"
    fi
    exit 0

}

twander_open() {
    selected="$1"

    if [[ "$selected" == "home" ]]; then
        home_open
    else
        if [ ! -d "$selected" ]; then
            echo "Directory $selected does not exist"
            return 1
        else
            open_it
        fi
    fi
}

gitgo_open() {
    url=$(git remote get-url origin 2>/dev/null)

    if [[ -z "$url" ]]; then
        echo "Not in a repo folder"
        notify-send -u normal ":-)" "Not in a repo folder"
    else
        xdg-open "$url"
    fi
}

readme_open() {
    xdg-open "https://github.com/hellopradeep69/topen.git"
}

check_tmux_open() {
    if [ -z "$TMUX" ]; then
        home_open
        exit 1
    fi
}

check_tmux_open

case "$name" in
btop | -b)
    btop
    ;;
ytdown | -yt)
    ~/.local/bin/ytdown.sh
    ;;
twander | -d)
    twander_open "$2"
    ;;
lf)
    lf ~/
    ;;
lazygit | -l)
    lazygit
    ;;
fdir | -f)
    open_fzf
    ;;
code | -c)
    code_start
    ;;
gitgo | -g)
    gitgo_open
    ;;
readme)
    readme_open
    ;;
*)
    echo "Usage: topen.sh [OPTIONS] "
    echo "Options:"
    echo "  btop,-b                  Opens btop"
    echo "  lf                       Opens lf from home directory"
    echo "  gitgo,-g                 Opens the currect repo in browser"
    echo "  ytdown,-yt               Opens a yt-dlp ui"
    echo "  lazygit,-l               Opens Lazygit for current directory"
    echo "  twander,-d <directory>   Pass a Directory as argument to open in a tmux session"
    echo "  fdir,-f                  Opens a fuzzy finder for directory and open in tmux session"
    echo "  code,-c                  Run and show Error/Output in new tmux window for more info use readme "
    echo "  readme                   For more info"
    exit 0
    ;;
esac
