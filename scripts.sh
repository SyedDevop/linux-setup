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

# Function for AI-generated commit messages
lcm() {
  # Ensure there are staged changes
  if git diff --cached --quiet; then
    echo "No staged changes to commit"
    return 1
  fi

  echo "Generating commit message..."

  # Capture diff safely
  diff=$(git diff --cached --ignore-all-space -w)

  # Build prompt using heredoc (clean + no escaping issues)
  prompt=$(
    cat <<EOF
You are a Git commit message generator.

Analyze the provided git diff and generate a commit message following the Conventional Commits specification.

Rules:
- Format: <type>(optional-scope): <short description>
- Types: feat, fix, docs, style, refactor, test, chore
- Use imperative mood (e.g., "add", "fix")
- Max 60 characters in subject
- No trailing period
- Focus on intent, not just changes
- Optional body: max 2–3 bullet points
- Avoid vague phrases like "update code"

Output:
- Return ONLY the commit message
- No explanations, no quotes

Git diff:
$diff
EOF
  )

  # Run model
  commit_msg=$(
    /media/work/llm/llama-b9016/llama-cli \
      -st \
      -m /media/work/llm/Bonsai-8B.gguf \
      -p "$prompt" \
      --log-disable \
      2>/dev/null
  )

  # Trim whitespace
  commit_msg=$(echo "$commit_msg" | sed '/^\s*$/d')
  echo "-------------------"
  echo $commit_msg
  echo "-------------------"
  return 0
  if [ -z "$commit_msg" ]; then
    echo "Failed to generate commit message. Please commit manually."
    return 1
  fi

  echo
  echo "Generated commit message:"
  echo "--------------------------------"
  echo "$commit_msg"
  echo "--------------------------------"

  read -r -p "Proceed with commit? (y/N): " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    git commit -m "$commit_msg"
  else
    echo "Commit cancelled"
  fi
}
# Optional: Add alias for convenience
alias gcm='gcm'

alias weather='curl wttr.in'

alias local_ip='ip -4 -o addr show up | awk '\''{print $2, $4}'\'''

# Function to navigate to the directory of the selected file
cdf() {
  local file
  file=$(fzf --preview 'bat --style=numbers --color=always --line-range :500 {}') || return
  cd "$(dirname "$file")"
}

# A persistent scratchpad for temp per vary things
scratch() {
  nvim "$HOME/.scratchpad.md"
  # if command -v nvim &>/dev/null; then
  #   nvim -u NONE "$HOME/.scratchpad"
  # else
  #   vi "$HOME/.scratchpad"
  # fi
}
