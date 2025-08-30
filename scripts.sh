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

# NOTE: this will Recursively formate all the json files in the current directory
# find . -type f -name "*.json" -exec bash -c ' . ~/app/linux-setup/scripts.sh && pretyjson "$0"' {} \;

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
  d=$(g_path -d "$1")
  f=$(g_path -f "$1")
  if [[ "$d" != "" ]]; then
    mkdir -p "$d"
    cd "$d" || exit
    echo -e "\e[1;32m[Success]\e[0m Directory created and navigated to: \e[1;34m($d)\e[0m"
  fi

  if [[ "$f" != "" ]]; then
    touch "$f"
    echo -e "\e[1;32m[Success]\e[0m File created: \e[1;33m($f)\e[0m"
  fi
}

alias git-store="git config --global credential.helper store"
alias gcm='git diff --cached | gemini --prompt "Generate a concise, conventional commit message based on the following git diff:" | xargs git commit -m'
