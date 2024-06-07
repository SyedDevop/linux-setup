nf() {
	query=""
	if [[ $# -gt 0 ]]; then
		query=("$*")
	fi
	fzf --query "$query" --preview 'bat --style=numbers --color=always --line-range :500 {}' | xargs -I {} nvim {}
}

pretyjson() {
	local temp_file
	temp_file=$(mktemp) &&
		jq . <"$1" >"$temp_file" &&
		mv -- "$temp_file" "$1"
}

take() {
	dir_path="${1%/*.*}"
	mkdir -p "$dir_path"
	cd "$dir_path" || exit
	echo -e "\e[32m Created and Cd to : ($dir_path) \e[0m"
	if [[ "$1" == *.* ]]; then
		filename=$(basename "$1")
		touch "$filename"
		echo -e "\e[32m Created File : ($filename) \e[0m"
	fi
}
