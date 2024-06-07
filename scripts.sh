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

# take() {
# 	dir_path="${1%/*.*}"
# 	mkdir -p "$dir_path"
# 	cd "$dir_path" || exit
# 	echo -e "\e[32m Created and Cd to : ($dir_path) \e[0m"
# 	if [[ "$1" == *.* ]]; then
# 		filename=$(basename "$1")
# 		touch "$filename"
# 		echo -e "\e[32m Created File : ($filename) \e[0m"
# 	fi
# }

take() {
	dir_path="${1%/*.*}"
	mkdir -p "$dir_path"
	if cd "$dir_path"; then
		echo -e "\e[1;32m[Success]\e[0m Directory created and navigated to: \e[1;34m($dir_path)\e[0m"
	else
		echo -e "\e[1;31m[Error]\e[0m Failed to create or navigate to directory: \e[1;34m($dir_path)\e[0m"
	fi

	if [[ "$1" == *.* ]]; then
		filename=$(basename "$1")
		if touch "$filename"; then
			echo -e "\e[1;32m[Success]\e[0m File created: \e[1;33m($filename)\e[0m"
		else
			echo -e "\e[1;31m[Error]\e[0m Failed to create file: \e[1;33m($filename)\e[0m"
		fi
	fi
}
