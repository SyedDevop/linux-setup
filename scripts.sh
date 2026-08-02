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
ocm() {
  if ! git diff --cached --quiet; then
    echo "Generating commit message..."
    PROMPT=$(
      cat <<EOF
You are generating a git commit message. Analyze the staged diff below and
describe what actually changed — not a generic placeholder message.

Format:
1. Subject line: "<type>(<scope>): <description>"
   - type: one of feat, fix, docs, style, refactor, perf, test, chore, build, ci
   - scope: optional, short (e.g. component, module, or file area touched);
     omit the parentheses entirely if no clear scope applies
   - description: imperative mood ("add", "fix", "remove" — not "added",
     "fixes", "removing"), lowercase, no trailing period, max 50 chars
     (hard max 72)
2. Blank line.
3. Body (only if the diff is non-trivial — skip for small one-line changes):
   - Wrap at 72 chars
   - Use "-" bullets, one per distinct logical change
   - State WHAT changed and WHY if the diff makes the reason evident
     (e.g. bug being fixed, behavior being added) — don't just restate
     file names
   - Group related hunks across files into one bullet if they serve the
     same purpose; don't list every file separately unless each does
     something different
   - Mention breaking changes explicitly, prefixed with "BREAKING:"
   - If the diff touches tests only, config only, or docs only, say so
     plainly rather than inferring unrelated functional changes

Rules:
- Base the message strictly on the diff content provided below — do not
  invent functionality, fixes, or intent that isn't evidenced by the
  actual changed lines.
- If the diff is truncated or a file's changes aren't fully visible,
  describe only what's visible; don't guess at the rest.
- If there are no staged changes, output exactly: "chore: no staged changes"
  and nothing else.
- If staged changes exist but are trivial (whitespace, formatting,
  comment tweaks), reflect that honestly (e.g. "style: ...") rather than
  overstating their significance.
- Output ONLY the commit message text. No preamble, no explanation, no
  markdown code fences, no quotes around it.
- DO NOT MAKE ANY TOOL CALLS OR PERFORM ANY GIT OR FILE OPERATIONS.

Context:
Branch: $(git symbolic-ref --quiet --short HEAD 2>/dev/null || echo "DETACHED")

Staged changes (stat):
$(git diff --staged --stat 2>/dev/null || echo "none")

Staged diff:
$(git diff --staged 2>/dev/null | head -c 8000 || echo "none")
EOF
    )

    commit_msg=$(opencode run "$PROMPT")

    if [ $? -eq 0 ] && [ -n "$commit_msg" ]; then
      echo "Generated commit message:"
      echo "$commit_msg"
      while true; do

        echo ""
        read -rp "Proceed with commit? ([y]es/ [c]opy/ [p]rompt/ [m]essage/ [n]o): " confirm

        if [[ $confirm =~ ^[Yy]$ ]]; then
          git commit -m "$commit_msg"
          break
        elif [[ $confirm =~ ^[Mm]$ ]]; then
          echo ""
          echo "The message:"
          echo "$commit_msg"
        elif [[ $confirm =~ ^[Pp]$ ]]; then
          echo ""
          echo "The Prompt:"
          echo "$PROMPT"
        elif [[ $confirm =~ ^[Cc]$ ]]; then
          echo -n "$commit_msg" | xclip -selection clipboard
          echo "Commit message copied to clipboard."
        elif [[ $confirm =~ ^([Nn]|)$ ]]; then
          echo "Commit cancelled."
          break
        else
          echo "Invalid choice. Enter y, c, p, or n."
        fi
      done
    else
      echo "Failed to generate commit message. Please commit manually."
    fi
  else
    echo "No staged changes to commit"
  fi
}

alias gcm='ocm'

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
