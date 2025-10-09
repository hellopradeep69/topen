#!/usr/bin/bash

name="$1"

case "$name" in
btop)
    btop
    ;;
ytdown)
    ~/.local/bin/ytdown.sh
    ;;
lf)
    lf ~/
    ;;
lazygit)
    lazygit
    ;;
gitgo)
    url=$(git remote get-url origin 2>/dev/null)

    if [[ -z "$url" ]]; then
        echo "Not in a repo folder"
        notify-send -u normal ":-)" "Not in a repo folder"
    else
        xdg-open "$url"
    fi
    ;;
*)
    echo "Usage: topen.sh [OPTIONS] "
    echo "Options:"
    echo "  btop         Opens btop"
    echo "  lf           Opens lf"
    echo "  gitgo        Opens the currect repo in browser"
    echo "  ytdown       Opens a yt-dlp ui"
    echo "  lazygit      Opens Lazygit for current directory"
    exit 0
    ;;
esac
