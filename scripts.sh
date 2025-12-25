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

# Function for AI-generated commit messages
gcm() {
  if ! git diff --cached --quiet; then
    echo "Generating commit message..."
    commit_msg=$(git diff --cached --ignore-all-space -w | gemini --prompt "Generate a concise, conventional commit message (type: description) based on this git diff. Use conventional commit format with types like feat, fix, docs, style, refactor, test, chore:")

    if [ $? -eq 0 ] && [ -n "$commit_msg" ]; then
      echo "Generated commit message: $commit_msg"
      read -p "Proceed with commit? (y/N): " confirm
      if [[ $confirm =~ ^[Yy]$ ]]; then
        git commit -m "$commit_msg"
      else
        echo "Commit cancelled"
      fi
    else
      echo "Failed to generate commit message. Please commit manually."
    fi
  else
    echo "No staged changes to commit"
  fi
}

# Optional: Add alias for convenience
alias gcm='gcm'

alias weather='curl wttr.in'

alias local_ip='ip -4 -o addr show up | awk '\''{print $2, $4}'\'''
