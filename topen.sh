#!/usr/bin/bash

name="$1"

# for tarpoon
CACHE="$HOME/.cache/tarpoon_cache"
touch "$CACHE"

# for History
HISTORY_CACHE="$HOME/.cache/HISTORY_cache"
touch "$HISTORY_CACHE"

# fuzzy finder tmux [Tmux sessionizer]
exclude_dir() {
	EXCLUDE_DIRS=(~/.tmux ~/Templates ~/.cache ~/.rustup ~/.npm ~/.zen ~/.linuxmint
		~/Public ~/.icons ~/Desktop ~/.cargo ~/.mozilla ~/.themes ~/.w3m ~/.golf
		~/.java ~/.cursor ~/fastfetch ~/Telegram ~/.fzf ~/.dbus ~/Dot-conf/*
		~/.pki ~/Music/* ~/.oh-my-zsh ~/Sessions.vim ~/.ssh ~/.gnupg ~/Downloads/zen)

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
		tmux list-sessions -F '#S' |
			fzf --preview 'tmux capture-pane -pt {} -S -50'
	)"
}

# W3m+tmux wrapper
Link_search() {
	(echo "History" && tmux capture-pane -J -p | grep -oE '(http|https)://[a-zA-Z0-9+./?=_%:-]+' | sort -t: -u) | fzf-tmux -d20 --multi --print-query
}

W3m_history() {
	local query=$(cat $HISTORY_CACHE | fzf-tmux -d20 --multi --print-query)
	if [[ -n "$query" ]]; then
		tmux splitw -d "w3m 'https://lite.duckduckgo.com/lite/?q=${query// /+}'"
	fi
}

W3m_tmux() {
	link=$(Link_search)
	browser=$(echo $link | awk '{print $1}')
	query=$(echo $link | sed "s/w3m//")
	if [[ -n "$query" && $query != *History* ]]; then
		echo $query >>$HISTORY_CACHE
	fi
	if [[ $browser = "w3m" ]]; then
		tmux splitw -d "w3m 'https://lite.duckduckgo.com/lite/?q=${query// /+}'"
	elif [[ $browser = "History" ]]; then
		W3m_history
	else
		echo $link | xargs -r xdg-open
	fi
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
ytdown | -yt)
	~/.local/bin/ytdown.sh
	;;
twander | -d)
	twander_open "$2"
	;;
fdir | -f)
	open_fzf
	;;
gitgo | -g)
	gitgo_open
	;;
readme)
	readme_open
	;;
-w3m)
	W3m_tmux
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
	echo "  gitgo,-g                 Opens the currect repo in browser"
	echo "  ytdown,-yt               Opens a yt-dlp ui"
	echo "  twander,-d <directory>   Pass a Directory as argument to open in a tmux session"
	echo "  fdir,-f                  Opens a fuzzy finder for directory and open in tmux session"
	echo "  -s                       Choose session using Fzf"
	echo "  -w3m                     w3m + tmux wrapper using fzf"
	echo "  -H                       Track current tmux session"
	echo "  -h                       List tracked sessions and choose one interactively"
	echo "  -hn                      Jump to the next tracked session"
	echo "  -hp                      Jump to the previous tracked session"
	echo "  -h <index>               Switch to the tarpoon session at the given index"
	echo "  readme                   For more info"
	exit 0
	;;
esac
