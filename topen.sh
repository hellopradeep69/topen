#!/usr/bin/bash

name="$1"

twander_open() {
    selected="$1"

    if [ ! -d "$selected" ]; then
        echo "Directory $selected does not exist"
        return 1
    fi

    rel_path=$(realpath --relative-to="$HOME" "$selected")
    selected_name=$(echo "$rel_path" | tr / _ | tr -cd '[:alnum:]_')

    # echo "$selected_name"
    if ! tmux has-session -t "$selected_name" 2>/dev/null; then
        tmux new-session -ds "$selected_name" -c "$selected" -n "main"
        tmux select-window -t "$selected_name:1"
    fi

    tmux switch-client -t "$selected_name"

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

case "$name" in
btop)
    btop
    ;;
ytdown)
    ~/.local/bin/ytdown.sh
    ;;
twander | d)
    twander_open "$2"
    ;;
lf)
    lf ~/
    ;;
lazygit)
    lazygit
    ;;
gitgo)
    gitgo_open
    ;;
readme)
    readme_open
    ;;
*)
    echo "Usage: topen.sh [OPTIONS] "
    echo "Options:"
    echo "  btop                    Opens btop"
    echo "  lf                      Opens lf from home directory"
    echo "  gitgo                   Opens the currect repo in browser"
    echo "  ytdown                  Opens a yt-dlp ui"
    echo "  lazygit                 Opens Lazygit for current directory"
    echo "  twander,d <directory>   Pass a Directory as argument to open in a tmux session"
    echo "  readme                  For more info"
    exit 0
    ;;
esac
