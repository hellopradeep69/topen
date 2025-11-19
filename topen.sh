#!/usr/bin/bash

# Colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
RESET="\e[0m"

name="$1"
FILE="$2"

# for tarpoon
CACHE="$HOME/.cache/tarpoon_cache"
touch "$CACHE"

# Code
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

# fuzzy finder tmux [Tmux sessionizer]
exclude_dir() {
  EXCLUDE_DIRS=(~/.tmux ~/Templates ~/.cache ~/.rustup ~/.npm ~/.zen ~/.linuxmint
    ~/Public ~/.icons ~/Desktop ~/.cargo ~/.mozilla ~/.themes ~/.w3m ~/.golf
    ~/.java ~/.cursor ~/fastfetch ~/Telegram ~/.fzf ~/.dbus ~/Dot-conf/*)

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
    # tmux list-sessions -F "[TMUX] #{session_name}" 2>/dev/null | grep -vFx "[TMUX] $current_session" | sort
    tmux list-sessions -F "[TMUX] #{session_name} #{?session_attached,*, } " 2>/dev/null | sort
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
    --no-sort \
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

# directory
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

# open git repo
gitgo_open() {
  url=$(git remote get-url origin 2>/dev/null)

  if [[ -z "$url" ]]; then
    echo "Not in a repo folder"
    notify-send -u normal ":-)" "Not in a repo folder"
  else
    xdg-open "$url"
  fi
}

# open git repo for topen
readme_open() {
  xdg-open "https://github.com/hellopradeep69/topen.git"
}

# Harpoon
Def_tarpoon() {
  grep -vxF "edit" "$CACHE" >"${CACHE}.tmp"
  mv "${CACHE}.tmp" "$CACHE"
  echo "edit" >>"$CACHE"
}

List_tarpoon() {
  cat "$CACHE"
}

Index_tarpoon() {
  cat -n "$CACHE"
}

Add_tarpoon() {
  dir="$PWD"
  ses_name=$(tmux display-message -p '#S ')

  # echo "$ses_name"

  if ! grep -qxF "$ses_name $dir" "$CACHE"; then
    echo "$ses_name" "$dir" >>"$CACHE"
    notify-send "Added to tarpoon" "$ses_name"
  else
    notify-send "Already exists" "$ses_name"
  fi
}

Already_harpoon() {
  already_session="$1"
  current_session=$(tmux display-message -p '#S')
  # echo "$current_session $already_session"
  if [[ "$already_session" == "$current_session" ]]; then
    notify-send "Already inside the session" "$current_session"
  fi
}

Make_tarpoon() {
  # echo "$path"
  session_name="$1"
  local path="$2"

  if ! tmux has-session -t "$session_name" 2>/dev/null; then
    tmux new-session -ds "$session_name" -c "$path"
  fi
  tmux switch-client -t "$session_name"
}

Check_tarpoon() {
  local session="$1"
  local path="$2"

  if [[ "$session" = "edit" ]]; then
    # exec tmux popup -E "nvim $CACHE"
    tmux new-window -n "edit" nvim "$CACHE"
  else
    Make_tarpoon "$session" "$path"
  fi
}

Jump_tarpoon() {

  local path=$(
    List_tarpoon | fzf \
      --bind "q:abort" \
      --reverse \
      --inline-info \
      --tmux center
  )

  tsession=$(echo "$path" | awk '{print $1}')
  tpath=$(echo "$path" | awk '{print $2}')

  # echo "$tsession"
  # echo "$tpath"

  Already_harpoon "$tsession"

  if [ -n "$path" ]; then
    if [ -n "$TMUX" ]; then
      Check_tarpoon "$tsession" "$tpath"
    fi
  fi
}

Switch_tarpoon() {

  index="$1"
  len_index=$(Index_tarpoon | awk '{print $1}' | tail -n 1)
  len=$((len_index - 1))
  # echo "$len_index" && echo "$index" && echo "$len"
  if [[ "$index" -le 0 || "$index" -gt "$len" ]]; then
    notify-send "Invalid Index" "$index"
    exit 0
  fi

  session_name=$(Index_tarpoon | awk -v i="$index" 'NR==i {print $2}')
  path=$(Index_tarpoon | awk -v i="$index" 'NR==i {print $3}')

  Already_harpoon "$session_name"

  Check_tarpoon "$session_name" "$path"
}

Combine_tarpoon() {
  if [[ -n "$1" ]]; then
    Switch_tarpoon "$1"
  else
    Jump_tarpoon
  fi

}

Next_tarpoon() {
  current_session="$(tmux display-message -p '#S')"
  total="$(Index_tarpoon | awk '{print $1}' | tail -n 1)"

  current_index=$(Index_tarpoon | awk -v s="$current_session" '$2 == s {print NR}')
  next_index=$((current_index + 1))

  if [[ "$next_index" = "$total" ]]; then
    next_index=1
  fi

  session_name=$(Index_tarpoon | awk -v i="$next_index" 'NR==i {print $2}')
  path=$(Index_tarpoon | awk -v i="$next_index" 'NR==i {print $3}')

  notify-send "Next_tarpoon" "$session_name"
  Check_tarpoon "$session_name" "$path"
}

Previous_tarpoon() {

  current_session="$(tmux display-message -p '#S')"
  total="$(Index_tarpoon | awk '{print $1}' | tail -n 1)"
  total=$((total - 1))
  echo "$total"

  current_index=$(Index_tarpoon | awk -v s="$current_session" '$2 == s {print NR}')
  prev_index=$((current_index - 1))

  if [[ "$prev_index" -lt 1 ]]; then
    prev_index="$total"

  fi

  session_name=$(Index_tarpoon | awk -v i="$prev_index" 'NR==i {print $2}')
  path=$(Index_tarpoon | awk -v i="$prev_index" 'NR==i {print $3}')

  notify-send "Previous tarpoon" "$session_name"
  Check_tarpoon "$session_name" "$path"
}

Session_it() {
  tmux switch-client -t "$(
    tmux list-sessions -F '#S #{?session_attached,*, }' |
      fzf --preview 'tmux capture-pane -pt {} -S -50'
  )"
}

check_tmux_open() {
  Def_tarpoon

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
-s)
  Session_it
  ;;
-H)
  Add_tarpoon
  ;;
-h)
  Combine_tarpoon "$2"
  ;;
-hn)
  Next_tarpoon
  ;;
-hp)
  Previous_tarpoon
  ;;
*)
  # echo "Usage: topen.sh [OPTIONS] "
  echo "Usage:"
  echo "    ${0##*/} [options] [args]"
  echo "Options:"
  echo "  btop,-b                  Opens btop"
  echo "  lf                       Opens lf from home directory"
  echo "  gitgo,-g                 Opens the currect repo in browser"
  echo "  ytdown,-yt               Opens a yt-dlp ui"
  echo "  lazygit,-l               Opens Lazygit for current directory"
  echo "  twander,-d <directory>   Pass a Directory as argument to open in a tmux session"
  echo "  fdir,-f                  Opens a fuzzy finder for directory and open in tmux session"
  echo "  code,-c                  Run and show Error/Output in new tmux window for more info use readme "
  echo "  -s                       Choose session using Fzf"
  echo "  -H                       Track current tmux session"
  echo "  -h                       List tracked sessions and choose one interactively"
  echo "  -hn                      Jump to the next tracked session"
  echo "  -hp                      Jump to the previous tracked session"
  echo "  -h <index>               Switch to the tarpoon session at the given index"
  echo "  readme                   For more info"
  exit 0
  ;;
esac
